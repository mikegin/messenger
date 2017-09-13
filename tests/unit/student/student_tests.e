note
	description: "Summary description for {STUDENT_TESTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STUDENT_TESTS

inherit
	ES_TEST

create
	make

feature{NONE} -- Initialization
	make
		do
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)
			add_boolean_case (agent t4)
			add_boolean_case (agent t5)
			add_boolean_case (agent t6)
			add_boolean_case (agent t7)
			add_boolean_case (agent t8)
		end

feature -- Tests
	t1: BOOLEAN
		local
			m: MESSENGER_ACCESS
			uid: INTEGER_64
			user_name: STRING
			user: USER
		do
			comment("t1: Test add_user")
			uid := 4
			create user_name.make_from_string ("Bob")
			m.m.add_user (uid, user_name)

			user := m.m.users.at (uid)

			Result := user.get_id = uid and user.get_name ~ user_name
			m.m.reset
		end

	t2: BOOLEAN
		local
			m: MESSENGER_ACCESS
			gid: INTEGER_64
			group_name: STRING
			group: GROUP
		do
			comment("t2: Test add_group")
			gid := 4
			create group_name.make_from_string ("Nurses")
			m.m.add_group (gid, group_name)

			group := m.m.groups.at (gid)

			Result := group.get_id = gid and group.get_name ~ group_name
			m.m.reset
		end

	t3: BOOLEAN
		local
			m: MESSENGER_ACCESS
			uid1: INTEGER_64
			uid2: INTEGER_64
			user_name1: STRING
			user_name2: STRING
			gid1: INTEGER_64
			gid2: INTEGER_64
			group_name1: STRING
			group_name2: STRING
		do
			comment("t3: Test register_user")

			uid1 := 2
			create user_name1.make_from_string ("Bob")
			m.m.add_user (uid1, user_name1)

			uid2 := 3
			create user_name2.make_from_string ("Tim")
			m.m.add_user (uid2, user_name2)

			gid1 := 4
			create group_name1.make_from_string ("Nurses")
			m.m.add_group (gid1, group_name1)

			gid2 := 5
			create group_name2.make_from_string ("Doctors")
			m.m.add_group (gid2, group_name2)

			m.m.register_user (uid1, gid1)
			m.m.register_user (uid1, gid2)
			m.m.register_user (uid2, gid1)

			Result := m.m.users.at (uid1).has_group (gid1) and m.m.groups.at (gid1).has_user (uid1) and
				m.m.users.at (uid1).has_group (gid2) and m.m.groups.at (gid2).has_user (uid1) and
				m.m.users.at (uid2).has_group (gid1) and m.m.groups.at (gid1).has_user (uid2)

			m.m.reset
		end

	t4: BOOLEAN
		local
			m: MESSENGER_ACCESS
			uid1: INTEGER_64
			uid2: INTEGER_64
			user_name1: STRING
			user_name2: STRING
			gid: INTEGER_64
			group_name: STRING
			txt: STRING
			message: MESSAGE
			state_access: STATE_ACCESS
		do
			comment("t4: Test send_message")
			uid1 := 2
			create user_name1.make_from_string ("Bob")
			m.m.add_user (uid1, user_name1)

			uid2 := 3
			create user_name2.make_from_string ("Sam")
			m.m.add_user (uid2, user_name2)

			gid := 4
			create group_name.make_from_string ("Nurses")
			m.m.add_group (gid, group_name)

			m.m.register_user (uid1, gid)
			m.m.register_user (uid2, gid)

			create txt.make_from_string ("My message")
			m.m.send_message (uid1, gid, txt)

			message := m.m.messages.at (1)

			Result := message.get_id = 1 and message.get_txt ~ txt and m.m.users.at (uid1).get_from_inbox (1) ~ state_access.m.read and m.m.users.at (uid2).get_from_inbox (1) ~ state_access.m.unread and m.m.groups.at (gid).has_message (1)

			m.m.reset
		end

	t5: BOOLEAN
		local
			m: MESSENGER_ACCESS
			uid1: INTEGER_64
			uid2: INTEGER_64
			user_name1: STRING
			user_name2: STRING
			gid: INTEGER_64
			group_name: STRING
			txt: STRING
			state_access: STATE_ACCESS
		do
			comment("t5: Test read_message")
			uid1 := 2
			create user_name1.make_from_string ("Bob")
			m.m.add_user (uid1, user_name1)

			uid2 := 3
			create user_name2.make_from_string ("Sam")
			m.m.add_user (uid2, user_name2)

			gid := 4
			create group_name.make_from_string ("Nurses")
			m.m.add_group (gid, group_name)

			m.m.register_user (uid1, gid)
			m.m.register_user (uid2, gid)

			create txt.make_from_string ("My message")
			m.m.send_message (uid1, gid, txt)

			m.m.read_message (uid2, 1)

			Result := m.m.users.at (uid2).get_from_inbox (1) ~ state_access.m.read

			m.m.reset
		end

		t6: BOOLEAN
			local
				m: MESSENGER_ACCESS
				uid1: INTEGER_64
				uid2: INTEGER_64
				user_name1: STRING
				user_name2: STRING
				gid: INTEGER_64
				group_name: STRING
				txt: STRING
			do
				comment("t6: Test delete_message")
				uid1 := 2
				create user_name1.make_from_string ("Bob")
				m.m.add_user (uid1, user_name1)

				uid2 := 3
				create user_name2.make_from_string ("Sam")
				m.m.add_user (uid2, user_name2)

				gid := 4
				create group_name.make_from_string ("Nurses")
				m.m.add_group (gid, group_name)

				m.m.register_user (uid1, gid)
				m.m.register_user (uid2, gid)

				create txt.make_from_string ("My message")
				m.m.send_message (uid1, gid, txt)

				m.m.read_message (uid2, 1)

				m.m.delete_message (uid2, 1)

				Result := not m.m.users.at (uid2).has_in_inbox (1)

				m.m.reset
			end

		t7: BOOLEAN
			local
				m: MESSENGER_ACCESS
				uid1: INTEGER_64
				uid2: INTEGER_64
				user_name1: STRING
				user_name2: STRING
				gid: INTEGER_64
				group_name: STRING
				txt: STRING
				message: MESSAGE
			do
				comment("t7: Test set_message_preview")
				uid1 := 2
				create user_name1.make_from_string ("Bob")
				m.m.add_user (uid1, user_name1)

				uid2 := 3
				create user_name2.make_from_string ("Sam")
				m.m.add_user (uid2, user_name2)

				gid := 4
				create group_name.make_from_string ("Nurses")
				m.m.add_group (gid, group_name)

				m.m.register_user (uid1, gid)
				m.m.register_user (uid2, gid)

				create txt.make_from_string ("My message is more than 15 characters.")
				m.m.send_message (uid1, gid, txt)

				message := m.m.messages.at (1)

				m.m.set_message_preview (20)

				sub_comment("<br /><br /> " + message.out)

				Result := message.get_msg_prev = 20

				m.m.reset
			end

		t8: BOOLEAN
			local
				m: MESSENGER_ACCESS
				uid1: INTEGER_64
				uid2: INTEGER_64
				user_name1: STRING
				user_name2: STRING
				gid: INTEGER_64
				group_name: STRING
				txt: STRING
			do
				comment("t8: Test has_old_message and has_new_message")
				uid1 := 2
				create user_name1.make_from_string ("Bob")
				m.m.add_user (uid1, user_name1)

				uid2 := 3
				create user_name2.make_from_string ("Sam")
				m.m.add_user (uid2, user_name2)

				gid := 4
				create group_name.make_from_string ("Nurses")
				m.m.add_group (gid, group_name)

				m.m.register_user (uid1, gid)
				m.m.register_user (uid2, gid)

				create txt.make_from_string ("My message")
				m.m.send_message (uid1, gid, txt)

				Result := m.m.has_new_messages (uid2) and m.m.has_old_messages (uid1)

				m.m.reset
			end

end
