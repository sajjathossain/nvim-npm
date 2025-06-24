---@class Cache
local M = {}

local utils = require('nvim-npm.utils')

---@type table<string, string> Cache of package.json paths
local package_json_cache = {}

---Refresh the package.json cache
---@return boolean Success status
function M.refresh_package_json_cache()
  local root = utils.fs.find_git_root()
  if not root then
    vim.notify("No .git folder found, unable to determine project root", vim.log.levels.ERROR)
    return false
  end

  -- Get all package.json paths
  local package_json_paths = utils.fs.get_all_package_json_paths(root)
  package_json_cache = {}

  for _, path in ipairs(package_json_paths) do
    local relative_path = vim.fn.fnamemodify(path, ":.:h")
    local dir_name = relative_path == "." and "root" or relative_path
    package_json_cache[dir_name] = path
  end

  return true
end

---Get package.json cache
---@return table<string, string> Cache of package.json paths
function M.get_package_json_cache()
  if vim.tbl_isempty(package_json_cache) then
    M.refresh_package_json_cache()
  end
  return package_json_cache
end

---Check if cache is empty
---@return boolean True if cache is empty
function M.is_cache_empty()
  return vim.tbl_isempty(package_json_cache)
end

---Clear the cache
function M.clear_cache()
  package_json_cache = {}
end

---Print cache contents with package manager info (for debugging)
function M.print_cache()
  local cache = M.get_package_json_cache()
  if vim.tbl_isempty(cache) then
    print("Cache is empty")
    return
  end

  print("Package.json cache:")
  for dir_name, path in pairs(cache) do
    local dir = vim.fn.fnamemodify(path, ":h")
    local project_info = utils.ni.get_project_info(dir)
    local manager_info = project_info.package_manager ~= "unknown" 
      and (" (" .. project_info.package_manager .. ")") 
      or ""
    print(string.format("  %s: %s%s", dir_name, path, manager_info))
  end
end

return M
