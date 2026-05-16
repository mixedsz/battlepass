-- ADD TASK COUNT FOR DAILY TASKS

-- FROM CLIENT SIDE
-- TriggerServerEvent('ak4y-battlepass:taskCountAdd:standart', taskId, count)



-- FROM SERVER SIDE 
-- TriggerClientEvent('ak4y-battlepass:addtaskcount:standart', source, taskId, count)

---------------------------------------------


-- ADD TASK COUNT FOR STABLE TASKS

-- FROM CLIENT SIDE
-- TriggerServerEvent('ak4y-battlepass:taskCountAdd:premium', taskId, count)


-- FROM SERVER SIDE
-- TriggerClientEvent('ak4y-battlepass:addtaskcount:premium', source, taskId, count)


--------------------------------------------


-- @ For Example How to use it

-- Check first daily task. it says type 'tasktry' in chat and its taskId = 1
-- {taskId = 1, requiredcount = 2, rewardXP = 1500, taskTitle = "Type 'tasktry' in chat", taskDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas porttitor."},

-- RegisterCommand('tasktry', function(source, args)
--     -- Here is client
--     -- first param 1, because taskId = 1
--     -- second param 1, because i will add just 1 count. if you type 2 you will add 2 count to task
--     -- this task is daily thats why i used ak4y-battlepass:taskCountAdd:standart
--     TriggerServerEvent('ak4y-battlepass:taskCountAdd:standart', 1, 1)
-- end)




-- Check second stable task. it says type 'taskstable' in chat and its taskId = 2
-- {taskId = 2, requiredcount = 2, rewardXP = 500, taskTitle = "Type 'stabletry' in chat", taskDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas porttitor."},

-- RegisterCommand('stabletry', function(source, args)
--     -- Here is client
--     -- first param 2, because taskId = 2
--     -- second param 1, because i will add just 1 count. if you type 2 you will add 2 count to task
--     -- this task is stable thats why i used ak4y-battlepass:taskCountAdd:premium
--     TriggerServerEvent('ak4y-battlepass:taskCountAdd:premium', 2, 1)
-- end)
