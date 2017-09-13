note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_DELETE_MESSAGE
inherit
	ETF_DELETE_MESSAGE_INTERFACE
		redefine delete_message end
create
	make
feature -- command
	delete_message(uid: INTEGER_64 ; mid: INTEGER_64)
		require else
			delete_message_precond(uid, mid)
    	do
			-- perform some update on the model state
			if not model.id_positive (uid) or not model.id_positive (mid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif not model.user_exists (uid) then
				model.set_error_message (errors.user_not_exists)
			elseif not model.message_exists (mid) then
				model.set_error_message (errors.message_not_exists)
			elseif not model.message_id_found_in_old_messages (uid, mid) then
				model.set_error_message (errors.old_message_not_found)
			else
				model.delete_message (uid, mid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
