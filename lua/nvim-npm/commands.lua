local M = {}
local utils = require('nvim-npm.utils')
local telescope = require('nvim-npm.telescope')

--- init commands
--- @return nil
M._intiCommands = function()
  utils._api.nvim_create_user_command('PrintScripts', utils._printScriptsPaths, {})
  utils._api.nvim_create_user_command('ShowScriptsInTelescope', telescope._showProjectsWithScriptsInTelescope, {})
  utils._api.nvim_create_user_command('RefreshPackageJsonCache', utils._refreshPackageJsonCache, {})
  utils._api.nvim_create_user_command('OpenTerminal', telescope._openTerminal, {})
  utils._api.nvim_create_user_command('ExitTerminalSession', telescope._exitTerminal, {})
  utils._api.nvim_create_user_command('ExitAllTerminalSession', telescope._exitAllTerminals, {})
  utils._api.nvim_create_user_command('InstallPackage', telescope._installPackage, {})
end

return M
