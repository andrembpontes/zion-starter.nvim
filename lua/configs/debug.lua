local M = {}

local wrapped_cache = setmetatable({}, { __mode = "k" })
local wrapped_reverse = setmetatable({}, { __mode = "k" })

local ctx = {
	file = nil,
	ft = nil,
	phase = nil,
}


local function log_path()
	local p = vim.env.NVIM_DEBUG_LOG
	if p == nil or p == "" then
		return nil
	end
	return p
end

local function log_lines(lines)
	local p = log_path()
	if p == nil then
		return
	end
	-- Best-effort logging; never break startup because of logging.
	pcall(vim.fn.writefile, lines, p, "a")
end

local function log_line(line)
	log_lines({ line })
end

local function sanitize(v)
	local s = tostring(v)
	-- Keep logs single-line and terminal-safe.
	-- Use %z for NUL (LuaJIT treats literal NUL poorly in patterns).
	s = s:gsub("%z", "\\0")
	s = s:gsub("\r", "\\r")
	s = s:gsub("\n", "\\n")
	return s
end

local function ctx_prefix()
	local parts = {}
	if ctx.phase ~= nil then
		parts[#parts + 1] = "phase=" .. ctx.phase
	end
	if ctx.file ~= nil then
		parts[#parts + 1] = "file=" .. ctx.file
	end
	if ctx.ft ~= nil then
		parts[#parts + 1] = "ft=" .. ctx.ft
	end
	if #parts == 0 then
		return ""
	end
	return " " .. table.concat(parts, " ")
end

local function is_callable(v)
	local t = type(v)
	if t == "function" then
		return true
	end
	if t == "table" or t == "userdata" then
		local mt = getmetatable(v)
		return mt ~= nil and type(mt.__call) == "function"
	end
	return false
end

local function mark_wrapped(original, wrapper)
	wrapped_cache[original] = wrapper
	wrapped_reverse[wrapper] = original
	return wrapper
end

local function already_wrapped(v)
	return wrapped_reverse[v] ~= nil
end


local function wrap(original)
	return function(msg, level, opts)
		if vim.g._nvim_debug_in_notify then
			return original(msg, level, opts)
		end
		vim.g._nvim_debug_in_notify = true

		local ok_inspect, inspect = pcall(require, "vim.inspect")
		local level_s = level ~= nil and tostring(level) or "nil"
		local opts_s = ok_inspect and inspect(opts) or tostring(opts)
		local title_s = ""
		if type(opts) == "table" and opts.title ~= nil then
			title_s = " title=" .. tostring(opts.title)
		end

		local header = ("[nvim-debug notify]%s level=%s%s msg=%s opts=%s"):format(
			ctx_prefix(),
			level_s,
			title_s,
			sanitize(msg),
			opts_s
		)

		if vim.env.NVIM_DEBUG_BYTES == "1" and type(msg) == "string" then
			local has_null = msg:find("\0", 1, true) ~= nil
			local b = { msg:byte(1, math.min(#msg, 32)) }
			local line = "[nvim-debug bytes] has_null="
				.. tostring(has_null)
				.. " len="
				.. tostring(#msg)
				.. " first="
				.. table.concat(b, ",")
			vim.api.nvim_out_write(line .. "\n")
			log_line(line)
		end

		vim.api.nvim_out_write(header .. "\n")
		log_line(header)

		local tb = debug.traceback("[nvim-debug notify traceback]", 2)
		vim.api.nvim_out_write(tb .. "\n")
		log_lines(vim.split(tb, "\n", { plain = true }))

		local ok, ret = pcall(original, msg, level, opts)
		vim.g._nvim_debug_in_notify = false
		if not ok then
			local err = "[nvim-debug notify error] " .. tostring(ret)
			vim.api.nvim_out_write(err .. "\n")
			log_line(err)
			return
		end
		return ret
	end
end

local function wrap_value(v)
	if v == nil then
		return v
	end
	if already_wrapped(v) then
		return v
	end
	local cached = wrapped_cache[v]
	if cached ~= nil then
		return cached
	end

	local t = type(v)
	if t == "function" then
		return mark_wrapped(v, wrap(v))
	end

	if (t == "table" or t == "userdata") and is_callable(v) then
		local call_wrapper = wrap(v)
		local proxy = {}
		setmetatable(proxy, {
			__index = v,
			__call = function(_, ...)
				return call_wrapper(...)
			end,
		})
		-- Also wrap `.notify` if present.
		local maybe_notify = rawget(v, "notify")
		if type(maybe_notify) == "function" then
			proxy.notify = mark_wrapped(maybe_notify, wrap(maybe_notify))
		end
		return mark_wrapped(v, proxy)
	end

	return v
end

local function trap_vim_notify_assignments()
	if vim.g._nvim_debug_notify_trap_installed then
		return
	end
	vim.g._nvim_debug_notify_trap_installed = true

	local mt = getmetatable(vim) or {}
	local orig_newindex = mt.__newindex

	mt.__newindex = function(t, k, v)
		if k == "notify" then
			rawset(t, k, wrap_value(v))
			return
		end
		if type(orig_newindex) == "function" then
			return orig_newindex(t, k, v)
		end
		if type(orig_newindex) == "table" then
			orig_newindex[k] = v
			return
		end
		rawset(t, k, v)
	end

	setmetatable(vim, mt)
	-- Ensure current `vim.notify` is wrapped.
	rawset(vim, "notify", wrap_value(vim.notify))
end

local function get_notify_history()
	local ok, mod = pcall(require, "notify")
	if not ok or mod == nil then
		return nil
	end
	if type(mod.history) ~= "function" then
		return nil
	end
	local ok_hist, hist = pcall(mod.history, { include_hidden = true })
	if not ok_hist or type(hist) ~= "table" then
		return nil
	end
	return hist
end

local function format_notify_record(r)
	local lvl = r.level ~= nil and tostring(r.level) or "?"
	local title = ""
	if type(r.title) == "table" then
		title = table.concat(r.title, "")
	elseif r.title ~= nil then
		title = tostring(r.title)
	end
	local msg = ""
	if type(r.message) == "table" then
		msg = table.concat(r.message, "\\n")
	elseif r.message ~= nil then
		msg = tostring(r.message)
	end
	local time_s = r.time ~= nil and tostring(r.time) or ""
	local head = ("[nvim-debug notify-history]%s idx=%s time=%s level=%s title=%s"):format(
		ctx_prefix(),
		tostring(r.id or "?"),
		time_s,
		lvl,
		sanitize(title)
	)
	return head .. " msg=" .. sanitize(msg)
end

local function ensure_wrapped()
	trap_vim_notify_assignments()
	local current = vim.notify
	if current == nil then
		return
	end

	local existing = vim.g._nvim_debug_notify_wrapper
	if type(existing) == "function" and current == existing then
		return
	end

	local wrapper = wrap_value(current)
	vim.g._nvim_debug_notify_wrapper = wrapper
	vim.notify = wrapper

	-- Many plugins call `require("notify")("msg")` directly.
	local ok_notify, notify_mod = pcall(require, "notify")
	if ok_notify and notify_mod ~= nil then
		local original_mod = wrapped_reverse[notify_mod] or notify_mod
		if type(original_mod) == "table" and not original_mod.__nvim_debug_patched then
			original_mod.__nvim_debug_patched = true
			if type(original_mod.notify) == "function" then
				original_mod.notify = mark_wrapped(original_mod.notify, wrap(original_mod.notify))
			end
			if type(original_mod.async) == "function" then
				original_mod.async = mark_wrapped(original_mod.async, wrap(original_mod.async))
			end
		end

		local wrapped = wrap_value(original_mod)
		vim.g._nvim_debug_notify_module_wrapper = wrapped
		package.loaded["notify"] = wrapped
	end
end

local function ensure_echo_wrapped()
	if vim.g._nvim_debug_echo_wrapped then
		return
	end
	vim.g._nvim_debug_echo_wrapped = true

	local orig_echo = vim.api.nvim_echo
	vim.api.nvim_echo = function(chunks, history, opts)
		local ok_inspect, inspect = pcall(require, "vim.inspect")
		local payload = ok_inspect and inspect(chunks) or tostring(chunks)
		local header = "[nvim-debug echo] " .. payload
		vim.api.nvim_out_write(header .. "\n")
		log_line(header)
		local tb = debug.traceback("[nvim-debug echo traceback]", 2)
		vim.api.nvim_out_write(tb .. "\n")
		log_lines(vim.split(tb, "\n", { plain = true }))
		return orig_echo(chunks, history, opts)
	end

	local orig_err = vim.api.nvim_err_writeln
	vim.api.nvim_err_writeln = function(msg)
		local header = "[nvim-debug err_writeln] " .. tostring(msg)
		vim.api.nvim_out_write(header .. "\n")
		log_line(header)
		local tb = debug.traceback("[nvim-debug err_writeln traceback]", 2)
		vim.api.nvim_out_write(tb .. "\n")
		log_lines(vim.split(tb, "\n", { plain = true }))
		return orig_err(msg)
	end

	local orig_notify = vim.api.nvim_notify
	if type(orig_notify) == "function" then
		vim.api.nvim_notify = function(msg, level, opts)
			local header = ("[nvim-debug nvim_notify] level=%s msg=%s"):format(tostring(level), tostring(msg))
			vim.api.nvim_out_write(header .. "\n")
			log_line(header)
			local tb = debug.traceback("[nvim-debug nvim_notify traceback]", 2)
			vim.api.nvim_out_write(tb .. "\n")
			log_lines(vim.split(tb, "\n", { plain = true }))
			return orig_notify(msg, level, opts)
		end
	end
end

function M.dump_messages()
	local ok, out = pcall(function()
		return vim.api.nvim_exec2("messages", { output = true }).output
	end)
	if not ok then
		log_line("[nvim-debug messages] failed")
		return
	end
	log_line("----- :messages -----")
	for _, line in ipairs(vim.split(out, "\n", { plain = true })) do
		log_line(line)
	end
end

function M.setup()
	-- Try immediately, then again after lazy.nvim finishes wiring plugins.
	ensure_echo_wrapped()
	ensure_wrapped()

	vim.api.nvim_create_autocmd("User", {
		pattern = { "LazyDone", "VeryLazy" },
		callback = ensure_wrapped,
	})

	vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, {
		callback = ensure_wrapped,
	})

	vim.defer_fn(ensure_wrapped, 50)
	vim.defer_fn(ensure_wrapped, 200)
	vim.defer_fn(ensure_wrapped, 1000)
	vim.defer_fn(ensure_wrapped, 2000)
	vim.defer_fn(ensure_wrapped, 5000)

	-- Keep re-wrapping briefly to survive late overwrites of vim.notify.
	local uv_ok, uv = pcall(require, "luv")
	if uv_ok and uv and type(uv.new_timer) == "function" then
		local timer = uv.new_timer()
		local i = 0
		timer:start(0, 100, function()
			i = i + 1
			vim.schedule(ensure_wrapped)
			if i >= 50 then
				timer:stop()
				timer:close()
			end
		end)
	end
end

function M.set_context(file)
	ctx.file = file
	ctx.ft = nil
	if file ~= nil and file ~= "" then
		pcall(function()
			ctx.ft = vim.filetype.match({ filename = file })
		end)
	end
	local line = ("========== nvim-debug file ==========%s"):format(ctx_prefix())
	vim.api.nvim_out_write(line .. "\n")
	log_line(line)
end

function M.set_phase(phase)
	ctx.phase = phase
	local line = "========== nvim-debug phase=" .. tostring(phase) .. " =========="
	vim.api.nvim_out_write(line .. "\n")
	log_line(line)
end

function M.notify_history_len()
	local hist = get_notify_history()
	return hist and #hist or 0
end

function M.dump_notify_since(start_len)
	local hist = get_notify_history()
	local start = tonumber(start_len) or 0
	local now = hist and #hist or 0
	local header = ("----- :Notifications delta ----- %s -> %s%s"):format(start, now, ctx_prefix())
	vim.api.nvim_out_write(header .. "\n")
	log_line(header)
	if hist == nil or now <= start then
		log_line("(no new notifications)")
		vim.api.nvim_out_write("(no new notifications)\n")
		return
	end
	for i = start + 1, now do
		local line = format_notify_record(hist[i])
		vim.api.nvim_out_write(line .. "\n")
		log_line(line)
	end
end

function M.dump_notify_history()
	local hist = get_notify_history()
	local header = ("----- :Notifications full ----- count=%s%s"):format(tostring(hist and #hist or 0), ctx_prefix())
	vim.api.nvim_out_write(header .. "\n")
	log_line(header)
	if hist == nil then
		log_line("(notify history unavailable)")
		vim.api.nvim_out_write("(notify history unavailable)\n")
		return
	end
	for _, r in ipairs(hist) do
		local line = format_notify_record(r)
		vim.api.nvim_out_write(line .. "\n")
		log_line(line)
	end
end

return M
