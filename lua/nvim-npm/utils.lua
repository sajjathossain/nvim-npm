local M = {}
M._vim = vim
M._api = M._vim.api
M._fn = M._vim.fn
M._json = M._vim.fn.json_decode
M._packageJsonCache = {}
M._packageManagerCommand = "npm run"
--[[ local status_ok_lfs, lfs = pcall(require, "lfs")

if not status_ok_lfs then return {} end ]]

M._print = print

M._setPackageManager = function(root)
  local commands = {
    ["pnpm run"] = M._fn.filereadable(root .. "/pnpm-lock.yaml") == 1,
    ["yarn"] = M._fn.filereadable(root .. "/yarn.lock") == 1,
    ["npm run"] = M._fn.filereadable(root .. "/package-lock.json") == 1,
  }

  for key, command in pairs(commands) do
    if command then
      M._packageManagerCommand = key
      return
    end
  end
end

M._refreshPackageJsonCache = function()
  local root = M._findGitRoot()
  if not root then
    M._api.nvim_err_writeln("No .git folder found, unable to determine project root")
    return nil
  end

  M._setPackageManager(root)

  local package_json_paths = M._getAllPackageJsonPaths(root)
  M._packageJsonCache = {}

  for _, path in ipairs(package_json_paths) do
    local relative_path = M._fn.fnamemodify(path, ":.:h")
    local dir_name = relative_path == "." and "root" or relative_path
    M._packageJsonCache[dir_name] = path
  end
end


M._findGitRoot = function()
  local path = M._fn.expand('%:p:h')
  while path and path ~= '/' do
    if M._fn.isdirectory(path .. '/.git') == 1 then
      return path
    end
    path = M._fn.fnamemodify(path, ':h')
  end
  return nil
end

M._readFile = function(file_path)
  local file = io.open(file_path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

M._hasScripts = function(package_json_path)
  local package_json_content = M._readFile(package_json_path)
  if not package_json_content then
    return false
  end

  local json = M._fn.json_decode(package_json_content)
  return json.scripts ~= nil
end


M._getAllPackageJsonPaths = function(dir)
  local package_json_paths = {}

  local function traverseDirectory(current_dir)
    local dirs = M._fn.readdir(current_dir) or {}
    for _, entry in ipairs(dirs) do
      local full_path = current_dir .. "/" .. entry
      local is_dir = M._fn.isdirectory(full_path) == 1
      local is_file = M._fn.isdirectory(full_path) == 0

      if is_dir then
        if entry ~= "node_modules" then
          traverseDirectory(full_path)
        end
      elseif is_file and entry == "package.json" and M._hasScripts(full_path) then
        table.insert(package_json_paths, full_path)
      end
    end
  end

  traverseDirectory(dir)
  return package_json_paths
end

M._getPackageJsonScriptsPaths = function()
  if vim.tbl_isempty(M._packageJsonCache) then
    M._refreshPackageJsonCache()
  end

  return M._packageJsonCache
end

M._getAllTerminals = function()
  local status_ok_term, terminal = pcall(require, 'toggleterm.terminal')
  if not status_ok_term then return nil end
  local terminals = terminal.get_all()
  if vim.tbl_isempty(terminals) then
    return nil
  end

  return terminals
end

--- @type function
M._printScriptsPaths = function()
  local scripts_paths = M._getPackageJsonScriptsPaths()
  if scripts_paths then
    for dir_name, path in pairs(scripts_paths) do
      M._print(dir_name .. ": " .. path .. "\n")
    end
  end
end

return M
