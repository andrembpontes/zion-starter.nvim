NVIM_CONFIG_PATH ?= ~/.config/nvim

.PHONY:

link:
	ln -s $(PWD) $(NVIM_CONFIG_PATH)
