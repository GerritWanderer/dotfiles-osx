#!/bin/bash

# This script uses bits and pieces of the code originally created by Gavin Nugent.
# https://github.com/28allday/W.O.P.R
#
# Some sections have been changed/added to suit my specific needs.
# Original Copyright (c) 2025 Gavin Nugent.
# The code is licensed under the MIT License, see below for details.
#
# MIT License
#
# Copyright (c) 2025 Gavin Nugent
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Add everything we need to use gamescope in Omarchy
# Make sure multilib is enabled in pacman config grep "^\[multilib\]" /etc/pacman.conf

# AMD
yay -S --noconfirm vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver

# Required
echo "Installing required packages..."
yay -S --noconfirm libcap curl pciutils

# Common
echo "Installing common packages..."
yay -S --noconfirm vulkan-tools vulkan-mesa-layers

# Recommended
echo "Installing recommended packares..."
yay -S --noconfirm gamemode lib32-gamemode gamescope mangohud lib32-mangohud proton-ge-custom-bin

# Fix for protontricks (there is a bug in the AUR package, it tries to delete a file that does not exist)
# so instead we have to manually clone the repo, patch the file, build the package, and install it

# install python modules the build process needs
# and apparently vdf and pillow are neede for it to run
sudo pacman -S python-pip
sudo pacman -S python-installer python-wheel python-setuptools python-setuptools-scm python-build python-vdf python-pillow

PKGNAME="protontricks-git"
AUR_URL="https://aur.archlinux.org/${PKGNAME}.git"

# Clone repo if not already present
if [[ ! -d "$PKGNAME" ]]; then
  git clone "$AUR_URL"
fi

cd "$PKGNAME"

PKGBUILD_FILE="PKGBUILD"

# The exact line we want to remove (pattern-based, not brittle)
PATCH_PATTERN='rm -v "\$pkgdir/usr/bin/\$\{pkgname%-git\}-desktop-install"'

if grep -Fq 'rm -v "$pkgdir/usr/bin/${pkgname%-git}-desktop-install"' "$PKGBUILD_FILE"; then
  echo "Patching PKGBUILD: removing broken rm -v line"
  sed -i '\|rm -v "$pkgdir/usr/bin/${pkgname%-git}-desktop-install"|d' "$PKGBUILD_FILE"
else
  echo "Patch not needed: rm -v line not found"
fi

# Build & install
makepkg -si --noconfirm

# Delete the repo
cd ..
rm -rf protontricks-git

# If user is not in the video and input groups, then add them
# otherwise there may be problems with GPU or Controller access
echo "Adding user $USER to video and input groups..."
if ! groups | grep -q '\bvideo\b'; then
  sudo usermod -aG video $USER
fi

if ! groups | grep -q '\binput\b'; then
  sudo usermod -aG input $USER
fi

# Default swappiness is 61, lowering to 10 for better performance
# https://wiki.archlinux.org/title/Swap#Swappiness
SWAPPINESS_FILE="/etc/sysctl.d/99-swappiness.conf"

echo "Setting swappiness kernel parameter to 10..."
sudo sysctl -w vm.swappiness=10

# Check if vm.swappiness is already set in sysctl.conf and replace if needed
if grep -q "^vm.swappiness =" $SWAPPINESS_FILE; then
  # Replace existing line with vm.swappiness=10
  sudo sed -i 's/^vm.swappiness =.*/vm.swappiness = 10/' $SWAPPINESS_FILE
else
  # Add the new line at the end if not found
  echo "vm.swappiness = 10" | sudo tee -a $SWAPPINESS_FILE
fi

# Apply changes immediately
sudo sysctl --system
echo "Swappiness has been set to 10 permanently."

# Check and update open file limit for esync/fsync support permanently
# high  performance applications that handle many files or network connections
# need a greater number of open file descriptors available
LIMITS_FILE="/etc/security/limits.conf"

if [ "$(ulimit -n 2>/dev/null || echo 0)" -lt 524288 ]; then
  echo "Increasing open file limit for esync support..."

  # Check for 'hard nofile' and add/update if necessary
  if ! grep -q "hard nofile" $LIMITS_FILE; then
    echo "hard nofile 524288" | sudo tee -a $LIMITS_FILE >/dev/null
  else
    sudo sed -i '/nofile/s/hard nofile.*/hard nofile 524288/' $LIMITS_FILE
  fi

  # Check for 'soft nofile' and add/update if necessary
  if ! grep -q "soft nofile" $LIMITS_FILE; then
    echo "soft nofile 524288" | sudo tee -a $LIMITS_FILE >/dev/null
  else
    sudo sed -i '/nofile/s/soft nofile.*/soft nofile 524288/' $LIMITS_FILE
  fi

  echo "Open file limit increased or updated to 524288 in $LIMITS_FILE"
fi

# Create udev rule to avoid password prompts for gaming performance control
RULES_FILE="/etc/udev/rules.d/99-gaming-performance.rules"

# Check if the file already exists
if [ ! -f "$RULES_FILE" ]; then
  echo "Creating udev rule file: $RULES_FILE"

  # Add the rules to the udev file
  sudo bash -c "cat > $RULES_FILE <<EOF
# Gaming Mode Performance Control Rules
# Allow users to modify CPU governor and GPU performance settings without sudo

# CPU governor control (all CPUs)
KERNEL==\"cpu[0-9]*\", SUBSYSTEM==\"cpu\", ACTION==\"add\", RUN+=\"/bin/chmod 666 /sys/devices/system/cpu/%k/cpufreq/scaling_governor\"

# AMD GPU performance control
KERNEL==\"card[0-9]\", SUBSYSTEM==\"drm\", DRIVERS==\"amdgpu\", ACTION==\"add\", RUN+=\"/bin/chmod 666 /sys/class/drm/%k/device/power_dpm_force_performance_level\"
EOF"

  echo "Udev rule file created successfully at $RULES_FILE"
else
  echo "Udev rule file already exists at $RULES_FILE"
fi

echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=cpu --subsystem-match=drm

echo "Applying permissions immediately..."
# CPU governor permissions
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
  sudo chmod 666 /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null ||
    echo "Could not set CPU governor permissions (will work after reboot)"
fi

# Detect GPU and apply permissions
if lspci 2>/dev/null | grep -iE 'vga|3d|display' | grep -iqE 'amd|radeon|advanced micro'; then
  sudo chmod 666 /sys/class/drm/card*/device/power_dpm_force_performance_level 2>/dev/null ||
    echo "Could not set AMD GPU permissions (will work after reboot)"
fi

# Granting cap_sys_nice to gamescope (so --rt flag works)
echo "Granting cap_sys_nice to gamescope to ALL USERS..."
echo "  -- remove it later with:"
echo "     sudo setcap -r $(command -v gamescope)"
sudo setcap 'CAP_SYS_NICE=eip' "$(command -v gamescope)"

# All done
echo "All done, example:"
echo "- Launch parameters: gamescope -w 2560 -h 1440 -W 2560 -H 1440 -f -b --backend sdl -s 0.8 --force-grab-cursor --generate-drm-mode fixed --rt -- %command%"
echo "- Set compatibility to Proton-GE"
echo ""
echo "- Modify the gamescope parameters to match your setup (adaptive sync, resolution, hdr, use mangohud, etc)"
echo "- You can use: gamescope --help"
echo ""
echo "Note that --backend sdl is a workaround for gamescope because otherwise the cursor does not work correctly."
