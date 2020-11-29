local mputil = require "mp.utils"
local util = require "util"

local config = {
	values = {
		anki_targets=""
	}
}

local mp_opts = require "mp.options"
mp_opts.read_options(config.values)

function config.load(path)
	local stat_res = mputil.file_info(path)
	if not stat_res or not stat_res.is_file then
		-- TODO handle error
	end

	local result = {}
	local section_name, section_entries
	local block_token, block_key, block_value

	local function insert_section()
		table.insert(result, {
			name = section_name,
			entries = section_entries
		})
	end

	for line in io.lines(path) do
		if block_token then
			if util.string_trim(line) == block_token then
				section_entries[block_key] = table.concat(block_value, "\n")
				block_token, block_key, block_value = nil
			else table.insert(block_value, line) end
		else
			local trimmed = util.string_trim(line, "start")
			if #trimmed ~= 0 and not util.string_starts(trimmed, "#") then
				if util.string_starts(trimmed, "[") then
					local new_section_name = line:match("%[([^%]]+)%]")
					if not new_section_name then
						-- TODO handle error
					else
						if section_name then insert_section() end
						section_name, section_entries = new_section_name, {}
					end
				elseif section_name then
					local key, value = trimmed:match("^([^=]+)=(.*)$")
					if key then
						local block_token_match = value:match("%[([^%[]*)%[")
						if block_token_match then
							block_token = "]" .. block_token_match .. "]"
							block_key, block_value = key, {}
						else section_entries[key] = value end
					else
						-- TODO handle error
					end
				else
					-- TODO handle error
				end
			end
		end
	end
	if section_name then insert_section() end
	return result
end

function config.load_subcfg(name)
	local rel_path = string.format("script-opts/%s-%s.conf", mp.get_script_name(), name)
	return config.load(mp.find_config_file(rel_path))
end

return config
