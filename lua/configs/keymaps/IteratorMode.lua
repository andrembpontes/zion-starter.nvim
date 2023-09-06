local hydra = require("hydra")

local noop_iterator = {
	name = "none",
	on_next = function() end,
	on_prev = function() end,
	on_list = function() end,
}

local Iterator = {
	iterators = {},
	current = noop_iterator,
}

function Iterator:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Iterator:try_set_current(key)
	local next = self.iterators[key]
	if next then
		self.current = next
		return true
	else
		return false
	end
end

function Iterator:add_iterator(iterator)
	self.iterators[iterator.key] = iterator
end

local function invoke_or_eval_keys(fn_or_string)
	if type(fn_or_string) == "string" then
		-- extracted from hydra source-code
		local termcodes = vim.api.nvim_replace_termcodes(fn_or_string, true, true, true)
		--vim.api.nvim_feedkeys(termcodes, "n", false)
	elseif type(fn_or_string) == "function" then
		fn_or_string()
	else
		error("Invalid type: " .. type(fn_or_string))
	end
end

function Iterator:setup_hydra()
	local _self = self

	local config = {
		name = "Iterators",
		body = "]",
		hint = [[curr: %{curr_name}

_[_: Get prev
_]_: Get next
_l_: Show list

%{iterators_list}
]],
		mode = "n",
		heads = {
			{
				"[",
				function()
					invoke_or_eval_keys(_self.current.on_prev)
				end,
			},
			{
				"]",
				function()
					invoke_or_eval_keys(_self.current.on_next)
				end,
			},
			{
				"l",
				function()
					invoke_or_eval_keys(_self.current.on_list)
				end,
			},
		},
		config = {
			hint = {
				type = "window",
				position = "middle-right",
				offset = 3,
				funcs = {
					curr_name = function()
						if _self.current then
							return _self.current.name
						else
							return "none"
						end
					end,

					iterators_list = function()
						local list = ""
						for _, val in pairs(_self.iterators) do
							list = list .. val.name .. ", "
						end
						return list
					end,
				},
			},
			invoke_on_body = true,
		},
	}

	for _, value in pairs(_self.iterators) do
		config.heads[#config.heads + 1] = {
			value.key,
			function()
				_self:try_set_current(value.key)
			end,
		}
	end

	print(vim.inspect(config))
	hydra(config)
end

return Iterator
