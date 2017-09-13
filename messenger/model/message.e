note
	description: "Class that represents a message."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGE

inherit
	ANY
		redefine out end

create
	make

feature {NONE} -- Initialization

	make (mid: INTEGER_64; uid: INTEGER_64; gid: INTEGER_64; content: STRING)
			-- Initialization for `Current'.
		do
			id := mid
			sender := uid
			group := gid
			txt := content
			msg_prev := 15
		end

feature{NONE} -- Attributes
	id: INTEGER_64

	txt: STRING

	sender: INTEGER_64

	group: INTEGER_64

	msg_prev: INTEGER_64

feature -- Queries
	get_id: INTEGER_64
		do
			Result := id
		end

	get_txt: STRING
		do
			Result := txt
		end

	get_sender: INTEGER_64
		do
			Result := sender
		end

	get_group: INTEGER_64
		do
			Result := group
		end

	get_msg_prev: INTEGER_64
		do
			Result := msg_prev
		end

feature -- Commands
	set_message_prev(n: INTEGER_64)
		do
			msg_prev := n
		end

feature -- output
	out: STRING
		do
			create Result.make_empty
			Result.append ("sender: " + sender.out + ", ")
			Result.append ("group: " + group.out + ", ")
			Result.append ("content: ")
			if txt.count > msg_prev then
				Result.append("%"" +txt.substring (1, msg_prev.as_integer_32) + "..." + "%"") -- 64bit -> 32bit issue?
			else
				Result.append("%"" + txt + "%"")
			end
		end

end
