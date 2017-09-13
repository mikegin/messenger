note
	description: "Class that represents a group."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

class
	GROUP

inherit
	COMPARABLE
		redefine
			is_less
		end

create
	make

feature {NONE} -- Initialization

	make (gid: INTEGER_64; n: STRING)
			-- Initialization for `Current'.
		do
			id := gid
			create name.make_from_string (n)
			create users.make
			create messages.make
		end

feature {NONE} -- Attributes
	id: INTEGER_64

	name: STRING

	users: SORTED_TWO_WAY_LIST[INTEGER_64] -- list of user_id's

	messages: SORTED_TWO_WAY_LIST[INTEGER_64] -- list of message_id's

feature{GROUP, MESSENGER_ADT, STUDENT_TESTS} -- Queries
	is_less alias "<" (other: like Current): BOOLEAN
		do
			if  name < other.get_name then
				Result := True
			elseif name ~ other.get_name and id < other.get_id then
				Result := True
			end
		end

	get_id: INTEGER_64
		do
			Result := id
		end

	get_name: STRING
		do
			Result := name
		end

	get_users: SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			Result := users
		end

	has_user (uid: INTEGER_64): BOOLEAN
		do
			Result := users.has (uid)
		end

	has_message (message_id: INTEGER_64): BOOLEAN
		do
			Result := messages.has (message_id)
		end

feature{MESSENGER_ADT, STUDENT_TESTS} -- Commands

	add_message (mid: INTEGER_64)
		do
			messages.extend (mid)
		end

	add_user (uid: INTEGER_64)
		do
			users.extend (uid)
		end


end
