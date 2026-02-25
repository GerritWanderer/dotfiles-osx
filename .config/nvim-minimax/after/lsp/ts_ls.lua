-- ┌─────────────────────┐
-- │ TypeScript LSP config│
-- └─────────────────────┘
--
-- Requires: typescript-language-server
-- Install:  npm install -g typescript-language-server typescript
return {
  on_attach = function(client, _)
    -- Slim down trigger characters for better 'mini.completion' experience
    client.server_capabilities.completionProvider.triggerCharacters =
      { '.', '"', "'", '`', '/', '@', '<' }
  end,
}
