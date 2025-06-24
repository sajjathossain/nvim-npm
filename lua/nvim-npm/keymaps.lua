---@class Keymaps
local M = {}

---Setup keymaps based on configuration
---@param mappings_config false | { t?: table<string, string>, n?: table<string, string> }
function M.setup(mappings_config)
  -- If mappings are disabled, return early
  if mappings_config == false then
    return
  end

  -- If no mappings config provided, don't set any keymaps
  if not mappings_config or vim.tbl_isempty(mappings_config) then
    return
  end

  -- Set keymaps for each mode
  for mode, mappings in pairs(mappings_config) do
    if mappings and type(mappings) == "table" then
      for key, command in pairs(mappings) do
        vim.keymap.set(mode, key, command, {
          desc = M.get_keymap_description(command),
          silent = true,
          noremap = true
        })
      end
    end
  end
end

---Get description for keymap based on command
---@param command string The command string
---@return string Description
function M.get_keymap_description(command)
  local descriptions = {
    ["<cmd>ShowScriptsInTelescope<cr>"] = "Show npm scripts",
    ["<cmd>OpenTerminal<cr>"] = "Open terminal",
    ["<cmd>InstallPackage<cr>"] = "Install package",
    ["<cmd>RefreshPackageJsonCache<cr>"] = "Refresh cache",
    ["<C-\\><C-n>"] = "Exit terminal mode"
  }
  
  return descriptions[command] or "nvim-npm keymap"
end

return M
