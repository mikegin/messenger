note
	description: "STATE accessor."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

expanded class
	STATE_ACCESS

feature
	m: STATE
		once
			create Result.make
		end

invariant
	m = m

end
