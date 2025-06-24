---@class Api
local M = {}

local telescope_ui = require('nvim-npm.ui.telescope')
local cache = require('nvim-npm.core.cache')

---Show scripts in telescope
function M.show_scripts()
  telescope_ui.show_projects_with_scripts()
end

---Open terminal selector
function M.open_terminal()
  telescope_ui.open_terminal()
end

---Exit terminal selector
function M.exit_terminal()
  telescope_ui.exit_terminal()
end

---Exit all terminals
function M.exit_all_terminals()
  telescope_ui.exit_all_terminals()
end

---Install package selector
function M.install_package()
  telescope_ui.install_package()
end

---Remove package selector
function M.remove_package()
  telescope_ui.remove_package()
end

---Refresh package.json cache
function M.refresh_cache()
  if cache.refresh_package_json_cache() then
    vim.notify("Package.json cache refreshed", vim.log.levels.INFO)
  else
    vim.notify("Failed to refresh cache", vim.log.levels.ERROR)
  end
end

---Print scripts paths (for debugging)
function M.print_scripts_paths()
  cache.print_cache()
end

return M
