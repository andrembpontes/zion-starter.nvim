NVIM_CONFIG_PATH ?= ~/.config/nvim
GIT_PULL ?= git pull
GIT_COMMIT_PUSH ?= git diff HEAD --exit-code || (git add . && git commit -am "update" && git push)

.PHONY:

link:
	[[ -d $(NVIM_CONFIG_PATH) ]] || ln -s $(PWD) $(NVIM_CONFIG_PATH)

pull:
	$(GIT_PULL)
	(cd ../zion.nvim && $(GIT_PULL))

push:
	$(GIT_COMMIT_PUSH)
	(cd ../zion.nvim && $(GIT_COMMIT_PUSH))
