local anki = require "anki"
local http = require "http"
local mputil = require "mp.utils"

local ankiconnect = {}

function ankiconnect.request(action, params)
	return http.post_json{
		url = "localhost:8765",
		data = mputil.format_json{
			action = action,
			params = params,
			version = 6
		}
	}
end

function ankiconnect.add_note(fields)
	local tgt = anki.active_target()
	ankiconnect.request("addNote", {
		note = {
			deckName = tgt.deck,
			modelName = tgt.note_type,
			fields = fields,
			options = {allowDuplicate = true},
			tags = tgt.config.tags
		}
	})
end

return ankiconnect
