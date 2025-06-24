---@class TerminalUtils
local M = {}

local ni = require('nvim-npm.utils.ni')

---Get all available terminals
---@return table[]|nil Array of terminal objects or nil if none found
function M.get_all_terminals()
  local ok, terminal = pcall(require, 'toggleterm.terminal')
  if not ok then 
    vim.notify("toggleterm.nvim is required but not found", vim.log.levels.ERROR)
    return nil 
  end
  
  local terminals = terminal.get_all()
  if vim.tbl_isempty(terminals) then
    return nil
  end

  return terminals
end

---Check if terminal exists by display name
---@param display_name string Terminal display name
---@return number|nil Terminal ID if found, nil otherwise
function M.find_terminal_by_name(display_name)
  local terminals = M.get_all_terminals()
  if not terminals then
    return nil
  end

  for _, term in ipairs(terminals) do
    if term.display_name == display_name then
      return term.id
    end
  end

  return nil
end

---Get next available terminal ID
---@return number Next terminal ID
function M.get_next_terminal_id()
  local terminals = M.get_all_terminals()
  if not terminals or #terminals == 0 then
    return 1
  end

  -- Sort terminals by ID and get the highest
  table.sort(terminals, function(a, b) return a.id < b.id end)
  return terminals[#terminals].id + 1
end

---Execute script command in terminal using ni
---@param params { script_name: string, script_command: string, path: string, operation?: string }
function M.execute_command(params)
  local script_name = params.script_name
  local script_command = params.script_command
  local path = params.path
  local operation = params.operation or "run"

  if not script_command or script_command == "" then
    vim.notify("No command provided for script: " .. (script_name or "unknown"), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(path, ":h")
  
  -- Check if project is supported by ni
  if not ni.is_project_supported(dir) then
    vim.notify("Project does not contain package.json", vim.log.levels.ERROR)
    return
  end

  -- Build the command using ni
  local command
  if operation == "run" then
    command = ni.build_run_command(script_command, dir)
  elseif operation == "install" then
    command = ni.build_install_command(script_command, dir)
  elseif operation == "install-dev" then
    command = ni.build_install_command(script_command, dir, true)
  elseif operation == "remove" then
    command = ni.build_remove_command(script_command, dir)
  else
    -- Fallback for custom operations
    command = ni.build_run_command(script_command, dir)
  end

  -- Create terminal display name
  local dir_parts = {}
  for part in dir:gmatch("[^/]+") do
    table.insert(dir_parts, part)
  end
  local last_part = dir_parts[#dir_parts] or "root"
  local display_name = last_part .. "::" .. script_command

  -- Find or create terminal
  local term_id = M.find_terminal_by_name(display_name)
  if not term_id then
    term_id = M.get_next_terminal_id()
  end

  -- Execute the command
  local full_command = string.format(
    "%dTermExec name=%s size=25 direction=float cmd=\"%s\"",
    term_id,
    display_name,
    command
  )

  vim.cmd(full_command)
end

---Install package using ni
---@param package_name string Package name to install
---@param project_path string Path to the project
---@param dev? boolean Install as dev dependency
function M.install_package(package_name, project_path, dev)
  local dir = vim.fn.fnamemodify(project_path, ":h")
  
  if not ni.is_project_supported(dir) then
    vim.notify("Project does not contain package.json", vim.log.levels.ERROR)
    return
  end

  local operation = dev and "install-dev" or "install"
  M.execute_command({
    script_name = "install",
    script_command = package_name,
    path = project_path,
    operation = operation
  })
end

---Remove package using ni
---@param package_name string Package name to remove
---@param project_path string Path to the project
function M.remove_package(package_name, project_path)
  local dir = vim.fn.fnamemodify(project_path, ":h")
  
  if not ni.is_project_supported(dir) then
    vim.notify("Project does not contain package.json", vim.log.levels.ERROR)
    return
  end

  M.execute_command({
    script_name = "remove",
    script_command = package_name,
    path = project_path,
    operation = "remove"
  })
end

---Get project information using ni
---@param project_path string Path to the project
---@return table Project information
function M.get_project_info(project_path)
  local dir = vim.fn.fnamemodify(project_path, ":h")
  return ni.get_project_info(dir)
end

---Close terminal by buffer number
---@param bufnr number Buffer number
---@return boolean Success status
function M.close_terminal_buffer(bufnr)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
    return true
  end
  return false
end

return M
