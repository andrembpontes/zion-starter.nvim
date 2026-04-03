NVIM_CONFIG_PATH ?= ~/.config/nvim
NVIM_DEBUG_WAIT ?= 5000
NVIM_DEBUG_WAIT_PER_FILE ?= 1500
NVIM_DEBUG_VERBOSE ?= 1
NVIM_DEBUG_EDIT ?= README.md
GIT_PULL ?= git pull
GIT_COMMIT_PUSH ?= git diff HEAD --exit-code || (git add . && git commit -am "update" && git push)

.PHONY: link pull push nvim-debug nvim-debug-cycle
.PHONY: nvim-debug-ui nvim-debug-cycle-ui
.PHONY: nvim-debug-ui-user nvim-debug-cycle-user

link:
	[[ -d $(NVIM_CONFIG_PATH) ]] || ln -s $(CURDIR) $(NVIM_CONFIG_PATH)

pull:
	$(GIT_PULL)
	(cd ../zion.nvim && $(GIT_PULL))

push:
	$(GIT_COMMIT_PUSH)
	(cd ../zion.nvim && $(GIT_COMMIT_PUSH))

nvim-debug:
	XDG_CONFIG_HOME="$(shell dirname $(CURDIR))" \
	NVIM_APPNAME="$(notdir $(CURDIR))" \
	NVIM_DEBUG_NOTIFY=1 \
	NVIM_DEBUG_UI=1 \
	NVIM_DEBUG_WAIT="$(NVIM_DEBUG_WAIT)" \
	nvim --headless -V$(NVIM_DEBUG_VERBOSE) "$(NVIM_DEBUG_EDIT)" \
		-c "lua vim.api.nvim_out_write('[nvim-debug] starting\\n')" \
		-c "lua pcall(vim.api.nvim_exec_autocmds, 'User', { pattern = 'VeryLazy' })" \
		-c "lua vim.notify('[nvim-debug] notify wrapper active')" \
		-c "lua vim.wait(tonumber(vim.env.NVIM_DEBUG_WAIT or '5000'), function() return false end, 50)" \
		-c "lua local o=vim.api.nvim_exec2('messages',{output=true}).output; vim.api.nvim_out_write('\\n----- :messages -----\\n'..o..'\\n')" \
		-c "qa" \
		2>&1

nvim-debug-cycle:
	XDG_CONFIG_HOME="$(shell dirname $(CURDIR))" \
	NVIM_APPNAME="$(notdir $(CURDIR))" \
	NVIM_DEBUG_NOTIFY=1 \
	NVIM_DEBUG_UI=1 \
	NVIM_DEBUG_WAIT_PER_FILE="$(NVIM_DEBUG_WAIT_PER_FILE)" \
	nvim --headless -V$(NVIM_DEBUG_VERBOSE) tests/demo-files/demo.md \
		-c "lua vim.api.nvim_out_write('[nvim-debug] cycle start\\n')" \
		-c "lua pcall(vim.api.nvim_exec_autocmds, 'User', { pattern = 'VeryLazy' })" \
		-c "lua vim.notify('[nvim-debug] notify wrapper active')" \
		-c "lua local dir='tests/demo-files'; local wait_ms=tonumber(vim.env.NVIM_DEBUG_WAIT_PER_FILE or '1500'); local files=vim.fn.globpath(dir,'*',false,true); table.sort(files); for _,f in ipairs(files) do vim.api.nvim_out_write(('\\n[nvim-debug] edit %s\\n'):format(f)); vim.cmd('edit ' .. vim.fn.fnameescape(f)); vim.api.nvim_out_write(('[nvim-debug] ft=%s\\n'):format(vim.bo.filetype)); vim.wait(wait_ms, function() return false end, 50); end" \
		-c "lua local o=vim.api.nvim_exec2('messages',{output=true}).output; vim.api.nvim_out_write('\\n----- :messages -----\\n'..o..'\\n')" \
		-c "qa" \
		2>&1

nvim-debug-ui:
	@LOG=$$(mktemp -t zion-nvim-debug.XXXXXX.log); \
	XDG_CONFIG_HOME="$(shell dirname $(CURDIR))" \
	NVIM_APPNAME="$(notdir $(CURDIR))" \
	NVIM_DEBUG_NOTIFY=1 \
	NVIM_DEBUG_LOG="$$LOG" \
	NVIM_DEBUG_WAIT="$(NVIM_DEBUG_WAIT)" \
	nvim -V$(NVIM_DEBUG_VERBOSE) "$(NVIM_DEBUG_EDIT)" \
		-c "lua vim.api.nvim_out_write('[nvim-debug] ui start\\n')" \
		-c "lua vim.api.nvim_create_autocmd('VimEnter',{once=true,callback=function() local wait_ms=tonumber(vim.env.NVIM_DEBUG_WAIT or '5000'); pcall(vim.api.nvim_exec_autocmds,'User',{pattern='VeryLazy'}); vim.notify('[nvim-debug] notify wrapper active'); vim.defer_fn(function() require('configs.debug').dump_messages(); vim.cmd('qa') end, wait_ms) end})"; \
	printf "\n----- nvim-debug log (%s) -----\n" "$$LOG"; \
	cat "$$LOG"

nvim-debug-cycle-ui:
	@LOG=$$(mktemp -t zion-nvim-debug.XXXXXX.log); \
	XDG_CONFIG_HOME="$(shell dirname $(CURDIR))" \
	NVIM_APPNAME="$(notdir $(CURDIR))" \
	NVIM_DEBUG_NOTIFY=1 \
	NVIM_DEBUG_LOG="$$LOG" \
	NVIM_DEBUG_WAIT_PER_FILE="$(NVIM_DEBUG_WAIT_PER_FILE)" \
	nvim -V$(NVIM_DEBUG_VERBOSE) \
		-c "lua vim.api.nvim_out_write('[nvim-debug] ui cycle start\\n')" \
		-c "lua vim.api.nvim_create_autocmd('VimEnter',{once=true,callback=function() local dbg=require('configs.debug'); local wait_ms=tonumber(vim.env.NVIM_DEBUG_WAIT_PER_FILE or '1500'); dbg.set_phase('cycle'); pcall(vim.api.nvim_exec_autocmds,'User',{pattern='VeryLazy'}); vim.notify('[nvim-debug] notify wrapper active'); local dir='tests/demo-files'; local files=vim.fn.globpath(dir,'*',false,true); table.sort(files); local i=1; local function step() if i>#files then dbg.set_phase('final'); dbg.dump_messages(); dbg.dump_notify_history(); vim.cmd('qa'); return end; local f=files[i]; dbg.set_context(f); local start=dbg.notify_history_len(); vim.cmd('edit! ' .. vim.fn.fnameescape(f)); i=i+1; vim.defer_fn(function() dbg.dump_notify_since(start); step(); end, wait_ms); end; step(); end})"; \
	printf "\n----- nvim-debug log (%s) -----\n" "$$LOG"; \
	cat "$$LOG"

# Debug the *default* user config (~/.config/nvim) while still capturing notifications.
# This does NOT override XDG_CONFIG_HOME or NVIM_APPNAME.
nvim-debug-ui-user:
	@LOG=$$(mktemp -t nvim-debug-user.XXXXXX.log); \
	NVIM_DEBUG_LOG="$$LOG" \
	NVIM_DEBUG_NOTIFY_TRACEBACK=1 \
	NVIM_DEBUG_WAIT="$(NVIM_DEBUG_WAIT)" \
	nvim -V$(NVIM_DEBUG_VERBOSE) \
		--cmd "luafile $(CURDIR)/scripts/nvim-debug-notify.lua" \
		"$(NVIM_DEBUG_EDIT)" \
		-c "lua vim.api.nvim_create_autocmd('VimEnter',{once=true,callback=function() local wait_ms=tonumber(vim.env.NVIM_DEBUG_WAIT or '5000'); vim.defer_fn(function() if _G.NVIM_DEBUG then pcall(_G.NVIM_DEBUG.dump_messages); pcall(_G.NVIM_DEBUG.dump_notify_history); end; vim.cmd('qa') end, wait_ms) end})"; \
	printf "\n----- nvim-debug log (%s) -----\n" "$$LOG"; \
	cat "$$LOG"

# Headless cycle debug for the default user config.
nvim-debug-cycle-user:
	NVIM_DEBUG_NOTIFY_TRACEBACK=1 \
	nvim --headless -V$(NVIM_DEBUG_VERBOSE) \
		--cmd "luafile $(CURDIR)/scripts/nvim-debug-notify.lua" \
		tests/demo-files/demo.md \
		-c "lua vim.api.nvim_out_write('[nvim-debug] cycle start\\n')" \
		-c "lua local dir='tests/demo-files'; local wait_ms=tonumber(vim.env.NVIM_DEBUG_WAIT_PER_FILE or '1500'); local files=vim.fn.globpath(dir,'*',false,true); table.sort(files); for _,f in ipairs(files) do vim.api.nvim_out_write(('\\n[nvim-debug] edit %s\\n'):format(f)); vim.cmd('edit ' .. vim.fn.fnameescape(f)); vim.api.nvim_out_write(('[nvim-debug] ft=%s\\n'):format(vim.bo.filetype)); vim.wait(wait_ms, function() return false end, 50); end" \
		-c "lua if _G.NVIM_DEBUG then pcall(_G.NVIM_DEBUG.dump_messages); pcall(_G.NVIM_DEBUG.dump_notify_history); end" \
		-c "qa" \
		2>&1
