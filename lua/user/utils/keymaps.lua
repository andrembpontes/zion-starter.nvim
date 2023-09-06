local M = {}

function M.setKeymap(mode, lhs, rhs, opts)
	local mergedOpts = vim.tbl_deep_extend("force", {
		silent = false,
		noremap = true,
		desc = rhs,
	}, opts or {})

	vim.keymap.set(mode, lhs, rhs, mergedOpts)
end

---Mappings for nvo mode (Normal + Visual + Select + Operator)
function M.map(lhs, rhs, opts)
	M.setKeymap({ "n", "v", "o" }, lhs, rhs, opts)
end

---Mappings for n mode (Normal)
function M.nmap(lhs, rhs, opts)
	M.setKeymap("n", lhs, rhs, opts)
end

---Mappings for i mode (Insert)
function M.imap(lhs, rhs, opts)
	M.setKeymap("i", lhs, rhs, opts)
end

---Mappings for v mode (Visual + Select)
function M.vmap(lhs, rhs, opts)
	M.setKeymap("v", lhs, rhs, opts)
end

---Mappings for ! mode (Insert + CommandLine)
function M.icmap(lhs, rhs, opts)
	M.setKeymap("!", lhs, rhs, opts)
end

---Mappings for c mode (CommandLine)
function M.cmap(lhs, rhs, opts)
	M.setKeymap("c", lhs, rhs, opts)
end

---Mappings for t mode (Terminal)
function M.tmap(lhs, rhs, opts)
	M.setKeymap("t", lhs, rhs, opts)
end

return M
