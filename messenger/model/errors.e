note
	description: "Class housing errors and warnings"
	author: "Mikhail Gindin"
	date: "$Date$"
	revision: "$Revision$"

class
	ERRORS

create
	make

feature{NONE} -- Initialization
	make
		do

		end

feature -- list of errors
	ok: STRING = "OK"
	error: STRING = "ERROR "
	id_must_be_positive: STRING = "ID must be a positive integer."
    id_in_use: STRING = "ID already in use."
    user_name_starts_with_letter: STRING = "User name must start with a letter."
    group_name_starts_with_letter: STRING = "Group name must start with a letter."
    user_not_exists: STRING = "User with this ID does not exist."
    group_not_exists: STRING = "Group with this ID does not exist."
    registration_already_exists: STRING = "This registration already exists."
    message_empty: STRING = "A message may not be an empty string."
    not_authorized_group: STRING = "User not authorized to send messages to the specified group."
	message_not_exists: STRING = "Message with this ID does not exist."
	user_not_authorized: STRING = "User not authorized to access this message."
    message_id_unavailable: STRING = "Message with this ID unavailable."
    already_read: STRING = "Message has already been read. See `list_old_messages'."
    old_message_not_found: STRING = "Message with this ID not found in old/read messages."
    incorrect_message_length: STRING = "Message length must be greater than zero."

feature -- list of warnings
	w_no_new_messages: STRING = "There are no new messages for this user."
	w_no_old_messages: STRING = "There are no old messages for this user."
	w_no_groups_registered: STRING = "There are no groups registered in the system yet."
	w_no_users_registered: STRING = "There are no users registered in the system yet."

end
