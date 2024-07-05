local M = {}

--- Set keymap
--- @type function
M._keymap = vim.keymap.set

--- Keymaps
--- @type { t?: table<string, string>, n?: table<string, string> }
M._keymaps = {
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

--- Init keymaps
--- @param opts { mappings?: false | { t?: table<string, string>, n?: table<string, string>  }  }
--- @return nil
M._initKeymaps = function(opts)
  if not opts or opts.mappings ~= false or (opts.mappings and #opts.mappings == 0) then
    return M._setDeafultKeymaps()
  end

  if opts.mappings == false then
    return
  end

  return M._setupMappings(opts.mappings)
end


--- set default keymaps
--- @return nil
M._setDeafultKeymaps = function()
  for mode, mappings in pairs(M._keymaps) do
    for key, value in pairs(mappings) do
      M._keymap(mode, key, value)
    end
  end
end


--- Setup keymaps
--- @param keymaps { t?: table<string, string>, n?: table<string, string> }
--- @return nil
M._setupMappings = function(keymaps)
  for mode, mappings in pairs(keymaps) do
    if not mappings then
      return
    end

    for key, value in pairs(mappings) do
      M._keymap(mode, key, value)
    end
  end
end

return M
