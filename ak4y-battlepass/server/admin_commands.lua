-- ak4y dev.
-- Admin commands for managing the BattlePass

local ESX = nil

if AK4Y.Framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif AK4Y.Framework == "newEsx" or AK4Y.Framework == "errorEsx" then
    ESX = exports["es_extended"]:getSharedObject()
end

-- ─── Permission check ─────────────────────────────────────────────────────────

local function isAdmin(source)
    if source == 0 then return true end -- server console always allowed
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    return group == "admin" or group == "superadmin"
end

local function notify(source, msg, color)
    if source == 0 then
        print("[ak4y-battlepass] " .. msg)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = color or { 255, 255, 255 },
            args  = { "[BattlePass]", msg }
        })
    end
end

-- ─── /bp_givexp [playerId] [amount] ──────────────────────────────────────────
-- Give extra XP to any online player.

RegisterCommand('bp_givexp', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])
    local amount   = tonumber(args[2])

    if not targetId or not amount or amount <= 0 then
        notify(source, "Usage: /bp_givexp [playerId] [amount]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()
    local result = MySQL.query.await(
        'SELECT currentXP FROM ak4y_battlepass WHERE identifier = ?', { identifier }
    )
    if #result == 0 then
        notify(source, "Player has no battlepass data (have they opened the menu yet?).", { 255, 100, 100 })
        return
    end

    local newXP = result[1].currentXP + amount
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET currentXP = ? WHERE identifier = ?', { newXP, identifier }
    )

    notify(source, "Gave " .. amount .. " XP to player " .. targetId .. ".", { 100, 255, 100 })
    notify(targetId, "An admin gave you " .. amount .. " BattlePass XP!", { 100, 255, 100 })
end, true)

-- ─── /bp_setxp [playerId] [xp] ───────────────────────────────────────────────
-- Directly set a player's raw XP value.

RegisterCommand('bp_setxp', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])
    local xpValue  = tonumber(args[2])

    if not targetId or xpValue == nil or xpValue < 0 then
        notify(source, "Usage: /bp_setxp [playerId] [xp]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET currentXP = ? WHERE identifier = ?', { xpValue, identifier }
    )

    notify(source, "Set player " .. targetId .. " XP to " .. xpValue .. ".", { 100, 255, 100 })
end, true)

-- ─── /bp_setprestige [playerId] [0-6] ────────────────────────────────────────
-- Force a player's prestige level.

RegisterCommand('bp_setprestige', function(source, args)
    if not isAdmin(source) then return end
    local targetId      = tonumber(args[1])
    local prestigeLevel = tonumber(args[2])
    local maxPrestige   = #AK4Y.PrestigeRewards

    if not targetId or prestigeLevel == nil then
        notify(source, "Usage: /bp_setprestige [playerId] [0-" .. maxPrestige .. "]", { 255, 100, 100 })
        return
    end

    prestigeLevel = math.max(0, math.min(prestigeLevel, maxPrestige))

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET prestige = ? WHERE identifier = ?', { prestigeLevel, identifier }
    )

    notify(source, "Set player " .. targetId .. " prestige to " .. prestigeLevel .. ".", { 100, 255, 100 })
end, true)

-- ─── /bp_premium [playerId] ───────────────────────────────────────────────────
-- Manually grant premium status to a player.

RegisterCommand('bp_premium', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])

    if not targetId then
        notify(source, "Usage: /bp_premium [playerId]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET premium = 1 WHERE identifier = ?', { identifier }
    )

    notify(source, "Player " .. targetId .. " is now PREMIUM.", { 100, 255, 100 })
    notify(targetId, "Your BattlePass account has been upgraded to PREMIUM!", { 255, 215, 0 })
end, true)

-- ─── /bp_revokepremium [playerId] ────────────────────────────────────────────
-- Remove premium status from a player.

RegisterCommand('bp_revokepremium', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])

    if not targetId then
        notify(source, "Usage: /bp_revokepremium [playerId]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()
    MySQL.update.await(
        'UPDATE ak4y_battlepass SET premium = 0 WHERE identifier = ?', { identifier }
    )

    notify(source, "Removed premium from player " .. targetId .. ".", { 100, 255, 100 })
end, true)

-- ─── /bp_reset [playerId] ────────────────────────────────────────────────────
-- Fully reset a player's battlepass (XP, prestige, tasks, rewards).

RegisterCommand('bp_reset', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])

    if not targetId then
        notify(source, "Usage: /bp_reset [playerId]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()

    local standartTasks = {}
    for _, t in ipairs(AK4Y.BattlePassTasks) do
        standartTasks[#standartTasks + 1] = { taskId = t.taskId, hasCount = 0, taken = false }
    end

    local premiumTasks = {}
    for _, t in ipairs(AK4Y.DailyPremiumTasks) do
        premiumTasks[#premiumTasks + 1] = { taskId = t.taskId, hasCount = 0, taken = false }
    end

    local rewards = {}
    for _ in ipairs(AK4Y.BattlePassItems) do
        rewards[#rewards + 1] = { rewards = { standart = { taken = false } } }
    end

    MySQL.update.await(
        [[UPDATE ak4y_battlepass
          SET currentXP = 0, prestige = 0, premium = 0,
              standartTasks = ?, premiumTasks = ?, rewards = ?, standartResetTime = ?
          WHERE identifier = ?]],
        { json.encode(standartTasks), json.encode(premiumTasks), json.encode(rewards), os.time(), identifier }
    )

    notify(source, "Reset battlepass for player " .. targetId .. ".", { 100, 255, 100 })
    notify(targetId, "Your BattlePass has been reset by an admin.", { 255, 100, 100 })
end, true)

-- ─── /bp_resettasks [playerId] ───────────────────────────────────────────────
-- Reset only the daily tasks for a player without touching XP or rewards.

RegisterCommand('bp_resettasks', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])

    if not targetId then
        notify(source, "Usage: /bp_resettasks [playerId]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()

    local standartTasks = {}
    for _, t in ipairs(AK4Y.BattlePassTasks) do
        standartTasks[#standartTasks + 1] = { taskId = t.taskId, hasCount = 0, taken = false }
    end

    MySQL.update.await(
        'UPDATE ak4y_battlepass SET standartTasks = ?, standartResetTime = ? WHERE identifier = ?',
        { json.encode(standartTasks), os.time(), identifier }
    )

    notify(source, "Reset daily tasks for player " .. targetId .. ".", { 100, 255, 100 })
end, true)

-- ─── /bp_gencode ─────────────────────────────────────────────────────────────
-- Generate a random UUID-style premium code and insert it into the DB.

local function generateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return (template:gsub('[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end))
end

RegisterCommand('bp_gencode', function(source, args)
    if not isAdmin(source) then return end

    local code = generateUUID()
    MySQL.insert.await('INSERT INTO ak4y_battlepass_codes (code) VALUES (?)', { code })

    notify(source, "Generated premium code: " .. code, { 100, 255, 100 })
    print("^2[ak4y-battlepass] Premium code generated: " .. code .. "^7")
end, true)

-- ─── /bp_addcode [code] ──────────────────────────────────────────────────────
-- Manually register a specific code string as a valid premium code.

RegisterCommand('bp_addcode', function(source, args)
    if not isAdmin(source) then return end
    local code = args[1]

    if not code or #code < 4 then
        notify(source, "Usage: /bp_addcode [code]", { 255, 100, 100 })
        return
    end

    local existing = MySQL.query.await(
        'SELECT code FROM ak4y_battlepass_codes WHERE code = ?', { code }
    )
    if #existing > 0 then
        notify(source, "Code already exists in the database.", { 255, 100, 100 })
        return
    end

    MySQL.insert.await('INSERT INTO ak4y_battlepass_codes (code) VALUES (?)', { code })
    notify(source, "Code '" .. code .. "' added successfully.", { 100, 255, 100 })
end, true)

-- ─── /bp_checkplayer [playerId] ──────────────────────────────────────────────
-- Print a summary of a player's battlepass data to the console/chat.

RegisterCommand('bp_checkplayer', function(source, args)
    if not isAdmin(source) then return end
    local targetId = tonumber(args[1])

    if not targetId then
        notify(source, "Usage: /bp_checkplayer [playerId]", { 255, 100, 100 })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        notify(source, "Player " .. targetId .. " not found.", { 255, 100, 100 })
        return
    end

    local identifier = xTarget.getIdentifier()
    local result = MySQL.query.await(
        'SELECT currentXP, prestige, premium FROM ak4y_battlepass WHERE identifier = ?',
        { identifier }
    )
    if #result == 0 then
        notify(source, "No battlepass data found for that player.", { 255, 100, 100 })
        return
    end

    local row   = result[1]
    local level = math.floor(row.currentXP / AK4Y.RequiredXpForNextLevel)
    local msg   = string.format(
        "%s | Level: %d | XP: %d | Prestige: %d | Premium: %s",
        xTarget.getName(), level, row.currentXP, row.prestige,
        row.premium == 1 and "YES" or "NO"
    )
    notify(source, msg, { 100, 200, 255 })
end, true)
