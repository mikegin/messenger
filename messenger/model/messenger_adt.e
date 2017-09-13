note
	description: "Abstract Messenger that handles contracting."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MESSENGER_ADT

feature -- Attributes
	adt_users: FUN[INTEGER_64, USER] -- abstract users storage

	adt_groups: FUN[INTEGER_64, GROUP] -- abstract groups storage

	adt_messages: FUN[INTEGER_64, MESSAGE] -- abstract messages storage

	adt_registrations: REL[INTEGER_64, INTEGER_64] -- abstract registrations storage

	mid_counter: INTEGER_64 -- message id counter

	state_a: STATE_ACCESS

feature -- Commands
	add_user (uid: INTEGER_64; user_name: STRING)
			--adds a user to the system
		require
			id_positive (uid)
			not user_exists (uid)
			name_starts_with_letter (user_name)
		deferred
		ensure
			adt_users ~ old adt_users @<+ [uid, create {USER}.make (uid, user_name)]
		end

	add_group (gid: INTEGER_64; group_name: STRING)
			--adds a group to the system
		require
			id_positive (gid)
			not group_exists (gid)
			name_starts_with_letter (group_name)
		deferred
		ensure
			adt_groups ~ old adt_groups @<+ [gid, create {GROUP}.make (gid, group_name)]
		end

	register_user (uid: INTEGER_64; gid: INTEGER_64)
			--registers a user in a group
		require
			id_positive (uid) and id_positive (gid)
			user_exists (uid)
			group_exists (gid)
			not registration_exists (uid, gid)
		deferred
		ensure
			adt_registrations ~ old adt_registrations + [uid, gid]
		end

	send_message (uid: INTEGER_64; gid: INTEGER_64; txt: STRING)
			--sends a message from the user to the users in the group
		require
			id_positive (uid) and id_positive (gid)
			user_exists (uid)
			group_exists (gid)
			not message_empty (txt)
			registration_exists (uid, gid)
		deferred
		ensure
			adt_messages ~ old adt_messages + [mid_counter - 1, create {MESSAGE}.make (mid_counter - 1, uid, gid, txt)] -- function override doesn't work. why?

			group_has_message: adt_groups[gid].has_message (mid_counter - 1)

			correctly_sent: across adt_groups[gid].get_users as cr
				all
					adt_users[cr.item].get_id = uid implies adt_users[cr.item].get_from_inbox (mid_counter - 1) ~ state_a.m.read
					and
					adt_users[cr.item].get_id /= uid implies adt_users[cr.item].get_from_inbox (mid_counter -1) ~ state_a.m.unread
				end
		end

	read_message (uid: INTEGER_64; mid: INTEGER_64)
			--reads the user's message
		require
			id_positive (uid) and id_positive (mid)
			user_exists (uid)
			message_exists (mid)
			authorized_message_access (uid, mid)
			not message_unavailable (uid, mid)
			not message_already_read (uid, mid)
		deferred
		ensure
			adt_users[uid].get_from_inbox (mid) ~ state_a.m.read
		end

	delete_message (uid: INTEGER_64; mid: INTEGER_64)
			--deletes the user's message
		require
			id_positive (uid) and id_positive (mid)
			user_exists (uid)
			message_exists (mid)
			message_id_found_in_old_messages (uid, mid)
		deferred
		ensure
			not adt_users[uid].has_in_inbox (mid)
		end

	set_message_preview (n: INTEGER_64)
			--sets the message preview character amount across all messages
		require
			correct_message_length (n)
		deferred
		ensure
			across adt_messages as cr all adt_messages.item (cr.item.first).get_msg_prev = n end
		end

feature -- output Commands
	list_new_messages (uid: INTEGER_64)
			--formats the output to list the new messages of the user
		require
			id_positive (uid)
			user_exists (uid)
			has_new_messages (uid)
		deferred
		end

	list_old_messages (uid: INTEGER_64)
				--formats the output to list the old messages of the user
		require
			id_positive (uid)
			user_exists (uid)
			has_old_messages (uid)
		deferred
		end

	list_users
			--formats the output to list all users
		deferred
		end

	list_groups
			--formats the output to list all groups
		deferred
		end

feature -- Queries
	id_positive (id: INTEGER_64): BOOLEAN
			--checks if the id is positive
		deferred
		end

	name_starts_with_letter (name: STRING): BOOLEAN
			--checks if the name starts with a letter
		deferred
		end

	user_exists (id: INTEGER_64): BOOLEAN
			--checks if the user exists
		deferred
		end

	group_exists (id: INTEGER_64): BOOLEAN
			--checks if the group exists
		deferred
		end

	message_exists (id: INTEGER_64): BOOLEAN
			--checks if the message exists
		deferred
		end

	registration_exists (uid: INTEGER_64; gid: INTEGER_64): BOOLEAN
			--checks if the user is registered in the group
		require
			user_exists(uid) and group_exists(gid)
		deferred
		end

	message_empty (txt: STRING): BOOLEAN
			--checks if a message is empty
		deferred
		end

	authorized_message_access (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
			--checks if the user is authorized to access the message
		require
			user_exists(uid)
			message_exists(mid)
		deferred
		end

	message_unavailable (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
			--checks if the message is unavailable to the user
		require
			user_exists(uid)
			message_exists(mid)
		deferred
		end

	message_already_read (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
			--checks if the user's message is read
		require
			message_exists(mid)
			authorized_message_access(uid, mid)
		deferred
		end

	message_id_found_in_old_messages (uid: INTEGER_64; mid: INTEGER_64): BOOLEAN
			--checks if the mid is found in the users inbox
		require
			user_exists(uid)
			message_exists(mid)
		deferred
		end

	correct_message_length (n: INTEGER_64): BOOLEAN
			--checks if the message length is correct
		deferred
		end

	has_old_messages (uid: INTEGER_64): BOOLEAN
			--checks if the user has old messages
		deferred
		end

	has_new_messages (uid: INTEGER_64): BOOLEAN
			--checks if the user has new messages
		deferred
		end

	users_exist: BOOLEAN
			--checks if a user exists
		deferred
		end

	groups_exist: BOOLEAN
			--checks if a group exists
		deferred
		end

end
