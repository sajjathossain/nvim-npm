-- nvim-npm plugin initialization
-- This file is automatically loaded by Neovim

if vim.g.loaded_nvim_npm then
  return
end
vim.g.loaded_nvim_npm = 1

-- Ensure required dependencies are available
local function check_dependencies()
  local missing_deps = {}
  
  local deps = {
    'telescope',
    'toggleterm'
  }
  
  for _, dep in ipairs(deps) do
    local ok, _ = pcall(require, dep)
    if not ok then
      table.insert(missing_deps, dep .. '.nvim')
    end
  end
  
  if #missing_deps > 0 then
    vim.notify(
      'nvim-npm: Missing required dependencies: ' .. table.concat(missing_deps, ', '),
      vim.log.levels.ERROR
    )
    return false
  end
  
  return true
end

-- Only proceed if dependencies are available
if check_dependencies() then
  -- Plugin is ready to be used
  vim.g.nvim_npm_loaded = 1
end
