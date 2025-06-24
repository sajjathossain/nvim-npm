---@class PackageManagerUtils
local M = {}

---@type string Current package manager
local current_package_manager = "npm"

---Detect package manager based on lock files
---@param root_path string Project root path
---@return string Package manager name
function M.detect_package_manager(root_path)
  local lock_files = {
    pnpm = "pnpm-lock.yaml",
    yarn = "yarn.lock", 
    npm = "package-lock.json"
  }

  for manager, lock_file in pairs(lock_files) do
    if vim.fn.filereadable(root_path .. "/" .. lock_file) == 1 then
      current_package_manager = manager
      return manager
    end
  end

  -- Default to npm if no lock file found
  current_package_manager = "npm"
  return "npm"
end

---Get current package manager
---@return string Package manager name
function M.get_current()
  return current_package_manager
end

---Set package manager
---@param manager string Package manager name
function M.set_current(manager)
  current_package_manager = manager
end

---Get install command for current package manager
---@return string Install command
function M.get_install_command()
  local commands = {
    npm = "install",
    yarn = "add",
    pnpm = "add"
  }
  
  return commands[current_package_manager] or "install"
end

---Get run command for current package manager
---@return string Run command
function M.get_run_command()
  return "run"
end

return M
