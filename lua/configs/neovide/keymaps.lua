local map = vim.keymap.set;

-- Default Cmd+{C,V} Copy/Paste
map("n", "<D-c>", '"+yy')
map("v", "<D-c>", '"+y')
map({ "i", "c" }, "<D-c>", '<esc>"+yya')
map({ "n", "v", "o" }, "<D-v>", '<cmd>set paste<CR>"+p<cmd>set nopaste<CR>')
map({ "i", "c" }, "<D-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
map("t", "<D-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
map("v", "<D-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")

-- Default Ctrl+Shift+{C,V} Copy/Paste
map("n", "<C-S-c>", '"+yy')
map("v", "<C-S-c>", '"+y')
map({ "i", "c" }, "<C-S-c>", '<esc>"+yya')
map({ "n", "v", "o" }, "<C-S-v>", '<cmd>set paste<CR>"+p<cmd>set nopaste<CR>')
map({ "i", "c" }, "<C-S-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
map("t", "<C-S-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
map("v", "<C-S-v>", "<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>")
