---@class Utils
local M = {}

local fs = require('nvim-npm.utils.fs')
local package_manager = require('nvim-npm.utils.package-manager')
local terminal = require('nvim-npm.utils.terminal')
local ni = require('nvim-npm.utils.ni')

-- Export utility modules
M.fs = fs
M.package_manager = package_manager
M.terminal = terminal
M.ni = ni

return M
