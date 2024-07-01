local M = {}
local status_ok_telescope, telescope = pcall(require, 'telescope')
local status_ok_notify, notify = pcall(require, 'notify')
-- local status_ok_term, terminal = pcall(require, 'toggleterm.terminal')
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

  for script_name, _ in pairs(scripts) do
    table.insert(results, { " " .. script_name, script_name, package_json_path })
  end

  table.sort(results, function(a, b) return string.upper(a[2]) < string.upper(b[2]) end)

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
          local script = utils._packageManagerCommand .. " --prefix " .. dir .. " " .. script_command

          local parts = {}
          for part in dir:gmatch("[^/]+") do
            parts[#parts + 1] = part
          end

          local lastPart = parts[#parts]

          local str = lastPart .. "::" .. script_command
          local name = " name=" .. str
          local command = " cmd=" .. "\"" .. script .. "\""

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

          local wholeCommand = exeCommand .. name .. " size=25" .. " direction=float" .. command

          vim.cmd(wholeCommand)
          vim.cmd("startinsert")
        else
          utils._api.nvim_err_writeln("No command found for script: " .. script_name)
        end
      end)
      return true
    end,
  }):find()
end

--- show projects with scripts in telescope
--- @type function
--- @return nil
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

  if #results == 1 then
    return M._showScriptsInPackageJson(results[1][2])
  end

  table.sort(results, function(a, b) return string.upper(a[1]) < string.upper(b[1]) end)

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

--- Select a terminal
--- @param params {attach_mappings: function}
--- @return nil
M._selectTerminal = function(params)
  local terminals = utils._getAllTerminals()
  if not terminals then return notify("No terminals found", "error", { title = "nvim-npm" }) end

  print(vim.inspect(terminals))

  local results = {}
  for _, term in ipairs(terminals) do
    table.insert(results, { term.display_name, term.id })
  end

  table.sort(results, function(a, b) return string.upper(a[1]) < string.upper(b[1]) end)

  pickers.new({}, {
    prompt_title = "Terminals",
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
    attach_mappings = params.attach_mappings,
  }):find()
end

--- Open a terminal
--- @type function
--- @return nil
M._openTerminal = function()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      local term_name = selection.value[1]
      local term_id = selection.value[2]
      if term_id then
        vim.cmd("ToggleTerm " .. term_id)
      else
        utils._api.nvim_err_writeln("No command found for terminal: " .. term_name)
      end
    end)
    return true
  end

  M._selectTerminal({ attach_mappings = attach_mappings })
end


--- Exit a terminal
--- @type function
--- @return nil
M._exitTerminal = function()
  local attach_mappings = function(prompt_bufnr, _)
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      local term_name = selection.value[1]
      local term_id = selection.value[2]
      if term_id then
        vim.cmd(term_id .. "TermExec")
      else
        utils._api.nvim_err_writeln("No command found for terminal: " .. term_name)
      end
    end)
    return true
  end

  M._selectTerminal({ attach_mappings = attach_mappings })
end

--- Exit all terminals
--- @type function
--- @return nil
M._exitAllTerminals = function()
  local terminals = utils._getAllTerminals()
  if not terminals then return notify("No terminals found", "error", { title = "nvim-npm" }) end
  for _, term in ipairs(terminals) do
    vim.cmd("ToggleTerm " .. term.id)
    vim.cmd(term.id .. "TermExec" .. " cmd=exit")
  end
end

return M
