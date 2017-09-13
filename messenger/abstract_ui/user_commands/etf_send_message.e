note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SEND_MESSAGE
inherit
	ETF_SEND_MESSAGE_INTERFACE
		redefine send_message end
create
	make
feature -- command
	send_message(uid: INTEGER_64 ; gid: INTEGER_64 ; txt: STRING)
		require else
			send_message_precond(uid, gid, txt)
    	do
			-- perform some update on the model state
			if not model.id_positive (uid) or not model.id_positive (gid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif not model.user_exists (uid) then
				model.set_error_message (errors.user_not_exists)
			elseif not model.group_exists (gid) then
				model.set_error_message (errors.group_not_exists)
			elseif model.message_empty (txt) then
				model.set_error_message (errors.message_empty)
			elseif not model.registration_exists (uid, gid) then
				model.set_error_message (errors.not_authorized_group)
			else
				model.send_message (uid, gid, txt)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
