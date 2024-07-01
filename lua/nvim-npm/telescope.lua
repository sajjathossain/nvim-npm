local M = {}
local status_ok_telescope, telescope = pcall(require, 'telescope')
local status_ok_notify, notify = pcall(require, 'notify')
if not status_ok_telescope or not status_ok_notify then return end
telescope.setup {}

local utils = require('nvim-npm.utils')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

M._showScriptsInPackageJson = function(package_json_path)
  local package_json_content = utils._readFile(package_json_path)
  if not package_json_content then return end

  local json = utils._fn.json_decode(package_json_content)
  local scripts = json.scripts or {}

  local results = {}

  --[[ for script_name, script_command in pairs(scripts) do
    table.insert(results, { " " .. script_name .. "  " .. script_command, script_command, package_json_path })
  end ]]


  for script_name, _ in pairs(scripts) do
    table.insert(results, { " " .. script_name, script_name, package_json_path })
  end

  pickers.new({}, {
    prompt_title = "Scripts in " .. package_json_path,
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],
          ordinal = entry[1],
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local script_name = selection.value[1]
        local script_command = selection.value[2]
        local path = selection.value[3]
        if script_command then
          local dir = utils._fn.fnamemodify(path, ":h")
          local script = utils._packageManagerCommand .. " " .. script_command

          local parts = {}
          for part in dir:gmatch("[^/]+") do
            parts[#parts + 1] = part
          end

          local lastPart = parts[#parts]

          local str = lastPart .. "::" .. script_command
          local name = " name=" .. str
          local command = " cmd=" .. "\"" .. script .. "\""
          local directory = " dir=" .. dir

          local exeCommand = nil
          for _, value in ipairs(utils._terminalIndex) do
            local objDir = value[1]
            local objCommand = value[2]
            if objDir == str then
              exeCommand = objCommand
              break
            end
          end

          if exeCommand == nil then
            local newKey = tostring(#utils._terminalIndex + 1) .. "TermExec"
            table.insert(utils._terminalIndex, { str, newKey })
            exeCommand = newKey
          end

          vim.cmd(exeCommand .. name .. directory .. " size=25" .. " direction=float" .. command)
        else
          utils._api.nvim_err_writeln("No command found for script: " .. script_name)
        end
      end)
      return true
    end,
  }):find()
end

M._showProjectsWithScriptsInTelescope = function()
  if vim.tbl_isempty(utils._packageJsonCache) then
    utils._refreshPackageJsonCache()
  end

  if vim.tbl_isempty(utils._packageJsonCache) then
    return notify("No scripts found in the project", "error", { title = "nvim-npm" })
  end

  local results = {}
  for dir_name, path in pairs(utils._packageJsonCache) do
    table.insert(results, { dir_name, path })
  end

  pickers.new({}, {
    prompt_title = "Package.json Script Paths",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],
          ordinal = entry[1],
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M._showScriptsInPackageJson(selection.value[2])
      end)
      return true
    end,
  }):find()
end

return M
