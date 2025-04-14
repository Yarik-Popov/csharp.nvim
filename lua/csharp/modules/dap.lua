local M = {}
local config_store = require("csharp.config")
local dap = require("dap")
local utils = require("csharp.utils")

function M.get_debug_adapter()
  local config = config_store.get_config().dap

  if config.adapter_name ~= nil then
    return dap.adapters[config.adapter_name]
  end

  local debug_adapter = dap.adapters.coreclr

  if debug_adapter ~= nil then
    return debug_adapter
  end

  local mason = require("mason-registry")
  local package = mason.get_package("netcoredbg")

  if not package:is_installed() then
    package:install()
  end

  -- Netcoredbg puts the executable in a different spot
  local exec_path = {"netcoredbg"}
  if vim.loop.os_uname().sysname == "Windows_NT" then
    exec_path[#exec_path+1] = "netcoredbg.exe"
  end
  
  local path = utils.join_paths(package:get_install_path(), exec_path)

  dap.adapters.coreclr = {
    type = "executable",
    command = path,
    args = {
      "--interpreter=vscode",
    },
  }

  return dap.adapters.coreclr
end

return M
