-- ak4y dev.

local ESX = nil

if AK4Y.Framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif AK4Y.Framework == "newEsx" or AK4Y.Framework == "errorEsx" then
    ESX = exports["es_extended"]:getSharedObject()
end

-- ─── Database bootstrap ───────────────────────────────────────────────────────

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `ak4y_battlepass` (
            `identifier`       VARCHAR(60)  NOT NULL,
            `currentXP`        INT(11)      NOT NULL DEFAULT 0,
            `prestige`         INT(11)      NOT NULL DEFAULT 0,
            `premium`          TINYINT(1)   NOT NULL DEFAULT 0,
            `standartTasks`    LONGTEXT,
            `premiumTasks`     LONGTEXT,
            `rewards`          LONGTEXT,
            `standartResetTime` BIGINT(20)  NOT NULL DEFAULT 0,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `ak4y_battlepass_codes` (
            `code`   VARCHAR(36) NOT NULL,
            `used`   TINYINT(1)  NOT NULL DEFAULT 0,
            `usedBy` VARCHAR(60) DEFAULT NULL,
            PRIMARY KEY (`code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function getDiscordId(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 8) == "discord:" then
            return string.sub(id, 9)
        end
    end
    return nil
end

local function getBpEndDateString()
    local months = {
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    }
    local d = AK4Y.BPEndDate
    return months[d.month] .. " " .. d.day .. ", " .. d.year
end

local function sendDiscordWebhook(title, description, color)
    if not AK4Y.Discord_Webhook or AK4Y.Discord_Webhook == "" then return end
    PerformHttpRequest(
        AK4Y.Discord_Webhook,
        function() end,
        'POST',
        json.encode({
            username = "AK4Y BattlePass",
            embeds = {{
                title       = title,
                description = description,
                color       = color or 3447003,
                timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

-- Build a fresh standartTasks array from config
local function buildDefaultStandartTasks()
    local t = {}
    for _, task in ipairs(AK4Y.BattlePassTasks) do
        t[#t + 1] = { taskId = task.taskId, hasCount = 0, taken = false }
    end
    return t
end

-- Build a fresh premiumTasks array from config
local function buildDefaultPremiumTasks()
    local t = {}
    for _, task in ipairs(AK4Y.DailyPremiumTasks) do
        t[#t + 1] = { taskId = task.taskId, hasCount = 0, taken = false }
    end
    return t
end

-- Build a fresh rewards array from config (one entry per BattlePassItems row)
local function buildDefaultRewards()
    local r = {}
    for _ in ipairs(AK4Y.BattlePassItems) do
        r[#r + 1] = { rewards = { standart = { taken = false } } }
    end
    return r
end

-- Reset daily standart tasks (clear hasCount & taken, keep taskId)
local function resetStandartTasks(tasks)
    local r = {}
    for _, task in ipairs(tasks) do
        r[#r + 1] = { taskId = task.taskId, hasCount = 0, taken = false }
    end
    return r
end

-- Derive current level from raw XP
local function getLevel(xp)
    return math.floor(xp / AK4Y.RequiredXpForNextLevel)
end

-- ─── Server Callbacks ─────────────────────────────────────────────────────────

-- Returns all battlepass data needed by the UI
ESX.RegisterServerCallback("ak4y-battlePass:getPlayerDetails", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(nil) return end

    local identifier  = xPlayer.getIdentifier()
    local result      = MySQL.query.await('SELECT * FROM ak4y_battlepass WHERE identifier = ?', { identifier })
    local currentTime = os.time()
    local playerRow

    if #result == 0 then
        -- First time this player opens the battlepass — initialise their row
        local standartTasks = buildDefaultStandartTasks()
        local premiumTasks  = buildDefaultPremiumTasks()
        local rewards       = buildDefaultRewards()

        MySQL.insert.await(
            'INSERT INTO ak4y_battlepass (identifier, currentXP, prestige, premium, standartTasks, premiumTasks, rewards, standartResetTime) VALUES (?, 0, 0, 0, ?, ?, ?, ?)',
            { identifier, json.encode(standartTasks), json.encode(premiumTasks), json.encode(rewards), currentTime }
        )

        playerRow = {
            identifier       = identifier,
            currentXP        = 0,
            prestige         = 0,
            premium          = 0,
            standartTasks    = json.encode(standartTasks),
            premiumTasks     = json.encode(premiumTasks),
            rewards          = json.encode(rewards),
            standartResetTime = currentTime,
        }
    else
        playerRow = result[1]
    end

    -- Daily task reset check
    local resetPeriod = AK4Y.DailyTasksResetPeriod * 86400
    if currentTime - playerRow.standartResetTime >= resetPeriod then
        local currentTasks = json.decode(playerRow.standartTasks)
        local resetTasks   = resetStandartTasks(currentTasks)
        local resetJson    = json.encode(resetTasks)

        MySQL.update.await(
            'UPDATE ak4y_battlepass SET standartTasks = ?, standartResetTime = ? WHERE identifier = ?',
            { resetJson, currentTime, identifier }
        )
        playerRow.standartTasks    = resetJson
        playerRow.standartResetTime = currentTime
    end

    -- Next daily reset timestamp (milliseconds for JavaScript Date)
    local nextResetMs = (playerRow.standartResetTime + AK4Y.DailyTasksResetPeriod * 86400) * 1000

    cb({
        playerData = {
            currentXP       = playerRow.currentXP,
            prestige        = playerRow.prestige,
            premium         = playerRow.premium == 1,
            standartTasks   = playerRow.standartTasks,
            premiumTasks    = playerRow.premiumTasks,
            rewards         = playerRow.rewards,
            standartResetTime = nextResetMs,
        },
        apiKey    = "",
        discordid = getDiscordId(source),
        charInfo  = xPlayer.getName(),
        resetDate = getBpEndDateString(),
    })
end)

-- ─── Reward claiming ──────────────────────────────────────────────────────────

local function giveReward(xPlayer, source, rewardType, itemName, count, carData)
    if rewardType == "money" then
        xPlayer.addMoney(count)
    elseif rewardType == "black_money" then
        xPlayer.addAccountMoney('black_money', count)
    elseif rewardType == "bank" then
        xPlayer.addAccountMoney('bank', count)
    elseif rewardType == "item" then
        xPlayer.addInventoryItem(itemName, count)
    elseif rewardType == "vehicle" and carData then
        -- Vehicle reward: hand off to client to handle garage/spawn
        TriggerClientEvent('ak4y-battlepass:receiveVehicle', source, carData)
    end
end

ESX.RegisterServerCallback("ak4y-battlePass:getStandartRewards", function(source, cb, data, carData)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    local identifier = xPlayer.getIdentifier()
    local reqLevel   = tonumber(data.reqLevel)
    local reqTaskId  = tonumber(data.reqTaskId)
    local details    = data.itemDetails

    local result = MySQL.query.await('SELECT currentXP, rewards FROM ak4y_battlepass WHERE identifier = ?', { identifier })
    if #result == 0 then cb(false) return end

    local playerRow = result[1]

    -- Level check
    if getLevel(playerRow.currentXP) < reqLevel then cb(false) return end

    -- Locate the reward index in our config array
    local rewardIndex = nil
    for i, item in ipairs(AK4Y.BattlePassItems) do
        if item.taskId == reqTaskId then
            rewardIndex = i
            break
        end
    end
    if not rewardIndex then cb(false) return end

    local rewards = json.decode(playerRow.rewards)
    if not rewards[rewardIndex] then cb(false) return end
    if rewards[rewardIndex].rewards.standart.taken then cb(false) return end

    -- Give the reward
    giveReward(xPlayer, source, details.type, details.itemName, details.count, carData)

    -- Mark as claimed
    rewards[rewardIndex].rewards.standart.taken = true
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET rewards = ? WHERE identifier = ?',
        { json.encode(rewards), identifier }
    )

    if AK4Y.Server.LogRewardClaims then
        sendDiscordWebhook(
            "Reward Claimed",
            "**Player:** " .. GetPlayerName(source) ..
            "\n**Reward:** " .. (details.itemLabel or details.itemName) .. " x" .. details.count ..
            "\n**Level:** " .. reqLevel,
            3447003
        )
    end

    cb(true)
end)

ESX.RegisterServerCallback("ak4y-battlePass:getPremiumRewards", function(source, cb, data, carData)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    local identifier = xPlayer.getIdentifier()
    local reqLevel   = tonumber(data.reqLevel)
    local reqTaskId  = tonumber(data.reqTaskId)
    local details    = data.itemDetails

    local result = MySQL.query.await('SELECT currentXP, premium, rewards FROM ak4y_battlepass WHERE identifier = ?', { identifier })
    if #result == 0 then cb(false) return end

    local playerRow = result[1]
    if playerRow.premium ~= 1 then cb(false) return end
    if getLevel(playerRow.currentXP) < reqLevel then cb(false) return end

    local rewardIndex = nil
    for i, item in ipairs(AK4Y.BattlePassItems) do
        if item.taskId == reqTaskId then
            rewardIndex = i
            break
        end
    end
    if not rewardIndex then cb(false) return end

    local rewards = json.decode(playerRow.rewards)
    if not rewards[rewardIndex] then cb(false) return end
    if not rewards[rewardIndex].rewards.premium then cb(false) return end
    if rewards[rewardIndex].rewards.premium.taken then cb(false) return end

    giveReward(xPlayer, source, details.type, details.itemName, details.count, carData)

    rewards[rewardIndex].rewards.premium.taken = true
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET rewards = ? WHERE identifier = ?',
        { json.encode(rewards), identifier }
    )

    cb(true)
end)

-- ─── Task completion (XP grant) ───────────────────────────────────────────────

ESX.RegisterServerCallback("ak4y-battlePass:standartTaskDone", function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    local identifier = xPlayer.getIdentifier()
    local taskId     = tonumber(data.taskId)

    local result = MySQL.query.await(
        'SELECT standartTasks, currentXP FROM ak4y_battlepass WHERE identifier = ?',
        { identifier }
    )
    if #result == 0 then cb(false) return end

    local playerRow    = result[1]
    local standartTasks = json.decode(playerRow.standartTasks)

    -- Find the task in the player's saved array
    local taskIndex = nil
    for i, t in ipairs(standartTasks) do
        if t.taskId == taskId then taskIndex = i break end
    end

    -- Find the task definition in config
    local taskConfig = nil
    for _, t in ipairs(AK4Y.BattlePassTasks) do
        if t.taskId == taskId then taskConfig = t break end
    end

    if not taskIndex or not taskConfig then cb(false) return end
    if standartTasks[taskIndex].taken then cb(false) return end
    if standartTasks[taskIndex].hasCount < taskConfig.requiredcount then cb(false) return end

    -- Award XP and mark task taken
    standartTasks[taskIndex].taken = true
    local newXP = playerRow.currentXP + taskConfig.rewardXP

    MySQL.update.await(
        'UPDATE ak4y_battlepass SET standartTasks = ?, currentXP = ? WHERE identifier = ?',
        { json.encode(standartTasks), newXP, identifier }
    )

    -- Return the XP amount so the client can update the progress bar
    cb(taskConfig.rewardXP)
end)

ESX.RegisterServerCallback("ak4y-battlePass:premiumTaskDone", function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    local identifier  = xPlayer.getIdentifier()
    local taskId      = tonumber(data.taskId)

    local result = MySQL.query.await(
        'SELECT premiumTasks, currentXP, premium FROM ak4y_battlepass WHERE identifier = ?',
        { identifier }
    )
    if #result == 0 then cb(false) return end

    local playerRow  = result[1]
    if playerRow.premium ~= 1 then cb(false) return end

    local premiumTasks = json.decode(playerRow.premiumTasks)

    local taskIndex = nil
    for i, t in ipairs(premiumTasks) do
        if t.taskId == taskId then taskIndex = i break end
    end

    local taskConfig = nil
    for _, t in ipairs(AK4Y.DailyPremiumTasks) do
        if t.taskId == taskId then taskConfig = t break end
    end

    if not taskIndex or not taskConfig then cb(false) return end
    if premiumTasks[taskIndex].taken then cb(false) return end
    if premiumTasks[taskIndex].hasCount < taskConfig.requiredcount then cb(false) return end

    premiumTasks[taskIndex].taken = true
    local newXP = playerRow.currentXP + taskConfig.rewardXP

    MySQL.update.await(
        'UPDATE ak4y_battlepass SET premiumTasks = ?, currentXP = ? WHERE identifier = ?',
        { json.encode(premiumTasks), newXP, identifier }
    )

    cb(taskConfig.rewardXP)
end)

-- ─── Premium code redemption ──────────────────────────────────────────────────

ESX.RegisterServerCallback("ak4y-battlePass:sendInput", function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end

    local identifier = xPlayer.getIdentifier()
    local code       = tostring(data.input or "")

    -- Remove length restriction to support custom codes from bpaddcode
    if #code == 0 then cb(false) return end

    if AK4Y.UseTebexForPremiumCodes then
        -- Tebex-based validation requires a custom integration with the Tebex API.
        -- When ready, make an HTTP request to the Tebex headless API here, then
        -- call cb(true) on success or cb(false) on failure.
        print("[ak4y-battlepass] Tebex code validation not implemented.")
        cb(false)
        return
    end

    -- Custom code table validation
    local result = MySQL.query.await(
        'SELECT code FROM ak4y_battlepass_codes WHERE code = ? AND used = 0',
        { code }
    )
    if #result == 0 then cb(false) return end

    MySQL.update.await(
        'UPDATE ak4y_battlepass_codes SET used = 1, usedBy = ? WHERE code = ?',
        { identifier, code }
    )
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET premium = 1 WHERE identifier = ?',
        { identifier }
    )

    if AK4Y.Server.LogPremiumRedeem then
        sendDiscordWebhook(
            "Premium Code Redeemed",
            "**Player:** " .. GetPlayerName(source) .. "\n**Code:** " .. code,
            16776960
        )
    end

    cb(true)
end)

-- ─── Task count increments (triggered from client or other resources) ─────────

RegisterServerEvent('ak4y-battlepass:taskCountAdd:standart')
AddEventHandler('ak4y-battlepass:taskCountAdd:standart', function(taskId, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    taskId = tonumber(taskId)
    count  = tonumber(count)
    if not taskId or not count or count <= 0 then return end

    -- Validate taskId exists in config
    local taskConfig = nil
    for _, t in ipairs(AK4Y.BattlePassTasks) do
        if t.taskId == taskId then taskConfig = t break end
    end
    if not taskConfig then return end

    local identifier = xPlayer.getIdentifier()
    local result = MySQL.query.await(
        'SELECT standartTasks FROM ak4y_battlepass WHERE identifier = ?',
        { identifier }
    )
    if #result == 0 then return end

    local standartTasks = json.decode(result[1].standartTasks)
    for i, t in ipairs(standartTasks) do
        if t.taskId == taskId then
            if not t.taken then
                -- Clamp so we never exceed required count
                standartTasks[i].hasCount = math.min(t.hasCount + count, taskConfig.requiredcount)
            end
            break
        end
    end

    MySQL.update.await(
        'UPDATE ak4y_battlepass SET standartTasks = ? WHERE identifier = ?',
        { json.encode(standartTasks), identifier }
    )
end)

RegisterServerEvent('ak4y-battlepass:taskCountAdd:premium')
AddEventHandler('ak4y-battlepass:taskCountAdd:premium', function(taskId, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    taskId = tonumber(taskId)
    count  = tonumber(count)
    if not taskId or not count or count <= 0 then return end

    local taskConfig = nil
    for _, t in ipairs(AK4Y.DailyPremiumTasks) do
        if t.taskId == taskId then taskConfig = t break end
    end
    if not taskConfig then return end

    local identifier = xPlayer.getIdentifier()
    local result = MySQL.query.await(
        'SELECT premiumTasks, premium FROM ak4y_battlepass WHERE identifier = ?',
        { identifier }
    )
    if #result == 0 then return end
    if result[1].premium ~= 1 then return end

    local premiumTasks = json.decode(result[1].premiumTasks)
    for i, t in ipairs(premiumTasks) do
        if t.taskId == taskId then
            if not t.taken then
                premiumTasks[i].hasCount = math.min(t.hasCount + count, taskConfig.requiredcount)
            end
            break
        end
    end

    MySQL.update.await(
        'UPDATE ak4y_battlepass SET premiumTasks = ? WHERE identifier = ?',
        { json.encode(premiumTasks), identifier }
    )
end)

-- ─── Prestige ─────────────────────────────────────────────────────────────────

RegisterServerEvent('ak4y-battlepass:prestigePlayer')
AddEventHandler('ak4y-battlepass:prestigePlayer', function()
    local source  = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local identifier = xPlayer.getIdentifier()
    local result = MySQL.query.await(
        'SELECT currentXP, prestige FROM ak4y_battlepass WHERE identifier = ?',
        { identifier }
    )
    if #result == 0 then return end

    local playerRow      = result[1]
    local currentLevel   = getLevel(playerRow.currentXP)
    local maxBPLevel     = #AK4Y.BattlePassItems
    local maxPrestige    = #AK4Y.PrestigeRewards
    local currentPrestige = playerRow.prestige

    -- Must be at or above max level and not already at max prestige
    if currentLevel < maxBPLevel then return end
    if currentPrestige >= maxPrestige then return end

    local newPrestige = currentPrestige + 1

    -- Give the prestige reward
    local prestigeReward = AK4Y.PrestigeRewards[newPrestige]
    if prestigeReward then
        if prestigeReward.type == "item" then
            if prestigeReward.itemName == "money" then
                xPlayer.addMoney(prestigeReward.count)
            else
                xPlayer.addInventoryItem(prestigeReward.itemName, prestigeReward.count)
            end
        elseif prestigeReward.type == "money" then
            xPlayer.addMoney(prestigeReward.count)
        end
    end

    -- Reset XP and all reward claims for the new prestige run
    local freshRewards = buildDefaultRewards()

    MySQL.update.await(
        'UPDATE ak4y_battlepass SET currentXP = 0, prestige = ?, rewards = ? WHERE identifier = ?',
        { newPrestige, json.encode(freshRewards), identifier }
    )

    if AK4Y.Server.LogPrestige then
        sendDiscordWebhook(
            "Player Prestiged!",
            "**Player:** " .. GetPlayerName(source) .. "\n**New Prestige Level:** " .. newPrestige,
            16711680
        )
    end
end)
