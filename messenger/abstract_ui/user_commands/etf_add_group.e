note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_GROUP
inherit
	ETF_ADD_GROUP_INTERFACE
		redefine add_group end
create
	make
feature -- command
	add_group(gid: INTEGER_64 ; group_name: STRING)
		require else
			add_group_precond(gid, group_name)
    	do
			-- perform some update on the model state
			if not model.id_positive (gid) then
				model.set_error_message (errors.id_must_be_positive)
			elseif model.group_exists (gid) then
				model.set_error_message (errors.id_in_use)
			elseif not model.name_starts_with_letter (group_name) then
				model.set_error_message (errors.group_name_starts_with_letter)
			else
				model.add_group (gid, group_name)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
