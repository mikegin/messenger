note
	description: "Summary description for {OUTPUT_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	OUTPUT_HANDLER

inherit
	ANY
		redefine out end

create
	make

feature -- Initialization
	make
		local
			messenger_access: MESSENGER_ACCESS
			errors_access: ERRORS_ACCESS
			state_access: STATE_ACCESS
		do
			m := messenger_access.m

			--output handling
			output_counter := 1
			errors := errors_access.m
			create error_status.make_from_string (errors.ok)
			create error_message.make_empty
			states := state_access.m
			create read_message_output.make_empty
			create query.make_empty
			create query_warning.make_empty
		end

feature -- Attributes
	m: MESSENGER

	errors: ERRORS

	error_status: STRING

	error_message: STRING

	output_counter: INTEGER_64

	states: STATE

	read_message_output: STRING

	query: STRING

	query_warning: STRING

	output_is_query: BOOLEAN

	need_extra_error_space: BOOLEAN

feature -- Commands
	set_extra_error_space
		do
			need_extra_error_space := true
			output_is_query := true
		end

	set_query_warning (s: STRING)
		do
			query_warning := s
			output_is_query := true
		end

	set_error_message (s: STRING)
		do
			error_message := s
			error_status := errors.error
		end

	set_read_message_output (uid: INTEGER_64; mid: INTEGER_64)
		do
			read_message_output.append ("Message for user [" + uid.out + ", " + m.users.at (uid).name + "]: ")
			read_message_output.append ("[" + mid.out + ", %"" + m.messages.at (mid).txt + "%"]")
		end

feature -- Queries
	out : STRING
		do
			--first line
			create Result.make_from_string ("  ")
			Result.append (output_counter.out + ":  ")
			Result.append (error_status)
			if error_status ~ errors.error then
				if need_extra_error_space then
					Result.append(errors.w_extra_space)
				end

				--reset
				need_extra_error_space := false
				output_is_query := false
			end
			Result.append ("%N")

			--after first line
			if not (output_counter = 0) then
				if error_status ~ errors.error then
					Result.append(print_error_message)
				elseif error_status ~ errors.ok then
					if output_is_query then
						Result.append(print_query_message)
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

			output_counter := output_counter + 1
		end

	print_read_message_output: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append (read_message_output)
			Result.append ("%N")

			--reset
			read_message_output := ""
		end

	print_error_message: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append (error_message)
			Result.append("%N")

			--reset
			error_status := errors.ok
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

			--reset
			query := ""
			query_warning := ""
			output_is_query := false
		end

	print_users_list: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Users:" + "%N")
			across
				m.users as cr
			loop
				Result.append ("      ")
				Result.append (cr.item.id.out + "->" + cr.item.name)
				Result.append ("%N")
			end
		end

	print_groups_list: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Groups:" + "%N")
			across
				m.groups as cr
			loop
				Result.append ("      ")
				Result.append (cr.item.id.out + "->" + cr.item.name)
				Result.append ("%N")
			end
		end

	print_registrations_list: STRING
		local
			reg_it: INTEGER_64
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Registrations:" + "%N")

			reg_it := 1
			across -- print users
				m.users as cr
			loop
				if cr.item.groups.count /= 0 then
					Result.append ("      ")
					Result.append ("[" + cr.item.id.out + ", " + cr.item.name + "]" + "->")
					Result.append ("{")

					reg_it := 1
					across -- print user's groups
						cr.item.groups as g_cr
					loop
						Result.append (g_cr.item.id.out + "->" + g_cr.item.name)
						if reg_it /= cr.item.groups.count then
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
				m.messages as cr
			loop
				Result.append ("      ")
				Result.append (cr.item.id.out + "->" + "[" + cr.item.out + "]")
				Result.append ("%N")
			end
		end

	print_message_states: STRING
		do
			create Result.make_empty
			Result.append ("  ")
			Result.append("Message state:" + "%N")
			across
				m.messages as m_cr
			loop
				across
					m.users as u_cr
				loop
					Result.append ("      ")
					if u_cr.item.inbox.has (m_cr.item.id) then
						Result.append ("(" + u_cr.item.id.out + ", " + m_cr.item.id.out + ")" + "->" + u_cr.item.inbox.at (m_cr.item.id))
					else
						Result.append ("(" + u_cr.item.id.out + ", " + m_cr.item.id.out + ")" + "->" + states.unavailable)
					end
					Result.append ("%N")
				end
			end
		end

feature -- user queries Commands
	list_new_messages (uid: INTEGER_64)
		require
			m.id_positive (uid)
			m.user_exists (uid)
			m.has_new_messages (uid)
		do
			output_is_query := true

			query.append ("New/unread messages for user [" + uid.out + ", " + m.users.at (uid).name + "]:" + "%N")
			across
				m.users.at (uid).inbox as cr
			loop
				if cr.item ~ states.unread then
					query.append ("      ")
					query.append (cr.key.out + "->" + "[" + m.messages.at (cr.key).out + "]")
					query.append ("%N")
				end
			end
		end

	list_old_messages (uid: INTEGER_64)
		require
			m.id_positive (uid)
			m.user_exists (uid)
			m.has_old_messages (uid)
		do

		end

	list_users
		do

		end

	list_groups
		do

		end

end
