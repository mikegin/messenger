note
	description: "Class responsible for the main business logic of the Messenger app."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

class
	MESSENGER

inherit
	MESSENGER_ADT
		redefine
			out
		end

create {MESSENGER_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		local
			comparator: KL_COMPARABLE_COMPARATOR[INTEGER_64]
			users_name_comparator: KL_COMPARABLE_COMPARATOR[USER]
			groups_name_comparator: KL_COMPARABLE_COMPARATOR[GROUP]
			state_access: STATE_ACCESS
			errors_access: ERRORS_ACCESS
		do
			create adt_users.make_empty
			create adt_groups.make_empty
			create adt_messages.make_empty
			create adt_registrations.make_empty

			create comparator.make
			create users.make (comparator)
			create groups.make (comparator)
			create messages.make (comparator)
			mid_counter := 1 -- initial message number

			states := state_access.m

			--output handling
			errors := errors_access.m
			create error_status.make_from_string (errors.ok)
			create error_message.make_empty
			states := state_access.m
			create read_message_output.make_empty
			create query.make_empty
			create query_warning.make_empty
			create query_list_warning.make_empty
			create query_name_list.make_empty

			create users_name_comparator.make
			create users_name.make (users_name_comparator)
			create groups_name_comparator.make
			create groups_name.make (groups_name_comparator)

		end

feature{MESSENGER, STUDENT_TESTS} -- model attributes
	users: DS_RED_BLACK_TREE[USER, INTEGER_64] -- user_id -> USER (sorted by user_id)

	groups: DS_RED_BLACK_TREE[GROUP, INTEGER_64] -- group_id -> GROUP (sorted by group_id)

	messages: DS_RED_BLACK_TREE[MESSAGE, INTEGER_64] -- message_id -> MESSAGE (sorted by message_id)

	states: STATE

	users_name: DS_RED_BLACK_TREE[USER, USER] -- users tree sorted by USER, name then id

	groups_name: DS_RED_BLACK_TREE[GROUP, GROUP] -- groups tree sorted by GROUP, name then id

feature{NONE} -- output attributes
	errors: ERRORS

	error_status: STRING

	error_message: STRING

	output_counter: INTEGER_64

	read_message_output: STRING

	query: STRING

	query_warning: STRING

	output_is_query: BOOLEAN

	query_list_warning: STRING

	query_name_list: STRING

	output_is_query_name_list: BOOLEAN

feature -- Commands
	reset
			-- Reset model state.
		do
			make
		end

	add_user (uid: INTEGER_64; user_name: STRING)
		local
			user: USER
		do
			create user.make (uid, user_name)

			-- abstract implementation
			adt_users.extend ([uid, user])

			-- concrete implementation
			users.put_new (user, uid)
			users_name.put_new (user, user)
		end

	add_group (gid: INTEGER_64; group_name: STRING)
		local
			group: GROUP
		do
			create group.make (gid, group_name)

			-- abstract implementation
			adt_groups.extend ([gid, group])

			-- concrete implementation
			groups.put_new (group, gid)
			groups_name.put_new (group, group)
		end

	register_user (uid: INTEGER_64; gid: INTEGER_64)
		local
			user: USER
			group: GROUP
		do
			-- abstract implementation
			adt_registrations.extend ([uid, gid])

			-- concrete implementation
			user := users.at (uid)
			group := groups.at (gid)
			user.add_group (gid)
			group.add_user (uid)
		end

	send_message (uid: INTEGER_64; gid: INTEGER_64; txt: STRING)
		local
			message: MESSAGE
			group: GROUP
		do
			create message.make (mid_counter, uid, gid, txt)

			-- abstract implementation
			adt_messages.extend ([mid_counter, message])

			-- concrete implementation
				-- put message mapping
			messages.put_new (message, mid_counter)


			group := groups.at (gid)
				-- add message to group
			group.add_message (mid_counter)
				-- send message to group's users
			across group.get_users as cr
				loop
						-- put message in users inboxes
					if cr.item /~ uid then
						users.at (cr.item).put_in_inbox (mid_counter, states.unread)
					else
						users.at (cr.item).put_in_inbox (mid_counter, states.read)
					end

				end

			mid_counter := mid_counter + 1
		end

	read_message (uid: INTEGER_64; mid: INTEGER_64)
		do
			users.at (uid).change_in_inbox (mid, states.read)

			set_read_message_output (uid, mid)
		end

	delete_message (uid: INTEGER_64; mid: INTEGER_64)
		do
			users.at (uid).remove_from_inbox (mid)
		end

	set_message_preview (n: INTEGER_64)
		do
			across
				messages as cr
			loop
				cr.item.set_message_prev (n)
			end
		end

feature -- Queries
	id_positive (id: INTEGER_64): BOOLEAN
		do
			Result := id > 0
		end

	name_starts_with_letter (name: STRING): BOOLEAN
		do
			Result := not name.is_empty and then name[1].is_alpha
		end

	user_exists (id: INTEGER_64): BOOLEAN
		do
			Result := users.has (id)
		end

	group_exists (id: INTEGER_64): BOOLEAN
		do
			Result := groups.has (id)
		end

	message_exists (id: INTEGER_64): BOOLEAN
		do
			Result := messages.has (id)
		end

	registration_exists (uid: INTEGER_64; gid: INTEGER_64): BOOLEAN
		do
			Result := users.at (uid).has_group (gid)
		end

	message_empty (txt: STRING): BOOLEAN
		do
			Result := txt.is_empty
		end

	authorized_message_access (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
		do
			-- user in the group with the message
			across
				groups as cr
			loop
				if cr.item.has_message (mid) then -- only one group has the message
					Result := registration_exists (uid, cr.item.get_id)
				end
			end
		end

	message_unavailable (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
		do
			-- user in the group with the message but does not have the message
			across
				groups as cr
			loop
				if cr.item.has_message (mid) then --only one group has the message
					Result := not users.at (uid).has_in_inbox (mid)
				end
			end
		end

	message_already_read (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
		do
			Result := users.at (uid).get_from_inbox (mid) ~ states.read
		end

	message_id_found_in_old_messages (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
		local
			user: USER
		do
			user := users.at (uid)
			if user.has_in_inbox (mid) then
				Result := user.get_from_inbox (mid) ~ states.read
			end
		end

	correct_message_length (n: INTEGER_64): BOOLEAN
		do
			Result := n > 0
		end

	has_old_messages (uid: INTEGER_64): BOOLEAN
		do
			Result := across users.at (uid).get_inbox as cr some cr.item ~ states.read end
		end

	has_new_messages (uid: INTEGER_64): BOOLEAN
		do
			Result := across users.at (uid).get_inbox as cr some cr.item ~ states.unread end
		end

	users_exist: BOOLEAN
		do
			Result := not users.is_empty
		end

	groups_exist: BOOLEAN
		do
			Result := not groups.is_empty
		end

feature -- output Commands
	list_new_messages (uid: INTEGER_64)
		do
			list_messages (uid, states.unread)
		end

	list_old_messages (uid: INTEGER_64)
		do
			list_messages (uid, states.read)
		end

	list_users
		do
			output_is_query_name_list := true

			across
				users_name as cr
			loop
				query_name_list.append ("  ")
				query_name_list.append (cr.item.get_id.out + "->" + cr.item.get_name)
				query_name_list.append ("%N")
			end
		end

	list_groups
		do
			output_is_query_name_list := true

			across
				groups_name as cr
			loop
				query_name_list.append ("  ")
				query_name_list.append (cr.item.get_id.out + "->" + cr.item.get_name)
				query_name_list.append ("%N")
			end
		end

	set_query_warning (s: STRING)
		do
			query_warning := s
			output_is_query := true
		end

	set_query_list_warning (s: STRING)
		do
			query_list_warning := s
			output_is_query_name_list := true
		end

	set_error_message (s: STRING)
		do
			error_message := s
			error_status := errors.error
		end



feature{NONE} -- output Commands helper functions
	list_messages (uid: INTEGER_64; state: STRING)
		local
			old_or_new: STRING
		do
			output_is_query := true

			create old_or_new.make_empty

			if state ~ states.read then
				old_or_new := "Old/read"
			elseif state ~ states.unread then
				old_or_new := "New/unread"
			end

			query.append (old_or_new + " messages for user [" + uid.out + ", " + users.at (uid).get_name + "]:" + "%N")
			across
				users.at (uid).get_inbox as cr
			loop
				if cr.item ~ state then
					query.append ("      ")
					query.append (cr.key.out + "->" + "[" + messages.at (cr.key).out + "]")
					query.append ("%N")
				end
			end
		end

	set_read_message_output (uid: INTEGER_64; mid: INTEGER_64)
		do
			read_message_output.append ("Message for user [" + uid.out + ", " + users.at (uid).get_name + "]: ")
			read_message_output.append ("[" + mid.out + ", %"" + messages.at (mid).get_txt + "%"]")
		end

feature -- output Queries
	out : STRING
		do
			--first line
			create Result.make_from_string ("  ")
			Result.append (output_counter.out + ":  ")
			Result.append (error_status)
			Result.append ("%N")

			--after first line
			if not (output_counter = 0) then
				if error_status ~ errors.error then
					Result.append(print_error_message)
				elseif error_status ~ errors.ok then
					if output_is_query then
						Result.append(print_query_message)
					elseif output_is_query_name_list then
						Result.append (print_query_list_message)
					else
						if not read_message_output.is_empty then
							Result.append(print_read_message_output)
						end

						Result.append(print_users_list)

						Result.append(print_groups_list)

						Result.append(print_registrations_list)

						Result.append(print_all_messages)

						Result.append(print_message_states)
					end
				end
			end
			reset_output_variables
			output_counter := output_counter + 1
		end

feature{NONE} -- output Queries helper functions
	print_read_message_output: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append (read_message_output)
			Result.append ("%N")
		end

	print_error_message: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append (error_message)
			Result.append("%N")
		end

	print_query_message: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			if not query_warning.is_empty then
				Result.append(query_warning)
				Result.append("%N")
			else
				Result.append (query)
			end
		end

	print_query_list_message: STRING
		do
			create Result.make_empty
			if not query_list_warning.is_empty then
				Result.append(query_list_warning)
				Result.append("%N")
			else
				Result.append(query_name_list)
			end
		end

	print_users_list: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Users:" + "%N")
			across
				users as cr
			loop
				Result.append ("      ")
				Result.append (cr.item.get_id.out + "->" + cr.item.get_name)
				Result.append ("%N")
			end
		end

	print_groups_list: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Groups:" + "%N")
			across
				groups as cr
			loop
				Result.append ("      ")
				Result.append (cr.item.get_id.out + "->" + cr.item.get_name)
				Result.append ("%N")
			end
		end

	print_registrations_list: STRING
		local
			reg_it: INTEGER_64
			group: GROUP
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Registrations:" + "%N")

			reg_it := 1
			across -- print users
				users as cr
			loop
				if cr.item.get_groups.count /= 0 then
					Result.append ("      ")
					Result.append ("[" + cr.item.get_id.out + ", " + cr.item.get_name + "]" + "->")
					Result.append ("{")

					reg_it := 1
					across -- print user's groups
						cr.item.get_groups as g_cr
					loop
						group := groups.at (g_cr.item)
						Result.append (group.get_id.out + "->" + group.get_name)
						if reg_it /= cr.item.get_groups.count then
							Result.append (", ")
						end
						reg_it := reg_it + 1
					end

					Result.append ("}")
					Result.append ("%N")
				end

			end
		end

	print_all_messages: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("All messages:" + "%N")
			across
				messages as cr
			loop
				Result.append ("      ")
				Result.append (cr.item.get_id.out + "->" + "[" + cr.item.out + "]")
				Result.append ("%N")
			end
		end

	print_message_states: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Message state:" + "%N")
			across
				messages as m_cr
			loop
				across
					users as u_cr
				loop
					Result.append ("      ")
					if u_cr.item.has_in_inbox (m_cr.item.get_id) then
						Result.append ("(" + u_cr.item.get_id.out + ", " + m_cr.item.get_id.out + ")" + "->" + u_cr.item.get_from_inbox (m_cr.item.get_id))
					else
						Result.append ("(" + u_cr.item.get_id.out + ", " + m_cr.item.get_id.out + ")" + "->" + states.unavailable)
					end
					Result.append ("%N")
				end
			end
		end

	reset_output_variables
		do
			error_status := errors.ok

			error_message := ""

			read_message_output := ""

			query := ""

			query_warning := ""

			output_is_query := false

			query_list_warning := ""

			query_name_list := ""

			output_is_query_name_list := false
		end
invariant
	user_trees_coincide:
		across users as cr all users_name.has (cr.item) end
		across users_name as cr all users.has (cr.item.get_id) end

	group_trees_coincide:
		across groups as cr all groups_name.has (cr.item) end
		across groups_name as cr all groups.has (cr.item.get_id) end


end




