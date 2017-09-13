note
	description: "Class that houses possible message states."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STATE

create{STATE_ACCESS}
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create read.make_from_string("read")
			create unread.make_from_string("unread")
			create unavailable.make_from_string ("unavailable")
		end

feature -- Attributes
	read: STRING

	unread: STRING

	unavailable: STRING
end
