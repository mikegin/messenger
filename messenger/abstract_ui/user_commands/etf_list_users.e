note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_USERS
inherit
	ETF_LIST_USERS_INTERFACE
		redefine list_users end
create
	make
feature -- command
	list_users
    	do
			-- perform some update on the model state
			if not model.users_exist then
				model.set_query_warning (errors.w_no_users_registered)
			else
				model.list_users
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
