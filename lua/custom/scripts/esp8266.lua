---------------- Settings for working with ESP8266 -------------------
----------------------------------------------------------------------
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      -- runtime = {
      --   version = 'Lua 5.1', -- Essential for NodeMCU compatibility
      -- },
      diagnostics = {
        -- Prevents red squiggles for NodeMCU-specific globals
        globals = { 'vim', 'node', 'wifi', 'gpio', 'net', 'tmr', 'uart', 'file' },
      },
      workspace = {
        library = {
          -- Load Neovim's built-in Lua API types
          vim.api.nvim_get_runtime_file("", true),
          -- Path to your NodeMCU API definitions
          "/home/sca04245/as/rechner/importantfiles/nodeMCU-emmylua/esp8266/library/",
        },
        -- checkThirdParty = false,
      },
      -- telemetry = { enable = false },
    },
  },
})
-- After defining the config, you usually "enable" it for the buffers
-- vim.lsp.enable('lua_ls')

local get_esp_path = function()
  local res = vim.fn.system("nodemcu-tool devices --json 2>/dev/null")
  res = vim.json.decode(res)
  local esp_path = res[1].path
  return esp_path
end

vim.keymap.set('n', '<leader>eu', function()
  local file = vim.fn.expand('%:p')
  local esp_path = get_esp_path()
  vim.cmd("vsplit | term bash -ci 'nodemcu-tool --port " .. esp_path .. " upload " .. file .. " && nodemcu-tool terminal'")
end, { desc = "Upload Esp8266 and Terminal" })

vim.keymap.set('n', '<leader>er', function()
  local esp_path = get_esp_path()
  vim.cmd("vsplit | term bash -ci 'nodemcu-tool --port " .. esp_path .. " reset && nodemcu-tool terminal'")
end, { desc = "Reset Esp8266 and Terminal" })

require("which-key").add({{'<leader>e', group = '[E]sp8266'}})
