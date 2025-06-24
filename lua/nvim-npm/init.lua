---@class NvimNpm
---@field config Config
local M = {}

local config = require('nvim-npm.config')
local commands = require('nvim-npm.commands')
local keymaps = require('nvim-npm.keymaps')
local api = require('nvim-npm.api')

-- Export API functions
M.exitAllTerminal = api.exit_all_terminals
M.exitTerminal = api.exit_terminal
M.installPackage = api.install_package
M.removePackage = api.remove_package
M.openTerminal = api.open_terminal
M.showScripts = api.show_scripts

---Setup the nvim-npm plugin
---@param opts? Config User configuration options
function M.setup(opts)
  -- Initialize configuration
  config.setup(opts or {})
  
  -- Initialize commands
  commands.setup()
  
  -- Initialize keymaps
  keymaps.setup(config.get().mappings)
end

return M
