local M = {}
local utils = require('nvim-npm.utils')
local telescope = require('nvim-npm.telescope')

--- init commands
--- @return nil
M._intiCommands = function()
  utils._api.nvim_create_user_command('PrintScripts', utils._printScriptsPaths, {})
  utils._api.nvim_create_user_command('ShowScriptsInTelescope', telescope._showScriptsInTelescope, {})
  utils._api.nvim_create_user_command('RefreshPackageJsonCache', utils._refreshPackageJsonCache, {})
end

return M
