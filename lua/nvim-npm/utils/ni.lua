---@class NiUtils
local M = {}

---Check if ni is installed globally
---@return boolean
function M.is_ni_installed()
  local handle = io.popen("which ni 2>/dev/null")
  if not handle then
    return false
  end
  
  local result = handle:read("*a")
  handle:close()
  
  return result and result:match("%S") ~= nil
end

---Install ni globally if not already installed
---@return boolean success True if ni is available after installation attempt
function M.ensure_ni_installed()
  if M.is_ni_installed() then
    return true
  end

  vim.notify("Installing @antfu/ni globally...", vim.log.levels.INFO, { title = "nvim-npm" })
  
  -- Try to install ni globally using npm
  local install_cmd = "npm install -g @antfu/ni"
  local handle = io.popen(install_cmd .. " 2>&1")
  
  if not handle then
    vim.notify("Failed to execute npm install command", vim.log.levels.ERROR, { title = "nvim-npm" })
    return false
  end
  
  local output = handle:read("*a")
  local success = handle:close()
  
  if success and M.is_ni_installed() then
    vim.notify("Successfully installed @antfu/ni", vim.log.levels.INFO, { title = "nvim-npm" })
    return true
  else
    vim.notify(
      "Failed to install @antfu/ni. Please install manually: npm install -g @antfu/ni\nOutput: " .. (output or ""),
      vim.log.levels.ERROR,
      { title = "nvim-npm" }
    )
    return false
  end
end

---Get the appropriate ni command for the operation
---@param operation string The operation type: "run", "install", "add", "remove"
---@return string command The ni command to use
function M.get_ni_command(operation)
  local commands = {
    run = "nr",      -- ni run
    install = "ni",  -- ni (install)
    add = "ni",      -- ni (add package)
    remove = "nun",  -- ni uninstall
    dev = "nid",     -- ni --dev
    global = "ni -g" -- ni --global
  }
  
  return commands[operation] or "ni"
end

---Execute a script using ni
---@param script_name string Name of the script
---@param project_path string Path to the project directory
---@return string command The full command to execute
function M.build_run_command(script_name, project_path)
  if not M.ensure_ni_installed() then
    -- Fallback to npm if ni installation fails
    vim.notify("Falling back to npm", vim.log.levels.WARN, { title = "nvim-npm" })
    return "npm run " .. script_name
  end
  
  -- Use nr (ni run) for running scripts
  return "cd " .. vim.fn.shellescape(project_path) .. " && nr " .. script_name
end

---Build install command using ni
---@param package_name string Name of the package to install
---@param project_path string Path to the project directory
---@param dev? boolean Whether to install as dev dependency
---@return string command The full command to execute
function M.build_install_command(package_name, project_path, dev)
  if not M.ensure_ni_installed() then
    -- Fallback to npm if ni installation fails
    local npm_cmd = dev and "npm install --save-dev " or "npm install "
    return "cd " .. vim.fn.shellescape(project_path) .. " && " .. npm_cmd .. package_name
  end
  
  local ni_cmd = dev and "nid" or "ni"
  return "cd " .. vim.fn.shellescape(project_path) .. " && " .. ni_cmd .. " " .. package_name
end

---Build remove command using ni
---@param package_name string Name of the package to remove
---@param project_path string Path to the project directory
---@return string command The full command to execute
function M.build_remove_command(package_name, project_path)
  if not M.ensure_ni_installed() then
    -- Fallback to npm if ni installation fails
    return "cd " .. vim.fn.shellescape(project_path) .. " && npm uninstall " .. package_name
  end
  
  return "cd " .. vim.fn.shellescape(project_path) .. " && nun " .. package_name
end

---Get project info using ni
---@param project_path string Path to the project directory
---@return table info Project information including detected package manager
function M.get_project_info(project_path)
  local info = {
    package_manager = "unknown",
    has_lockfile = false,
    lockfile_type = nil
  }
  
  -- Check for lock files to determine package manager
  local lock_files = {
    { file = "pnpm-lock.yaml", manager = "pnpm" },
    { file = "yarn.lock", manager = "yarn" },
    { file = "package-lock.json", manager = "npm" },
    { file = "bun.lockb", manager = "bun" }
  }
  
  for _, lock in ipairs(lock_files) do
    if vim.fn.filereadable(project_path .. "/" .. lock.file) == 1 then
      info.package_manager = lock.manager
      info.has_lockfile = true
      info.lockfile_type = lock.file
      break
    end
  end
  
  return info
end

---Check if ni supports the current project
---@param project_path string Path to the project directory
---@return boolean supported True if ni can handle this project
function M.is_project_supported(project_path)
  -- Check if package.json exists
  if vim.fn.filereadable(project_path .. "/package.json") ~= 1 then
    return false
  end
  
  -- ni supports all major package managers
  return true
end

return M
