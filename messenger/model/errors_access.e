note
	description: "ERRORS accessor."
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

expanded class
	ERRORS_ACCESS

feature
	m: ERRORS
		once
			create Result.make
		end

invariant
	m = m
end
