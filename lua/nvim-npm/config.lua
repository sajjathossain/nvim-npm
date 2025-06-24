---@class Config
---@field mappings false | { t?: table<string, string>, n?: table<string, string> }

---@class ConfigModule
local M = {}

---@type Config
local default_config = {
  mappings = {
    t = {
      ["<esc><esc>"] = "<C-\\><C-n>",
    },
    n = {
      [";pl"] = "<cmd>ShowScriptsInTelescope<cr>",
      [";po"] = "<cmd>OpenTerminal<cr>",
      [";pi"] = "<cmd>InstallPackage<cr>",
      [";pr"] = "<cmd>RefreshPackageJsonCache<cr>",
    }
  }
}

---@type Config
local config = {}

---Setup configuration
---@param user_config Config
function M.setup(user_config)
  config = vim.tbl_deep_extend('force', default_config, user_config)
end

---Get current configuration
---@return Config
function M.get()
  return config
end

---Get default configuration
---@return Config
function M.get_default()
  return default_config
end

return M
