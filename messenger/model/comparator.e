note
	description: "Summary description for {COMPARATOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COMPARATOR

inherit
	KL_COMPARATOR[INTEGER_64]

create
	make

feature -- Initialization
	make
		do

		end

feature
	less_than (u, v: INTEGER_64): BOOLEAN
		do
			Result := u < v
		end

end
