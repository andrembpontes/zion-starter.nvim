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
map("n", "<CS-c>", [["+yy]])
map("v", "<CS-c>", [["+y]])
map("i", "<CS-c>", [[<esc>"+yya]])

map("n", "<CS-v>", [[<cmd>set paste<CR>"+p<cmd>set nopaste<CR>]])
map("i", "<CS-v>", [[<cmd>set paste<CR><C-R>+<cmd>set nopaste<CR>]])
map("c", "<CS-v>", [[<C-R>+]])
map("v", "<CS-v>", [["+p]])
map("t", "<CS-v>", [[<C-\><C-n>"+pa]])
