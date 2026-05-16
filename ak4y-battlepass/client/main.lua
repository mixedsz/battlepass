if AK4Y.Framework == "esx" then
    ESX = nil
elseif AK4Y.Framework == "newEsx" then
	ESX = exports["es_extended"]:getSharedObject()
end

local firstX = true

local depositTime, withdrawTime, transferTime = 0, 0, 0
Citizen.CreateThread(function()
	if AK4Y.Framework == "esx" then
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
	elseif AK4Y.Framework == "newEsx" then 
		while ESX == nil do 
			Citizen.Wait(100)
		end
	end
    

	Wait(5000)
	PlayerData = ESX.GetPlayerData()
	SendNUIMessage({
		type = 'firstLoading',
		neededEXP = AK4Y.RequiredXpForNextLevel,
		htmlLanguage = AK4Y.Language,
	})	
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

local openMenuSpamProtect = 0
RegisterCommand('d10pass', function()
	if openMenuSpamProtect < GetGameTimer() then 
		openMenuSpamProtect = GetGameTimer() + 3000
		if firstX then 
			firstX = false
			PlayerData = ESX.GetPlayerData()
			SendNUIMessage({
				type = 'firstLoading',
				neededEXP = AK4Y.RequiredXpForNextLevel,
				htmlLanguage = AK4Y.Language,
			})	
		end
		ESX.TriggerServerCallback("ak4y-battlePass:getPlayerDetails", function(result)
			apiKey = result.apiKey
            if result.steamid then
                steamID = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apiKey .. "&steamids=" .. result.steamid
            else
                steamID = 'null'
            end
			SetNuiFocus(true,true)
			SendNUIMessage({
				type = 'openUi', 
				currentXP = result.playerData.currentXP,
				prestige = result.playerData.prestige,
				standartTasks = result.playerData.standartTasks,
				premiumTasks = result.playerData.premiumTasks,
				rewards = result.playerData.rewards,
				userPremium = result.playerData.premium,
				bpItems = AK4Y.BattlePassItems,
				bpBottomTask = AK4Y.BattlePassTasks, 
				-- bpDailyPremiumTasks = AK4Y.DailyPremiumTasks,
				bpResetTime = result.resetDate,
				steamid = steamID,
				bpDailyResetTime = result.playerData.standartResetTime,
				firstName = result.charInfo,
			})	
		end)
	else
		ESX.ShowNotification(AK4Y.Language.openSpamProtectNotif)
	end
end)

local getStandartSpamProtect = 0
RegisterNUICallback('getStandartReward', function(data, cb)
	if getStandartSpamProtect < GetGameTimer() then 
		getStandartSpamProtect = GetGameTimer() + 1000
		local carData = nil
		if data.itemDetails.type == "vehicle" then 
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(ped)
			local vehItemNameHash = GetHashKey(data.itemDetails.itemName)
			if not IsModelInCdimage(vehItemNameHash) then return end RequestModel(vehItemNameHash)  while not HasModelLoaded(vehItemNameHash) do Wait(0) end
			local vehicle = CreateVehicle(vehItemNameHash, playerCoords.x, playerCoords.y, playerCoords.z - 200.0, 1.0, false, false)
			FreezeEntityPosition(vehicle, true)
			carData = ESX.Game.GetVehicleProperties(vehicle)
		end
		ESX.TriggerServerCallback("ak4y-battlePass:getStandartRewards", function(result)
			DeleteVehicle(vehicle)
				DeleteEntity(vehicle)
			if result then 	
				cb(true)
			else
				cb(false)
			end
		end, data, carData)
	else
		cb(false)
	end
end)

local getPremiumSpamProtect = 0
RegisterNUICallback('getPremiumReward', function(data, cb)
	if getPremiumSpamProtect < GetGameTimer() then
		getPremiumSpamProtect = GetGameTimer() + 100 
		local carData = nil
		if data.itemDetails.type == "vehicle" then 
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(ped)
			local vehItemNameHash = GetHashKey(data.itemDetails.itemName)
			if not IsModelInCdimage(vehItemNameHash) then return end RequestModel(vehItemNameHash)  while not HasModelLoaded(vehItemNameHash) do Wait(0) end
			local vehicle = CreateVehicle(vehItemNameHash, playerCoords.x, playerCoords.y, playerCoords.z - 200.0, 1.0, false, false)
			FreezeEntityPosition(vehicle, true)
			carData = ESX.Game.GetVehicleProperties(vehicle)
		end
		ESX.TriggerServerCallback("ak4y-battlePass:getPremiumRewards", function(result)
			DeleteVehicle(vehicle)
				DeleteEntity(vehicle)
			if result then 
				cb(true)
			else
				cb(false)
			end
		end, data, carData)
	else
		cb(false)
	end
end)

local standartTaskSpam = 0
RegisterNUICallback('standartTaskDone', function(data, cb)
	if standartTaskSpam < GetGameTimer() then 
		standartTaskSpam = GetGameTimer() + 1000
		ESX.TriggerServerCallback("ak4y-battlePass:standartTaskDone", function(result)
			if result then 
				SendNUIMessage({
					type = 'addEXP', 
					exp = tonumber(result),
				})	
				cb(true)
			else
				cb(false)
			end
		end, data)
	else
		cb(false)
	end
end)

local premiumTaskSpam = 0
RegisterNUICallback('premiumTaskDone', function(data, cb)
	if premiumTaskSpam < GetGameTimer() then 
		premiumTaskSpam = GetGameTimer() + 1000 
		ESX.TriggerServerCallback("ak4y-battlePass:premiumTaskDone", function(result)
			if result then 
				SendNUIMessage({
					type = 'addEXP', 
					exp = tonumber(result),
				})	
				cb(true)
			else
				cb(false)
			end
		end, data)
	else
		cb(false)
	end
end)

local sendInputSpam = 0
RegisterNUICallback('sendInput', function(data, cb)
	if sendInputSpam < GetGameTimer() then 
		sendInputSpam = GetGameTimer() + 1000
		ESX.TriggerServerCallback("ak4y-battlePass:sendInput", function(result)
			if result then 	
				cb(true)
			else
				cb(false)
			end
		end, data)
	else
		cb(false)
	end
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
end)

RegisterNUICallback('prestigePlayer', function(data, cb)
	TriggerServerEvent('ak4y-battlepass:prestigePlayer')
end)

RegisterNetEvent('ak4y-battlepass:addtaskcount:standart')
AddEventHandler('ak4y-battlepass:addtaskcount:standart', function(taskId, count)
	TriggerServerEvent('ak4y-battlepass:taskCountAdd:standart', taskId, count)
end)

RegisterNetEvent('ak4y-battlepass:addtaskcount:premium')
AddEventHandler('ak4y-battlepass:addtaskcount:premium', function(taskId, count)
	TriggerServerEvent('ak4y-battlepass:taskCountAdd:premium', taskId, count)
end)
