% No need for "views" like article or qa because there is "votes"
-record(poll, {id, user_id, ip, created_at, question, choices, deadline_on, votes, voters}).
