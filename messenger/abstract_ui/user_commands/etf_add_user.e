note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_USER
inherit
	ETF_ADD_USER_INTERFACE
		redefine add_user end
create
	make
feature -- command
	add_user(uid: INTEGER_64 ; user_name: STRING)
		require else
			add_user_precond(uid, user_name)
    	do
			-- perform some update on the model state
			if not model.id_positive (uid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif model.user_exists (uid) then
				model.set_error_message (errors.id_in_use)
			elseif not model.name_starts_with_letter (user_name) then
				model.set_error_message (errors.user_name_starts_with_letter)
			else
				model.add_user (uid, user_name)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
