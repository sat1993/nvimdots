-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
-- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
return function()
	local dap = require("dap")
	local utils = require("modules.utils.dap")

	local function is_empty(s)
		return s == nil or s == ""
	end
	local function get_python_path()
		local cwd, venv = vim.fn.getcwd(), os.getenv("VIRTUAL_ENV")
		if venv and vim.fn.executable(venv .. "\\Scripts\\python.exe") == 1 then
			return venv .. "\\Scripts\\python.exe"
		elseif venv and vim.fn.executable(venv .. "/bin/python") == 1 then
			return venv .. "/bin/python"
		elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
			return cwd .. "/venv/bin/python"
		elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
			return cwd .. "/.venv/bin/python"
		else
			return "python3"
		end
	end

	dap.adapters.python = function(callback, config)
		if config.request == "attach" then
			local port = (config.connect or config).port
			local host = (config.connect or config).host or "127.0.0.1"
			callback({
				type = "server",
				port = assert(port, "`connect.port` is required for a python `attach` configuration"),
				host = host,
				options = { source_filetype = "python" },
			})
		else
			callback({
				type = "executable",
				command = get_python_path(),
				args = { "-m", "debugpy.adapter" },
				options = { source_filetype = "python" },
				detached = true,
			})
		end
	end
	dap.configurations.python = {
		{
			-- NOTE: This setting is for people using venv
			type = "python",
			request = "launch",
			name = "Debug (using venv)",
			-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
			console = "integratedTerminal",
			program = utils.input_file_path(),
			pythonPath = get_python_path(),
		},
	}
end
