---@class Health
local M = {}

local health = vim.health or require('health')

---Check health of nvim-npm plugin
function M.check()
  health.start('nvim-npm')
  
  -- Check required dependencies
  M.check_dependencies()
  
  -- Check optional dependencies
  M.check_optional_dependencies()
  
  -- Check ni installation
  M.check_ni_installation()
  
  -- Check configuration
  M.check_configuration()
  
  -- Check project setup
  M.check_project_setup()
end

---Check required dependencies
function M.check_dependencies()
  -- Check telescope
  local telescope_ok, _ = pcall(require, 'telescope')
  if telescope_ok then
    health.ok('telescope.nvim is installed')
  else
    health.error('telescope.nvim is required but not found')
  end
  
  -- Check toggleterm
  local toggleterm_ok, _ = pcall(require, 'toggleterm')
  if toggleterm_ok then
    health.ok('toggleterm.nvim is installed')
  else
    health.error('toggleterm.nvim is required but not found')
  end
end

---Check optional dependencies
function M.check_optional_dependencies()
  -- Check nvim-notify
  local notify_ok, _ = pcall(require, 'notify')
  if notify_ok then
    health.ok('nvim-notify is installed (optional)')
  else
    health.info('nvim-notify not found (optional, will use vim.notify)')
  end
end

---Check ni installation and functionality
function M.check_ni_installation()
  local ni = require('nvim-npm.utils.ni')
  
  if ni.is_ni_installed() then
    health.ok('@antfu/ni is installed globally')
    
    -- Check if ni commands are available
    local commands = { 'ni', 'nr', 'nun', 'nid' }
    local missing_commands = {}
    
    for _, cmd in ipairs(commands) do
      local handle = io.popen("which " .. cmd .. " 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        if not result or result:match("%S") == nil then
          table.insert(missing_commands, cmd)
        end
      else
        table.insert(missing_commands, cmd)
      end
    end
    
    if #missing_commands == 0 then
      health.ok('All ni commands are available (ni, nr, nun, nid)')
    else
      health.warn('Some ni commands are missing: ' .. table.concat(missing_commands, ', '))
    end
  else
    health.warn('@antfu/ni is not installed globally')
    health.info('Run: npm install -g @antfu/ni')
    health.info('Plugin will attempt to install ni automatically when needed')
  end
end

---Check configuration
function M.check_configuration()
  local config = require('nvim-npm.config')
  local current_config = config.get()
  
  if current_config then
    health.ok('Configuration loaded successfully')
    
    -- Check mappings
    if current_config.mappings == false then
      health.info('Keymaps are disabled')
    elseif current_config.mappings then
      health.ok('Keymaps are configured')
    end
  else
    health.warn('Configuration not found, using defaults')
  end
end

---Check project setup
function M.check_project_setup()
  local utils = require('nvim-npm.utils')
  local cache = require('nvim-npm.core.cache')
  
  -- Check git root
  local git_root = utils.fs.find_git_root()
  if git_root then
    health.ok('Git repository found: ' .. git_root)
    
    -- Check package.json files
    local package_cache = cache.get_package_json_cache()
    if not vim.tbl_isempty(package_cache) then
      local count = 0
      for _ in pairs(package_cache) do
        count = count + 1
      end
      health.ok(string.format('Found %d package.json file(s) with scripts', count))
      
      -- Check project compatibility with ni
      local compatible_projects = 0
      for _, path in pairs(package_cache) do
        if utils.ni.is_project_supported(vim.fn.fnamemodify(path, ":h")) then
          compatible_projects = compatible_projects + 1
        end
      end
      
      if compatible_projects == count then
        health.ok('All projects are compatible with ni')
      else
        health.warn(string.format('%d/%d projects are compatible with ni', compatible_projects, count))
      end
      
      -- Show detected package managers
      local managers = {}
      for dir_name, path in pairs(package_cache) do
        local project_info = utils.ni.get_project_info(vim.fn.fnamemodify(path, ":h"))
        if project_info.package_manager ~= "unknown" then
          managers[project_info.package_manager] = (managers[project_info.package_manager] or 0) + 1
        end
      end
      
      if next(managers) then
        local manager_list = {}
        for manager, count_val in pairs(managers) do
          table.insert(manager_list, string.format('%s (%d)', manager, count_val))
        end
        health.ok('Detected package managers: ' .. table.concat(manager_list, ', '))
      end
    else
      health.warn('No package.json files with scripts found')
    end
  else
    health.warn('Not in a git repository')
  end
end

return M
