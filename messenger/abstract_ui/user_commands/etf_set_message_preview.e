note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SET_MESSAGE_PREVIEW
inherit
	ETF_SET_MESSAGE_PREVIEW_INTERFACE
		redefine set_message_preview end
create
	make
feature -- command
	set_message_preview(n: INTEGER_64)
    	do
			-- perform some update on the model state
			if not model.correct_message_length (n) then
				model.set_error_message (errors.incorrect_message_length)
			else
				model.set_message_preview (n)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
