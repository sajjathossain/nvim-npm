---@class TelescopeUI
local M = {}

-- Check for required dependencies
local telescope_ok, telescope = pcall(require, 'telescope')
local notify_ok, notify = pcall(require, 'notify')

if not telescope_ok then
  vim.notify("telescope.nvim is required but not found", vim.log.levels.ERROR)
  return {}
end

if not notify_ok then
  -- Fallback to vim.notify if nvim-notify is not available
  notify = vim.notify
end

-- Initialize telescope
telescope.setup({})

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local cache = require('nvim-npm.core.cache')
local utils = require('nvim-npm.utils')

---Show scripts for a specific package.json
---@param package_json_path string Path to package.json
function M.show_scripts_in_package_json(package_json_path)
  local scripts = utils.fs.get_package_scripts(package_json_path)
  if not scripts then
    notify("No scripts found in " .. package_json_path, vim.log.levels.WARN)
    return
  end

  local results = {}
  for script_name, script_command in pairs(scripts) do
    table.insert(results, {
      display = " " .. script_name,
      name = script_name,
      command = script_command,
      path = package_json_path
    })
  end

  -- Sort results alphabetically
  table.sort(results, function(a, b) 
    return string.upper(a.name) < string.upper(b.name) 
  end)

  pickers.new({}, {
    prompt_title = "Scripts in " .. vim.fn.fnamemodify(package_json_path, ":h"),
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        
        utils.terminal.execute_command({
          script_name = selection.value.name,
          script_command = selection.value.name, -- Use script name for ni
          path = selection.value.path,
          operation = "run"
        })
      end)
      return true
    end
  }):find()
end

---Show projects with package.json files
---@param params { attach_mappings: function, operation?: string }
function M.show_projects(params)
  local package_cache = cache.get_package_json_cache()
  
  if vim.tbl_isempty(package_cache) then
    notify("No scripts found in the project", vim.log.levels.WARN, { title = "nvim-npm" })
    return
  end

  local results = {}
  for dir_name, path in pairs(package_cache) do
    -- Get project info using ni
    local project_info = utils.terminal.get_project_info(path)
    table.insert(results, { 
      dir_name, 
      path, 
      project_info.package_manager or "unknown"
    })
  end

  -- If only one project and not installing packages, show scripts directly
  if #results == 1 and not params.operation then
    return M.show_scripts_in_package_json(results[1][2])
  end

  -- Sort results alphabetically
  table.sort(results, function(a, b) 
    return string.upper(a[1]) < string.upper(b[1]) 
  end)

  pickers.new({}, {
    prompt_title = "Package.json Projects",
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        local display = entry[1]
        if entry[3] and entry[3] ~= "unknown" then
          display = display .. " (" .. entry[3] .. ")"
        end
        return {
          value = entry,
          display = display,
          ordinal = entry[1],
        }
      end,
    }),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = params.attach_mappings,
  }):find()
end

---Show projects with scripts in telescope
function M.show_projects_with_scripts()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      M.show_scripts_in_package_json(selection.value[2])
    end)
    return true
  end

  M.show_projects({ attach_mappings = attach_mappings })
end

---Select a terminal from available terminals
---@param params { attach_mappings: function }
function M.select_terminal(params)
  local terminals = utils.terminal.get_all_terminals()
  if not terminals then 
    notify("No terminals found", vim.log.levels.WARN, { title = "nvim-npm" })
    return 
  end

  local results = {}
  for _, term in ipairs(terminals) do
    table.insert(results, {
      display_name = term.display_name or ("Terminal " .. term.id),
      id = term.id,
      bufnr = term.bufnr
    })
  end

  -- Sort results alphabetically
  table.sort(results, function(a, b) 
    return string.upper(a.display_name) < string.upper(b.display_name) 
  end)

  pickers.new({}, {
    prompt_title = "Terminals",
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display_name,
          ordinal = entry.display_name,
        }
      end,
    }),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = params.attach_mappings,
  }):find()
end

---Open terminal selector
function M.open_terminal()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      
      local term_id = selection.value.id
      if term_id then
        vim.cmd("ToggleTerm " .. term_id)
      else
        notify("Invalid terminal selected", vim.log.levels.ERROR)
      end
    end)
    return true
  end

  M.select_terminal({ attach_mappings = attach_mappings })
end

---Exit terminal selector
function M.exit_terminal()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      
      local term_bufnr = selection.value.bufnr
      if utils.terminal.close_terminal_buffer(term_bufnr) then
        notify("Terminal closed", vim.log.levels.INFO)
      else
        notify("Failed to close terminal", vim.log.levels.ERROR)
      end
    end)
    return true
  end

  M.select_terminal({ attach_mappings = attach_mappings })
end

---Exit all terminals
function M.exit_all_terminals()
  local terminals = utils.terminal.get_all_terminals()
  if not terminals then 
    notify("No terminals found", vim.log.levels.WARN, { title = "nvim-npm" })
    return 
  end
  
  local closed_count = 0
  for _, term in ipairs(terminals) do
    if utils.terminal.close_terminal_buffer(term.bufnr) then
      closed_count = closed_count + 1
    end
  end
  
  notify(string.format("Closed %d terminal(s)", closed_count), vim.log.levels.INFO)
end

---Install package selector
function M.install_package()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      
      -- Get package name from user
      local package_name = vim.fn.input("Enter package name: ")
      if package_name == "" then
        notify("Package installation cancelled", vim.log.levels.INFO)
        return
      end
      
      -- Ask if it should be a dev dependency
      local is_dev = vim.fn.confirm("Install as dev dependency?", "&Yes\n&No", 2) == 1
      
      utils.terminal.install_package(package_name, selection.value[2], is_dev)
    end)
    return true
  end

  M.show_projects({ 
    attach_mappings = attach_mappings, 
    operation = "install" 
  })
end

---Remove package selector
function M.remove_package()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      
      -- Get package name from user
      local package_name = vim.fn.input("Enter package name to remove: ")
      if package_name == "" then
        notify("Package removal cancelled", vim.log.levels.INFO)
        return
      end
      
      utils.terminal.remove_package(package_name, selection.value[2])
    end)
    return true
  end

  M.show_projects({ 
    attach_mappings = attach_mappings, 
    operation = "remove" 
  })
end

return M
