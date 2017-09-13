note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REGISTER_USER
inherit
	ETF_REGISTER_USER_INTERFACE
		redefine register_user end
create
	make
feature -- command
	register_user(uid: INTEGER_64 ; gid: INTEGER_64)
		require else
			register_user_precond(uid, gid)
    	do
			-- perform some update on the model state
			if not model.id_positive (uid) or not model.id_positive (gid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif not model.user_exists (uid) then
				model.set_error_message (errors.user_not_exists)
			elseif not model.group_exists (gid) then
				model.set_error_message (errors.group_not_exists)
			elseif model.registration_exists (uid, gid) then
				model.set_error_message (errors.registration_already_exists)
			else
				model.register_user (uid, gid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
