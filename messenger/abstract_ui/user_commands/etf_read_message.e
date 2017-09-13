note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_READ_MESSAGE
inherit
	ETF_READ_MESSAGE_INTERFACE
		redefine read_message end
create
	make
feature -- command
	read_message(uid: INTEGER_64 ; mid: INTEGER_64)
		require else
			read_message_precond(uid, mid)
    	do
			-- perform some update on the model state
			if not model.id_positive (uid) or not model.id_positive (mid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif not model.user_exists (uid) then
				model.set_error_message (errors.user_not_exists)
			elseif not model.message_exists (mid) then
				model.set_error_message (errors.message_not_exists)
			elseif not model.authorized_message_access (uid, mid) then
				model.set_error_message (errors.user_not_authorized)
			elseif model.message_unavailable (uid, mid) then
				model.set_error_message (errors.message_id_unavailable)
			elseif model.message_already_read (uid, mid) then
				model.set_error_message (errors.already_read)
			else
				model.read_message (uid, mid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
