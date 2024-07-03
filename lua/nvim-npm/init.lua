local commands = require('nvim-npm.commands')
local keymaps = require('nvim-npm.keymaps')
local telescope = require('nvim-npm.telescope')

local M = {}

M.exitAllTerminal = telescope._exitAllTerminals
M.exitTerminal = telescope._exitTerminal
M.InstallPackage = telescope._installPackage
M.openTerminal = telescope._openTerminal
M.showScripts = telescope._showProjectsWithScriptsInTelescope

-- setup function
--- @type function
--- @param opts? {mappings?: false  | {t?: table<string, string>, n?: table<string, string>} }
--- @return nil
M.setup = function(opts)
  commands._intiCommands()
  keymaps._initKeymaps(opts or {})
end

return M
