% No need for "views" like article or qa because of "voters"
-record(poll, {id, question, detail, choices, votes, voters, user_id, ip, created_at}).
