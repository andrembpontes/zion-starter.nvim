-- Standalone notify debugger for *any* Neovim config.
-- Intended to be loaded via: nvim --cmd "luafile /path/to/this.lua"

local M = {}

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
  pcall(vim.fn.writefile, lines, p, "a")
end

local function log_line(line)
  log_lines({ line })
end

local function sanitize(v)
  local s = tostring(v)
  s = s:gsub("%z", "\\0")
  s = s:gsub("\r", "\\r")
  s = s:gsub("\n", "\\n")
  return s
end

local function safe_inspect(v)
  local ok, inspect = pcall(require, "vim.inspect")
  if ok and type(inspect) == "function" then
    return inspect(v)
  end
  return tostring(v)
end

local function wrap_notify(original)
  return function(msg, level, opts)
    if vim.g._nvim_debug_in_notify then
      return original(msg, level, opts)
    end
    vim.g._nvim_debug_in_notify = true

    local level_s = level ~= nil and tostring(level) or "nil"
    local title_s = ""
    if type(opts) == "table" and opts.title ~= nil then
      title_s = " title=" .. tostring(opts.title)
    end

    local header = ("[nvim-debug notify] level=%s%s msg=%s opts=%s"):format(
      level_s,
      title_s,
      sanitize(msg),
      safe_inspect(opts)
    )

    vim.api.nvim_out_write(header .. "\n")
    log_line(header)

    if vim.env.NVIM_DEBUG_NOTIFY_TRACEBACK == "1" then
      local tb = debug.traceback("[nvim-debug notify traceback]", 2)
      vim.api.nvim_out_write(tb .. "\n")
      log_lines(vim.split(tb, "\n", { plain = true }))
    end

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

local function install_notify_trap()
  if vim.g._nvim_debug_notify_trap_installed then
    return
  end
  vim.g._nvim_debug_notify_trap_installed = true

  local mt = getmetatable(vim) or {}
  local orig_newindex = mt.__newindex

  mt.__newindex = function(t, k, v)
    if k == "notify" then
      rawset(t, k, wrap_notify(v))
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
  rawset(vim, "notify", wrap_notify(vim.notify))
end

function M.dump_messages()
  local ok, out = pcall(function()
    return vim.api.nvim_exec2("messages", { output = true }).output
  end)
  if not ok then
    return
  end
  vim.api.nvim_out_write("\n----- :messages -----\n" .. out .. "\n")
  log_lines({ "----- :messages -----" })
  log_lines(vim.split(out, "\n", { plain = true }))
end

function M.dump_notify_history()
  local ok_mod, mod = pcall(require, "notify")
  if not ok_mod or mod == nil or type(mod.history) ~= "function" then
    return
  end

  local ok_hist, hist = pcall(mod.history, { include_hidden = true })
  if not ok_hist or type(hist) ~= "table" then
    return
  end

  vim.api.nvim_out_write("\n----- :Notifications full ----- count=" .. tostring(#hist) .. "\n")
  log_line("----- :Notifications full ----- count=" .. tostring(#hist))

  for i, r in ipairs(hist) do
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
    local line = ("[nvim-debug notify-history] idx=%s level=%s title=%s msg=%s"):format(
      tostring(r.id or i),
      lvl,
      sanitize(title),
      sanitize(msg)
    )
    vim.api.nvim_out_write(line .. "\n")
    log_line(line)
  end
end

install_notify_trap()

_G.NVIM_DEBUG = _G.NVIM_DEBUG or {}
_G.NVIM_DEBUG.dump_messages = M.dump_messages
_G.NVIM_DEBUG.dump_notify_history = M.dump_notify_history

vim.schedule(function()
  vim.notify("[nvim-debug] notify wrapper active")
end)
