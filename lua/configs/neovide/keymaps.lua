local keys = require("user.utils.keymaps")

-- Default Cmd+{C,V} Copy/Paste
keys.nmap("<D-c>", '"+yy')
keys.vmap("<D-c>", '"+y')
keys.icmap("<D-c>", '"+yy')
keys.map("<D-v>", '<cmd>set paste<CR>"+p<cmd>set nopaste<CR>')
keys.icmap("<D-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
keys.tmap("<D-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
keys.vmap("<D-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")

-- Default Ctrl+Shift+{C,V} Copy/Paste
keys.nmap("<C-S-c>", '"+yy')
keys.vmap("<C-S-c>", '"+y')
keys.icmap("<C-S-c>", '"+yy')
keys.map("<C-S-v>", '<cmd>set paste<CR>"+p<cmd>set nopaste<CR>')
keys.icmap("<C-S-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
keys.tmap("<C-S-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
keys.vmap("<C-S-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")

return {} -- Lazy requires a table return
