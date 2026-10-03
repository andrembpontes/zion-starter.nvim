-- Auto imported, you can override options here

-- Make the jumplist behave like a tree/stack so <BS> (<C-o>) and TAB (<C-i>)
-- act as back/forward and never revisit stale, already-left entries.
--   stack -> discard the forward branch when you jump from a middle entry
--   clean -> drop unloaded buffers
--   view  -> restore scroll offset ("mark view") on jump
vim.opt.jumpoptions = "stack,clean,view"

