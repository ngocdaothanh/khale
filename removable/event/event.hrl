-record(event, {id, user_id, ip, created_at, updated_at, name, invitation, deadline, participants, views = 0}).
-record(participant, {user_id, participant_note, accepted = false, invitor_note}).
