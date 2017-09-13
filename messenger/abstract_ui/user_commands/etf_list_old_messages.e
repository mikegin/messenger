note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_OLD_MESSAGES
inherit
	ETF_LIST_OLD_MESSAGES_INTERFACE
		redefine list_old_messages end
create
	make
feature -- command
	list_old_messages(uid: INTEGER_64)
		require else
			list_old_messages_precond(uid)
    	do
			-- perform some update on the model state
			if not model.id_positive (uid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif not model.user_exists (uid) then
				model.set_error_message (errors.user_not_exists)
			elseif not model.has_old_messages (uid) then
				model.set_query_warning (errors.w_no_old_messages)
			else
				model.list_old_messages (uid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
