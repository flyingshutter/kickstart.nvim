vim.lsp.config('lua_ls', {
  -- Add this block:
on_init = function(client)
  -- Fallback to the current working directory if workspace_folders is nil
  local path = client.workspace_folders
               and client.workspace_folders[1].name
               or vim.fn.getcwd()

  client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
    workspace = {
      library = {
          "/home/sca04245/as/rechner/importantfiles/nodeMCU-emmylua/esp8266/library/",
        unpack(vim.api.nvim_get_runtime_file("", true)),
        path -- Dynamically adds the project folder
      }
    }
  })
  client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  return true
end,
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
          unpack(vim.api.nvim_get_runtime_file("", true)),
          -- vim.api.nvim_get_runtime_file("", true),
          -- Path to your NodeMCU API definitions
          "/home/sca04245/as/rechner/importantfiles/nodeMCU-emmylua/esp8266/library/",
          ".",
        },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
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
    local cmd = "nodemcu-tool --port " .. esp_path .. " upload " .. file

    vim.cmd("vsplit")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)

    vim.fn.jobstart(cmd, {
        term = true,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                print("Upload Successful!")
                -- Close the window after a short delay so you can see the 100%
                vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                end, 1000)
            else
                print("Upload failed with code: " .. exit_code)
            end
        end
    })
end, { desc = "Upload with progress bar and auto-close" })

vim.keymap.set('n', '<leader>er', function()
  local esp_path = get_esp_path()
  vim.cmd("vsplit | term bash -ci 'nodemcu-tool --port " .. esp_path .. " reset && nodemcu-tool terminal'")
end, { desc = "Reset Esp8266 and Terminal" })

vim.keymap.set('n', '<leader>et', function()
  local esp_path = get_esp_path()
  vim.cmd("vsplit | term bash -ci 'nodemcu-tool --port " .. esp_path .. " terminal'")
end, {desc = 'Open [T]erminal'})

vim.keymap.set('n', '<leader>ee', function()
    -- 1. Get clipboard content
    local clipboard = vim.fn.getreg('+')

    -- 2. Find the terminal buffer's channel ID
    -- This assumes you are currently in the terminal or it's the current buffer
    local chan = vim.b.terminal_job_id

    if chan then
        vim.api.nvim_chan_send(chan, clipboard .. "\n")
    else
        print("Not in a terminal buffer!")
    end
end, { desc = '[E]xecute clipboard in terminal' })

require("which-key").add({{'<leader>e', group = '[E]sp8266'}})
