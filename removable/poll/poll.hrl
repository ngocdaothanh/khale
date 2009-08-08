% No need for "views" like article or qa because of "voters"
-record(poll, {id, user_id, ip, created_at, question, detail, choices, votes, voters}).
