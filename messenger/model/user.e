note
	description: "Class that represents a user."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

class
	USER

inherit
	COMPARABLE
		redefine
			is_less
		end

create
	make

feature {NONE} -- Initialization

	make (uid: INTEGER_64; n: STRING)
			-- Initialization for `Current'.
		local
			comparator: KL_COMPARABLE_COMPARATOR[INTEGER_64]
		do
			id := uid
			create name.make_from_string (n)
			create groups.make
			create comparator.make
			create inbox.make (comparator)
		end

feature{NONE} -- Attributes
	id: INTEGER_64

	name: STRING

	groups: SORTED_TWO_WAY_LIST[INTEGER_64] -- list of group_id's

	inbox: DS_RED_BLACK_TREE[STRING, INTEGER_64] -- message_id -> state

feature{USER, MESSENGER_ADT, STUDENT_TESTS} -- Queries
	is_less alias "<" (other: like Current): BOOLEAN
		do
			if name < other.get_name then
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

	get_groups: SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			Result := groups
		end

	has_group (gid: INTEGER_64): BOOLEAN
		do
			Result := groups.has (gid)
		end

	get_inbox: DS_RED_BLACK_TREE[STRING, INTEGER_64]
		do
			Result := inbox
		end

	has_in_inbox (mid: INTEGER_64): BOOLEAN
		do
			Result := inbox.has (mid)
		end

	get_from_inbox (mid: INTEGER_64): STRING
		require
			has_in_inbox (mid)
		do
			Result := inbox.at (mid)
		end

feature{MESSENGER_ADT, STUDENT_TESTS} -- Commands

	add_group (gid: INTEGER_64)
		do
			groups.extend (gid)
		end

	put_in_inbox (mid: INTEGER_64; state: STRING)
		do
			inbox.put_new (state, mid)
		end

	remove_from_inbox (mid: INTEGER_64)
		require
			has_in_inbox (mid)
		do
			inbox.remove (mid)
		end

	change_in_inbox (mid: INTEGER_64; state: STRING)
		require
			has_in_inbox (mid)
		do
			inbox.replace (state, mid)
		end

end
