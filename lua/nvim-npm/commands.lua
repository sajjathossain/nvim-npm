---@class Commands
local M = {}

local api = require('nvim-npm.api')

---Setup user commands
function M.setup()
  -- Main commands
  vim.api.nvim_create_user_command('ShowScriptsInTelescope', api.show_scripts, {
    desc = 'Show available npm scripts in telescope'
  })
  
  vim.api.nvim_create_user_command('OpenTerminal', api.open_terminal, {
    desc = 'Open terminal selector'
  })
  
  vim.api.nvim_create_user_command('InstallPackage', api.install_package, {
    desc = 'Install npm package in selected project using ni'
  })
  
  vim.api.nvim_create_user_command('RemovePackage', api.remove_package, {
    desc = 'Remove npm package from selected project using ni'
  })
  
  vim.api.nvim_create_user_command('RefreshPackageJsonCache', api.refresh_cache, {
    desc = 'Refresh package.json cache'
  })
  
  -- Terminal management commands
  vim.api.nvim_create_user_command('ExitTerminalSession', api.exit_terminal, {
    desc = 'Exit selected terminal session'
  })
  
  vim.api.nvim_create_user_command('ExitAllTerminalSession', api.exit_all_terminals, {
    desc = 'Exit all terminal sessions'
  })
  
  -- Debug commands
  vim.api.nvim_create_user_command('PrintScripts', api.print_scripts_paths, {
    desc = 'Print package.json scripts paths (debug)'
  })
end

return M
