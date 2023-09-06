local LayerMode = {
	keys = {}, -- {lhs, rhs, opts}
}

local function make_instructions(keys)
	local instructions = {}
	print(vim.inspect(keys))
	for _, value in ipairs(keys) do
		local lhs = value[1]
		local rhs = value[2]

		vim.validate({
			lhs = { lhs, "string" },
			rhs = { rhs, { "string", "function" } },
		})

		instructions[lhs] = rhs
	end

	return instructions
end

function LayerMode:new(name, trigger, keys)
	vim.validate({
		name = { name, "string" },
		keys = { keys, "table" },
	})

	local o = {
		name = name,
		keys = keys,
		trigger = trigger,
		instructions = make_instructions(keys),
	}

	setmetatable(o, self)
	self.__index = self

	o:__setup()
	return o
end

function LayerMode:enter()
	print(vim.inspect(self))
	require("libmodal").mode.enter(self.name, self.instructions)
end

function LayerMode:__setup()
	local _self = self
	local cmd = "EnterMode" .. self.name:gsub("^%l", string.upper)
	vim.api.nvim_create_user_command(cmd, function()
		_self:enter()
	end, {})
	vim.keymap.set("n", self.trigger, ":" .. cmd .. "<cr>")
end

return LayerMode
