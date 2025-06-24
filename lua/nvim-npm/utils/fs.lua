---@class FsUtils
local M = {}

---Find the git root directory
---@return string|nil Git root path or nil if not found
function M.find_git_root()
  local path = vim.fn.expand('%:p:h')
  
  while path and path ~= '/' do
    if vim.fn.isdirectory(path .. '/.git') == 1 then
      return path
    end
    path = vim.fn.fnamemodify(path, ':h')
  end
  
  return nil
end

---Read file content
---@param file_path string Path to the file
---@return string|nil File content or nil if failed
function M.read_file(file_path)
  local file = io.open(file_path, "r")
  if not file then 
    return nil 
  end
  
  local content = file:read("*a")
  file:close()
  return content
end

---Check if package.json has scripts
---@param package_json_path string Path to package.json
---@return boolean True if has scripts, false otherwise
function M.has_scripts(package_json_path)
  local content = M.read_file(package_json_path)
  if not content then
    return false
  end

  local ok, json = pcall(vim.fn.json_decode, content)
  if not ok then
    return false
  end

  return json.scripts ~= nil and next(json.scripts) ~= nil
end

---Get all package.json paths recursively
---@param dir string Directory to search
---@return string[] Array of package.json paths
function M.get_all_package_json_paths(dir)
  local package_json_paths = {}

  local function traverse_directory(current_dir)
    local entries = vim.fn.readdir(current_dir) or {}
    
    for _, entry in ipairs(entries) do
      local full_path = current_dir .. "/" .. entry
      local is_dir = vim.fn.isdirectory(full_path) == 1
      local is_file = vim.fn.isdirectory(full_path) == 0

      if is_dir then
        -- Skip node_modules and other common directories to ignore
        if entry ~= "node_modules" and entry ~= ".git" and entry ~= ".next" and entry ~= "dist" and entry ~= "build" then
          traverse_directory(full_path)
        end
      elseif is_file and entry == "package.json" and M.has_scripts(full_path) then
        table.insert(package_json_paths, full_path)
      end
    end
  end

  traverse_directory(dir)
  return package_json_paths
end

---Get scripts from package.json
---@param package_json_path string Path to package.json
---@return table<string, string>|nil Scripts object or nil if failed
function M.get_package_scripts(package_json_path)
  local content = M.read_file(package_json_path)
  if not content then
    return nil
  end

  local ok, json = pcall(vim.fn.json_decode, content)
  if not ok or not json.scripts then
    return nil
  end

  return json.scripts
end

return M
