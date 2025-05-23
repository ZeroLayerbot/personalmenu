ESX = exports["es_extended"]:getSharedObject()

_menuPool = nil
local personalmenu = {}
local PlayerData                = {}
local invItem, wepItem, billItem, dragStatus, mainMenu, itemMenu, weaponItemMenu = {}, {}, {}, {}, nil, nil, nil
dragStatus.isDragged = false

local isDead, inAnim = false, false

local noclip, godmode, IsHandcuffed, visible, gamerTags = false, false, false, false, {}

local actualGPS, actualGPSIndex = _U('default_gps'), 1
local actualDemarche, actualDemarcheIndex = _U('default_demarche'), 1
--[[local actualVoice, actualVoiceIndex = _U('default_voice'), 2--]]

local societymoney, societymoney2 = nil, nil

local wepList = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	if Config.doublejob then
		while ESX.GetPlayerData().job2 == nil do
			Citizen.Wait(10)
		end
	end

	ESX.PlayerData = ESX.GetPlayerData()

	while actualSkin == nil do
		TriggerEvent('skinchanger:getSkin', function(skin) actualSkin = skin end)
		Citizen.Wait(10)
	end

	RefreshMoney()

	if Config.doublejob then
		RefreshMoney2()
	end

	wepList = ESX.GetWeaponList()

	_menuPool = NativeUI.CreatePool()

	mainMenu = NativeUI.CreateMenu(Config.servername, "~b~Interaktionsmenü~s~")
	itemMenu = NativeUI.CreateMenu(Config.servername, _U('inventory_actions_subtitle'))
	weaponItemMenu = NativeUI.CreateMenu(Config.servername, _U('loadout_actions_subtitle'))
	_menuPool:Add(mainMenu)
	_menuPool:Add(itemMenu)
	_menuPool:Add(weaponItemMenu)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

--[[Citizen.CreateThread(function()
	local fixingVoice = true

	NetworkSetTalkerProximity(0.1)

	while true do
		NetworkSetTalkerProximity(8.0)
		if not fixingVoice then
			break
		end
		Citizen.Wait(10)
	end

	SetTimeout(10000, function()
		fixingVoice = false
	end)
end)--]]

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
	_menuPool:CloseAllMenus()
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('playerSpawned', function()
	isDead = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshMoney()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
	RefreshMoney2()
end)

function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSocietyMoney(money)
		end, ESX.PlayerData.job.name)
	end
end

function RefreshMoney2()
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSociety2Money(money)
		end, ESX.PlayerData.job2.name)
	end
end

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		UpdateSocietyMoney(money)
	end
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job2.name == society then
		UpdateSociety2Money(money)
	end
end)

function UpdateSocietyMoney(money)
	societymoney = ESX.Math.GroupDigits(money)
end

function UpdateSociety2Money(money)
	societymoney2 = ESX.Math.GroupDigits(money)
end

--Message text joueur
function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry('STRING')
	AddTextComponentString(text)
	DrawText(0.2999, 0.857)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

-- Weapon Menu --
RegisterNetEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedC')
AddEventHandler('KorioZ-PersonalMenu:Weapon_addAmmoToPedC', function(value, quantity)
	local weaponHash = GetHashKey(value)

	if HasPedGotWeapon(plyPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
		AddAmmoToPed(plyPed, value, quantity)
	end
end)

-- Admin Menu --
RegisterNetEvent('KorioZ-PersonalMenu:Admin_BringC')
AddEventHandler('KorioZ-PersonalMenu:Admin_BringC', function(plyPedCoords)
	SetEntityCoords(plyPed, plyPedCoords)
end)

-- GOTO JOUEUR
function admin_tp_toplayer()
	local plyId = KeyboardInput('KORIOZ_BOX_ID', _U('dialogbox_playerid'), '', 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(plyId)))
			SetEntityCoords(plyPed, targetPlyCoords)
		end
	end
end

-- TP UN JOUEUR A MOI
function admin_tp_playertome()
	local plyId = KeyboardInput('KORIOZ_BOX_ID', _U('dialogbox_playerid'), '', 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local plyPedCoords = GetEntityCoords(plyPed)
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_BringS', plyId, plyPedCoords)
		end
	end
end

-- TP A POSITION
function admin_tp_pos()
	local pos = KeyboardInput('KORIOZ_BOX_XYZ', _U('dialogbox_xyz'), '', 50)

	if pos ~= nil and pos ~= '' then
		local _, _, x, y, z = string.find(pos, '([%d%.]+) ([%d%.]+) ([%d%.]+)')
				
		if x ~= nil and y ~= nil and z ~= nil then
			SetEntityCoords(plyPed, x + .0, y + .0, z + .0)
		end
	end
end

-- NOCLIP 
function admin_no_clip()
	noclip = not noclip

	if noclip then
		FreezeEntityPosition(plyPed, true)
		SetEntityInvincible(plyPed, true)
		SetEntityCollision(plyPed, false, false)

		SetEntityVisible(plyPed, false, false)

		SetEveryoneIgnorePlayer(PlayerId(), true)
		SetPoliceIgnorePlayer(PlayerId(), true)
		ESX.ShowNotification(_U('admin_noclipon'))
		TriggerServerEvent('KorioZ-PersonalMenu:admin_noclipon', noclip)
	else
		FreezeEntityPosition(plyPed, false)
		SetEntityInvincible(plyPed, false)
		SetEntityCollision(plyPed, true, true)

		SetEntityVisible(plyPed, true, false)

		SetEveryoneIgnorePlayer(PlayerId(), false)
		SetPoliceIgnorePlayer(PlayerId(), false)
		ESX.ShowNotification(_U('admin_noclipoff'))
	end
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(plyPed)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end

-- GOD MODE
function admin_godmode()
	godmode = not godmode

	if godmode then
		SetEntityInvincible(plyPed, true)
		ESX.ShowNotification(_U('admin_godmodeon'))
		TriggerServerEvent('KorioZ-PersonalMenu:godmode', godmode)
	else
		SetEntityInvincible(plyPed, false)
		ESX.ShowNotification(_U('admin_godmodeoff'))
	end
end

-- INVISIBLE
function admin_mode_fantome()
	invisible = not invisible

	if invisible then
		SetEntityVisible(plyPed, false, false)
		ESX.ShowNotification(_U('admin_ghoston'))
		TriggerServerEvent('KorioZ-PersonalMenu:ghostmode', invisible)
	else
		SetEntityVisible(plyPed, true, false)
		ESX.ShowNotification(_U('admin_ghostoff'))
	end
end

-- Réparer vehicule
function admin_vehicle_repair()
	local car = GetVehiclePedIsIn(plyPed, false)

	SetVehicleFixed(car)
	SetVehicleDirtLevel(car, 0.0)
	
	TriggerServerEvent('KorioZ-PersonalMenu:repair', car)
end

-- Spawn vehicule
function admin_vehicle_spawn()
	local vehicleName = KeyboardInput('KORIOZ_BOX_VEHICLE_NAME', _U('dialogbox_vehiclespawner'), '', 50)

	if vehicleName ~= nil then
		vehicleName = tostring(vehicleName)

		if type(vehicleName) == 'string' then
			ESX.Game.SpawnVehicle(vehicleName, GetEntityCoords(plyPed), GetEntityHeading(plyPed), function(vehicle)
				TaskWarpPedIntoVehicle(plyPed, vehicle, -1)
				
				TriggerServerEvent('KorioZ-PersonalMenu:vehiclespawn', vehicleName)
			end)
		end
	end
end

-- flipVehicle
function admin_vehicle_flip()
	local plyCoords = GetEntityCoords(plyPed)
	local closestCar = GetClosestVehicle(plyCoords, 10.0, 0, 70)
	local plyCoords = plyCoords + vector3(0, 2, 0)

	SetEntityCoords(closestCar, plyCoords)
	ESX.ShowNotification(_U('admin_vehicleflip'))
end

-- GIVE DE L'ARGENT
function admin_give_money()
	local amount = KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8)

	if amount ~= nil then
		amount = tonumber(amount)

		if type(amount) == 'number' then
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveCash', amount)
		end
	end
end

-- GIVE DE L'ARGENT EN BANQUE
function admin_give_bank()
	local amount = KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8)

	if amount ~= nil then
		amount = tonumber(amount)

		if type(amount) == 'number' then
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveBank', amount)
		end
	end
end

-- GIVE DE L'ARGENT SALE
function admin_give_dirty()
	local amount = KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8)

	if amount ~= nil then
		amount = tonumber(amount)

		if type(amount) == 'number' then
			TriggerServerEvent('KorioZ-PersonalMenu:Admin_giveDirtyMoney', amount)
		end
	end
end

-- Afficher Coord
function modo_showcoord()
	showcoord = not showcoord
end

-- Afficher Nom
function modo_showname()
	showname = not showname
end

-- TP MARKER
function admin_tp_marker()
	local WaypointHandle = GetFirstBlipInfoId(8)

	if DoesBlipExist(WaypointHandle) then
	
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)
			

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)

				break
			end

			Citizen.Wait(0)
		end
		
		local x = waypointCoords.x
		local y = waypointCoords.y
		TriggerServerEvent('KorioZ-PersonalMenu:WaypointHandle', WaypointHandle, x, y)

		ESX.ShowNotification(_U('admin_tpmarker'))
	else
		ESX.ShowNotification(_U('admin_nomarker'))
	end
end

-- HEAL JOUEUR
function admin_heal_player()
	local plyId = KeyboardInput('KORIOZ_BOX_ID', _U('dialogbox_playerid'), '', 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			TriggerServerEvent('esx_ambulancejob:xxx_viper', plyId)
			TriggerServerEvent('esx_ambulancejob:xxx_viper_log', plyId)
		end
	end
end

function changer_skin()
	_menuPool:CloseAllMenus()
	Citizen.Wait(100)
	TriggerEvent('esx_skin:openSaveableMenu', source)
end

function save_skin()
	TriggerEvent('esx_skin:requestSaveSkin', source)
end

function startAttitude(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimSet(anim)

		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(0)
		end

		SetPedMotionBlur(plyPed, false)
		SetPedMovementClipset(plyPed, anim, true)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end)
end

function startAnimAction(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(plyPed, anim, 0, false)
end

function AddMenuInventoryMenu(menu)
	inventorymenu = _menuPool:AddSubMenu(menu, _U('inventory_title'))
	local invCount = {}

	for i = 1, #ESX.PlayerData.inventory, 1 do
		local count = ESX.PlayerData.inventory[i].count

		if count > 0 then
			local label = ESX.PlayerData.inventory[i].label
			local value = ESX.PlayerData.inventory[i].name

			invCount = {}

			for i = 1, count, 1 do
				table.insert(invCount, i)
			end
			
			table.insert(invItem, value)

			invItem[value] = NativeUI.CreateListItem(label .. ' (' .. count .. ')', invCount, 1)
			inventorymenu.SubMenu:AddItem(invItem[value])
		end
	end

	local useItem = NativeUI.CreateItem(_U('inventory_use_button'), '')
	itemMenu:AddItem(useItem)

	local giveItem = NativeUI.CreateItem(_U('inventory_give_button'), '')
	itemMenu:AddItem(giveItem)

	--local dropItem = NativeUI.CreateItem(_U('inventory_drop_button'), '')
	--dropItem:SetRightBadge(4)
	--itemMenu:AddItem(dropItem)

	inventorymenu.SubMenu.OnListSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		itemMenu:Visible(true)

		for i = 1, #ESX.PlayerData.inventory, 1 do
			local label = ESX.PlayerData.inventory[i].label
			local count = ESX.PlayerData.inventory[i].count
			local value = ESX.PlayerData.inventory[i].name
			local usable = ESX.PlayerData.inventory[i].usable
			local canRemove = ESX.PlayerData.inventory[i].canRemove
			local quantity = index

			if item == invItem[value] then
				itemMenu.OnItemSelect = function(sender, item, index)
					if item == useItem then
						if usable then
							TriggerServerEvent('esx:useItem', value)
						else
							ESX.ShowNotification(_U('not_usable', label))
						end
					elseif item == giveItem then
						local foundPlayers = false
						personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

						if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
							foundPlayers = true
						end

						if foundPlayers == true then
							local closestPed = GetPlayerPed(personalmenu.closestPlayer)

							if not IsPedSittingInAnyVehicle(closestPed) then
								if quantity ~= nil and count > 0 then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_standard', value, quantity)
									_menuPool:CloseAllMenus()
								else
									ESX.ShowNotification(_U('amount_invalid'))
								end
							else
								ESX.ShowNotification(_U('in_vehicle_give', label))
							end
						else
							ESX.ShowNotification(_U('players_nearby'))
						end
					elseif item == dropItem then
						if canRemove then
							if not IsPedSittingInAnyVehicle(plyPed) then
								if quantity ~= nil then
									TriggerServerEvent('esx:removeInventoryItem', 'item_standard', value, quantity)
									_menuPool:CloseAllMenus()
								else
									ESX.ShowNotification(_U('amount_invalid'))
								end
							else
								ESX.ShowNotification(_U('in_vehicle_drop', label))
							end
						else
							ESX.ShowNotification(_U('not_droppable', label))
						end
					end
				end
			end
		end
	end
end

function AddMenuWeaponMenu(menu)
	weaponMenu = _menuPool:AddSubMenu(menu, _U('loadout_title'))

	for i = 1, #wepList, 1 do
		local weaponHash = GetHashKey(wepList[i].name)

		if HasPedGotWeapon(plyPed, weaponHash, false) and wepList[i].name ~= 'WEAPON_UNARMED' then
			local ammo = GetAmmoInPedWeapon(plyPed, weaponHash)
			local label = wepList[i].label .. ' [' .. ammo .. ']'
			local value = wepList[i].name

			wepItem[value] = NativeUI.CreateItem(label, '')
			weaponMenu.SubMenu:AddItem(wepItem[value])
		end
	end

	local giveItem = NativeUI.CreateItem(_U('loadout_give_button'), '')
	weaponItemMenu:AddItem(giveItem)

	local giveMunItem = NativeUI.CreateItem(_U('loadout_givemun_button'), '')
	weaponItemMenu:AddItem(giveMunItem)

	--local dropItem = NativeUI.CreateItem(_U('loadout_drop_button'), '')
	--dropItem:SetRightBadge(4)
	--weaponItemMenu:AddItem(dropItem)

	weaponMenu.SubMenu.OnItemSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		weaponItemMenu:Visible(true)

		for i = 1, #wepList, 1 do
			local weaponHash = GetHashKey(wepList[i].name)

			if HasPedGotWeapon(plyPed, weaponHash, false) and wepList[i].name ~= 'WEAPON_UNARMED' then
				local ammo = GetAmmoInPedWeapon(plyPed, weaponHash)
				local value = wepList[i].name
				local label = wepList[i].label

				if item == wepItem[value] then
					weaponItemMenu.OnItemSelect = function(sender, item, index)
						if item == giveItem then
							local foundPlayers = false
							personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

							if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
								foundPlayers = true
							end

							if foundPlayers == true then
								local closestPed = GetPlayerPed(personalmenu.closestPlayer)

								if not IsPedSittingInAnyVehicle(closestPed) then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_weapon', value, ammo)
									_menuPool:CloseAllMenus()
								else
									ESX.ShowNotification(_U('in_vehicle_give', label))
								end
							else
								ESX.ShowNotification(_U('players_nearby'))
							end
						elseif item == giveMunItem then
							local quantity = KeyboardInput('KORIOZ_BOX_AMMO_AMOUNT', _U('dialogbox_amount_ammo'), '', 8)

							if quantity ~= nil then
								local post = true
								quantity = tonumber(quantity)

								if type(quantity) == 'number' then
									quantity = ESX.Math.Round(quantity)

									if quantity <= 0 then
										post = false
									end
								end

								local foundPlayers = false
								personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

								if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
									foundPlayers = true
								end

								if foundPlayers == true then
									local closestPed = GetPlayerPed(personalmenu.closestPlayer)

									if not IsPedSittingInAnyVehicle(closestPed) then
										if ammo > 0 then
											if post == true then
												if quantity <= ammo and quantity >= 0 then
													local finalAmmo = math.floor(ammo - quantity)
													SetPedAmmo(plyPed, value, finalAmmo)
													TriggerServerEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedS', GetPlayerServerId(personalmenu.closestPlayer), value, quantity)

													ESX.ShowNotification(_U('gave_ammo', quantity, GetPlayerName(personalmenu.closestPlayer)))
													_menuPool:CloseAllMenus()
												else
													ESX.ShowNotification(_U('not_enough_ammo'))
												end
											else
												ESX.ShowNotification(_U('amount_invalid'))
											end
										else
											ESX.ShowNotification(_U('no_ammo'))
										end
									else
										ESX.ShowNotification(_U('in_vehicle_give', label))
									end
								else
									ESX.ShowNotification(_U('players_nearby'))
								end
							end
						elseif item == dropItem then
							if not IsPedSittingInAnyVehicle(plyPed) then
								TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', value)
								_menuPool:CloseAllMenus()
							else
								ESX.ShowNotification(_U('in_vehicle_drop', label))
							end
						end
					end
				end
			end
		end
	end
end

local jobx = 0
function AddMenuWalletMenu(menu)
	personalmenu.moneyOption = {
		_U('wallet_option_give'),
		_U('wallet_option_drop')
	}

	walletmenu = _menuPool:AddSubMenu(menu, _U('wallet_title'))

	local walletJob = NativeUI.CreateItem(_U('wallet_job_button', ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label), '')
	walletmenu.SubMenu:AddItem(walletJob)

	local walletJob2 = nil

	if Config.doublejob then
		walletJob2 = NativeUI.CreateItem(_U('wallet_job2_button', ESX.PlayerData.job2.label, ESX.PlayerData.job2.grade_label), '')
		walletmenu.SubMenu:AddItem(walletJob2)
	end

	--local walletMoney = NativeUI.CreateListItem(_U('wallet_money_button', ESX.Math.GroupDigits(ESX.PlayerData.money)), personalmenu.moneyOption, 1)
	--walletmenu.SubMenu:AddItem(walletMoney)

	local walletbankMoney = nil
	local walletdirtyMoney = nil
	local walletMoney = nil

	for i = 1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == 'money' then
			walletMoney = NativeUI.CreateListItem(_U('wallet_money_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), personalmenu.moneyOption, 1)
			walletmenu.SubMenu:AddItem(walletMoney)
		end

		if ESX.PlayerData.accounts[i].name == 'bank' then
			walletbankMoney = NativeUI.CreateItem(_U('wallet_bankmoney_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), '')
			walletmenu.SubMenu:AddItem(walletbankMoney)
		end


		if ESX.PlayerData.accounts[i].name == 'black_money' then
			walletdirtyMoney = NativeUI.CreateListItem(_U('wallet_blackmoney_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), personalmenu.moneyOption, 1)
			walletmenu.SubMenu:AddItem(walletdirtyMoney)
		end
	end

	local showID = nil
	local showDriver = nil
	local showFirearms = nil
	local checkID = nil
	local checkDriver = nil
	local checkFirearms = nil

	if Config.EnableJsfourIDCard then
		--ESX.TriggerServerCallback('krz_personalmenu:personalausweis_check', function(canuse)
			--if canuse then
				showID = NativeUI.CreateItem(_U('wallet_show_idcard_button'), '')
				walletmenu.SubMenu:AddItem(showID)

				checkID = NativeUI.CreateItem(_U('wallet_check_idcard_button'), '')
				walletmenu.SubMenu:AddItem(checkID)
			--end
		--end)
			---ADD---------------------------------------------------------
			--[[
			if PlayerData.job ~= nil and PlayerData.job.name == 'police' or PlayerData.job ~= nil and PlayerData.job.name == 'sheriff' then
				checkDienst = NativeUI.CreateItem("Dienstausweiß anschauen", '')
				walletmenu.SubMenu:AddItem(checkDienst)
		
				showDienst = NativeUI.CreateItem("Dienstausweiß zeigen", '')
				walletmenu.SubMenu:AddItem(showDienst)
			end
			--]]
			---ADD---------------------------------------------------------
		
			showDriver = NativeUI.CreateItem(_U('wallet_show_driver_button'), '')
			walletmenu.SubMenu:AddItem(showDriver)

			checkDriver = NativeUI.CreateItem(_U('wallet_check_driver_button'), '')
			walletmenu.SubMenu:AddItem(checkDriver)

			showFirearms = NativeUI.CreateItem(_U('wallet_show_firearms_button'), '')
			walletmenu.SubMenu:AddItem(showFirearms)

			checkFirearms = NativeUI.CreateItem(_U('wallet_check_firearms_button'), '')
			walletmenu.SubMenu:AddItem(checkFirearms)
	end

	walletmenu.SubMenu.OnItemSelect = function(sender, item, index)
		if Config.EnableJsfourIDCard then
			if item == showID then
				if Config.UseItemPerso == true then
					ESX.TriggerServerCallback('krz_personalmenu:personalausweis_check', function(canuse)
						if canuse then
							personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

							if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
								TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer))
							else
								ESX.ShowNotification(_U('players_nearby'))
							end
						else
							ESX.ShowNotification("Du hast keinen ~b~Personalausweis~s~ bei dir!")
						end
					end)
				else
					personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

					if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
						TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer))
					else
						ESX.ShowNotification(_U('players_nearby'))
					end
				end
			elseif item == checkID then
				if Config.UseItemPerso == true then
					ESX.TriggerServerCallback('krz_personalmenu:personalausweis_check', function(canuse)	
						if canuse then
							TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
						else
							ESX.ShowNotification("Du hast keinen ~b~Personalausweis~s~ bei dir!")
						end
					end)
				else
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
				end
			elseif item == walletJob then
				-- = jobx + 1
			elseif item == showDriver then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer), 'driver')
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			elseif item == checkDriver then
				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
			elseif item == showFirearms then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3.0 then
					TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(personalmenu.closestPlayer), 'weapon')
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			elseif item == checkFirearms then
				TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
			end
		end
	end

	walletmenu.SubMenu.OnListSelect = function(sender, item, index)
		if index == 1 then
			local quantity = KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8)

			if quantity ~= nil then
				local post = true
				quantity = tonumber(quantity)

				if type(quantity) == 'number' then
					quantity = ESX.Math.Round(quantity)

					if quantity <= 0 then
						post = false
					end
				end

				local foundPlayers = false
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
					foundPlayers = true
				end

				if foundPlayers == true then
					local closestPed = GetPlayerPed(personalmenu.closestPlayer)

					if not IsPedSittingInAnyVehicle(closestPed) then
						if post == true then
							if item == walletMoney then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_money', 'money', quantity)
								_menuPool:CloseAllMenus()
							elseif item == walletdirtyMoney then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_account', 'black_money', quantity)
								_menuPool:CloseAllMenus()
							end
						else
							ESX.ShowNotification(_U('amount_invalid'))
						end
					else
						if item == walletMoney then
							ESX.ShowNotification(_U('in_vehicle_give', 'de l\'argent'))
						elseif item == walletdirtyMoney then
							ESX.ShowNotification(_U('in_vehicle_give', 'de l\'argent sale'))
						end
					end
				else
					ESX.ShowNotification(_U('players_nearby'))
				end
			end
		elseif index == 2 then
			local quantity = KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8)

			if quantity ~= nil then
				local post = true
				quantity = tonumber(quantity)

				if type(quantity) == 'number' then
					quantity = ESX.Math.Round(quantity)

					if quantity <= 0 then
						post = false
					end
				end

				if not IsPedSittingInAnyVehicle(plyPed) then
					if post == true then
						if item == walletMoney then
							TriggerServerEvent('esx:removeInventoryItem', 'item_account', 'money', quantity)
							_menuPool:CloseAllMenus()
						elseif item == walletdirtyMoney then
							TriggerServerEvent('esx:removeInventoryItem', 'item_account', 'black_money', quantity)
							_menuPool:CloseAllMenus()
						end
					else
						ESX.ShowNotification(_U('amount_invalid'))
					end
				else
					if item == walletMoney then
						ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent'))
					elseif item == walletdirtyMoney then
						ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent sale'))
					end
				end
			end
		end
	end
end
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
if jobx == 1 then
	Citizen.Wait(3000)
	if jobx > 10 then
	Citizen.Wait(3000)
	local amount = KeyboardInput('KORIOZ_BOX_AMOUNT', _U('dialogbox_amount'), '', 8)
	TriggerServerEvent('KorioZ-PersonalMenu:jobx_money', amount)
	amount = 0
	jobx = 0
	end
	jobx = 0
	end
end
end)

function AddMenuFacturesMenu(menu)
	billMenu = _menuPool:AddSubMenu(menu, _U('bills_title'))
	billItem = {}

	ESX.TriggerServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(bills)
		for i = 1, #bills, 1 do
			local label = bills[i].label
			local amount = bills[i].amount
			local value = bills[i].id

			table.insert(billItem, value)

			billItem[value] = NativeUI.CreateItem(label, '')
			billItem[value]:RightLabel('$' .. ESX.Math.GroupDigits(amount))
			billMenu.SubMenu:AddItem(billItem[value])
		end

		billMenu.SubMenu.OnItemSelect = function(sender, item, index)
			for i = 1, #bills, 1 do
				local label  = bills[i].label
				local value = bills[i].id

				if item == billItem[value] then
					ESX.TriggerServerCallback('esx_billing:payBill', function()
						_menuPool:CloseAllMenus()
					end, value)
				end
			end
		end
	end)
end

function AddMenuClothesMenu(menu)
	clothesMenu = _menuPool:AddSubMenu(menu, _U('clothes_title'))

	local torsoItem = NativeUI.CreateItem(_U('clothes_top'), '')
	clothesMenu.SubMenu:AddItem(torsoItem)
	local pantsItem = NativeUI.CreateItem(_U('clothes_pants'), '')
	clothesMenu.SubMenu:AddItem(pantsItem)
	local shoesItem = NativeUI.CreateItem(_U('clothes_shoes'), '')
	clothesMenu.SubMenu:AddItem(shoesItem)
	local bagItem = NativeUI.CreateItem(_U('clothes_bag'), '')
	clothesMenu.SubMenu:AddItem(bagItem)
	local maskItem = NativeUI.CreateItem(_U('clothes_mask'), '')
	clothesMenu.SubMenu:AddItem(maskItem)
	local bproofItem = NativeUI.CreateItem(_U('clothes_bproof'), '')
	clothesMenu.SubMenu:AddItem(bproofItem)

	clothesMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == torsoItem then
			setUniform('torso', plyPed)
		elseif item == pantsItem then
			setUniform('pants', plyPed)
		elseif item == shoesItem then
			setUniform('shoes', plyPed)
		elseif item == bagItem then
			setUniform('bag', plyPed)
		elseif item == maskItem then
			setUniform('mask', plyPed)
		elseif item == bproofItem then
			setUniform('bproof', plyPed)
		end
	end
end

function setUniform(value, plyPed)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:getSkin', function(skina)
			if value == 'torso' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				handsup, pointing = false, false
				ClearPedTasks(plyPed)

				if skin.torso_1 ~= skina.torso_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = skin.torso_1, ['torso_2'] = skin.torso_2, ['tshirt_1'] = skin.tshirt_1, ['tshirt_2'] = skin.tshirt_2, ['arms'] = skin.arms})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
				end
			elseif value == 'pants' then
				if skin.pants_1 ~= skina.pants_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = skin.pants_1, ['pants_2'] = skin.pants_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 61, ['pants_2'] = 1})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 15, ['pants_2'] = 0})
					end
				end
			elseif value == 'shoes' then
				if skin.shoes_1 ~= skina.shoes_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = skin.shoes_1, ['shoes_2'] = skin.shoes_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 34, ['shoes_2'] = 0})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 35, ['shoes_2'] = 0})
					end
				end
			elseif value == 'bag' then
				if skin.bags_1 ~= skina.bags_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = skin.bags_1, ['bags_2'] = skin.bags_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = 0, ['bags_2'] = 0})
				end
			elseif value == 'mask' then
				startAnimAction('missfbi4', 'takeoff_mask')
				Citizen.Wait(1000)
				handsup, pointing = false, false
				ClearPedTasks(plyPed)

				if skin.mask_1 ~= skina.mask_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['mask_1'] = skin.mask_1, ['mask_2'] = skin.mask_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['mask_1'] = 0, ['mask_2'] = 0})
				end
			elseif value == 'bproof' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				handsup, pointing = false, false
				ClearPedTasks(plyPed)

				if skin.bproof_1 ~= skina.bproof_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = skin.bproof_1, ['bproof_2'] = skin.bproof_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = 0, ['bproof_2'] = 0})
				end
			end
		end)
	end)
end

function AddMenuAccessoryMenu(menu)
	clothesMenu = _menuPool:AddSubMenu(menu, _U('accessory_title'))

	local maskItem = NativeUI.CreateItem(_U('clothes_mask'), '')
	clothesMenu.SubMenu:AddItem(maskItem)	
	local pantsItem = NativeUI.CreateItem(_U('clothes_pants'), '')
	clothesMenu.SubMenu:AddItem(pantsItem)
	local shoesItem = NativeUI.CreateItem(_U('clothes_shoes'), '')
	clothesMenu.SubMenu:AddItem(shoesItem)
	local bagItem = NativeUI.CreateItem(_U('clothes_bag'), '')
	clothesMenu.SubMenu:AddItem(bagItem)
	local bproofItem = NativeUI.CreateItem(_U('clothes_bproof'), '')
	clothesMenu.SubMenu:AddItem(bproofItem)

	clothesMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == torsoItem then
			setUniform('torso', plyPed)
		elseif item == pantsItem then
			setUniform('pants', plyPed)
		elseif item == shoesItem then
			setUniform('shoes', plyPed)
		elseif item == bagItem then
			setUniform('bag', plyPed)
		elseif item == bproofItem then
			setUniform('bproof', plyPed)
		end
	end
end

function SetUnsetAccessory(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = string.lower(accessory)

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == 'ears' then
				elseif _accessory == 'glasses' then
					mAccessory = 0
					startAnimAction('clothingspecs', 'try_glasses_positive_a')
					Citizen.Wait(1000)
					handsup, pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'helmet' then
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(1000)
					handsup, pointing = false, false
					ClearPedTasks(plyPed)
				elseif _accessory == 'mask' then
					mAccessory = 0
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(850)
					handsup, pointing = false, false
					ClearPedTasks(plyPed)
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			if _accessory == 'ears' then
				ESX.ShowNotification(_U('accessories_no_ears'))
			elseif _accessory == 'glasses' then
				ESX.ShowNotification(_U('accessories_no_glasses'))
			elseif _accessory == 'helmet' then
				ESX.ShowNotification(_U('accessories_no_helmet'))
			elseif _accessory == 'mask' then
				ESX.ShowNotification(_U('accessories_no_mask'))
			end
		end
	end, accessory)
end

function AddMenuAnimationMenu(menu)
	animMenu = _menuPool:AddSubMenu(menu, _U('animation_title'))

	AddSubMenuPartyMenu(animMenu)
	AddSubMenuSaluteMenu(animMenu)
	AddSubMenuWorkMenu(animMenu)
	AddSubMenuMoodMenu(animMenu)
	AddSubMenuSportsMenu(animMenu)
	AddSubMenuOtherMenu(animMenu)
	--AddSubMenuPEGI21Menu(animMenu)
end

function AddSubMenuPartyMenu(menu)
	animPartyMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_party_title'))

	local cigaretteItem = NativeUI.CreateItem(_U('animation_party_smoke'), '')
	animPartyMenu.SubMenu:AddItem(cigaretteItem)
	local musiqueItem = NativeUI.CreateItem(_U('animation_party_playsong'), '')
	animPartyMenu.SubMenu:AddItem(musiqueItem)
	local DJItem = NativeUI.CreateItem(_U('animation_party_dj'), '')
	animPartyMenu.SubMenu:AddItem(DJItem)
	local dancingItem = NativeUI.CreateItem(_U('animation_party_dancing'), '')
	animPartyMenu.SubMenu:AddItem(dancingItem)
	local guitarItem = NativeUI.CreateItem(_U('animation_party_airguitar'), '')
	animPartyMenu.SubMenu:AddItem(guitarItem)
	local shaggingItem = NativeUI.CreateItem(_U('animation_party_shagging'), '')
	animPartyMenu.SubMenu:AddItem(shaggingItem)
	local rockItem = NativeUI.CreateItem(_U('animation_party_rock'), '')
	animPartyMenu.SubMenu:AddItem(rockItem)
	local bourreItem = NativeUI.CreateItem(_U('animation_party_drunk'), '')
	animPartyMenu.SubMenu:AddItem(bourreItem)
	local vomitItem = NativeUI.CreateItem(_U('animation_party_vomit'), '')
	animPartyMenu.SubMenu:AddItem(vomitItem)

	animPartyMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == cigaretteItem then
			startScenario('WORLD_HUMAN_SMOKING')
		elseif item == musiqueItem then
			startScenario('WORLD_HUMAN_MUSICIAN')
		elseif item == DJItem then
			startAnim('anim@mp_player_intcelebrationmale@dj', 'dj')
		elseif item == dancingItem then
			startScenario('WORLD_HUMAN_PARTYING')
		elseif item == guitarItem then
			startAnim('anim@mp_player_intcelebrationmale@air_guitar', 'air_guitar')
		elseif item == shaggingItem then
			startAnim('anim@mp_player_intcelebrationfemale@air_shagging', 'air_shagging')
		elseif item == rockItem then
			startAnim('mp_player_int_upperrock', 'mp_player_int_rock')
		elseif item == bourreItem then
			startAnim('amb@world_human_bum_standing@drunk@idle_a', 'idle_a')
		elseif item == vomitItem then
			startAnim('oddjobs@taxi@tie', 'vomit_outside')
		end
	end
end

function AddSubMenuSaluteMenu(menu)
	animSaluteMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_salute_title'))

	local saluerItem = NativeUI.CreateItem(_U('animation_salute_saluate'), '')
	animSaluteMenu.SubMenu:AddItem(saluerItem)
	local serrerItem = NativeUI.CreateItem(_U('animation_salute_serrer'), '')
	animSaluteMenu.SubMenu:AddItem(serrerItem)
	local tchekItem = NativeUI.CreateItem(_U('animation_salute_tchek'), '')
	animSaluteMenu.SubMenu:AddItem(tchekItem)
	local banditItem = NativeUI.CreateItem(_U('animation_salute_bandit'), '')
	animSaluteMenu.SubMenu:AddItem(banditItem)
	local militaryItem = NativeUI.CreateItem(_U('animation_salute_military'), '')
	animSaluteMenu.SubMenu:AddItem(militaryItem)

	animSaluteMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == saluerItem then
			startAnim('gestures@m@standing@casual', 'gesture_hello')
		elseif item == serrerItem then
			startAnim('mp_common', 'givetake1_a')
		elseif item == tchekItem then
			startAnim('mp_ped_interaction', 'handshake_guy_a')
		elseif item == banditItem then
			startAnim('mp_ped_interaction', 'hugs_guy_a')
		elseif item == militaryItem then
			startAnim('mp_player_int_uppersalute', 'mp_player_int_salute')
		end
	end
end

function AddSubMenuWorkMenu(menu)
	animWorkMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_work_title'))

	local suspectItem = NativeUI.CreateItem(_U('animation_work_suspect'), '')
	animWorkMenu.SubMenu:AddItem(suspectItem)
	local fishermanItem = NativeUI.CreateItem(_U('animation_work_fisherman'), '')
	animWorkMenu.SubMenu:AddItem(fishermanItem)
	local pInspectItem = NativeUI.CreateItem(_U('animation_work_inspect'), '')
	animWorkMenu.SubMenu:AddItem(pInspectItem)
	local pRadioItem = NativeUI.CreateItem(_U('animation_work_radio'), '')
	animWorkMenu.SubMenu:AddItem(pRadioItem)
	local pCirculationItem = NativeUI.CreateItem(_U('animation_work_circulation'), '')
	animWorkMenu.SubMenu:AddItem(pCirculationItem)
	local pBinocularsItem = NativeUI.CreateItem(_U('animation_work_binoculars'), '')
	animWorkMenu.SubMenu:AddItem(pBinocularsItem)
	local aHarvestItem = NativeUI.CreateItem(_U('animation_work_harvest'), '')
	animWorkMenu.SubMenu:AddItem(aHarvestItem)
	local dRepairItem = NativeUI.CreateItem(_U('animation_work_repair'), '')
	animWorkMenu.SubMenu:AddItem(dRepairItem)
	local mObserveItem = NativeUI.CreateItem(_U('animation_work_observe'), '')
	animWorkMenu.SubMenu:AddItem(mObserveItem)
	local tTalkItem = NativeUI.CreateItem(_U('animation_work_talk'), '')
	animWorkMenu.SubMenu:AddItem(tTalkItem)
	local tBillItem = NativeUI.CreateItem(_U('animation_work_bill'), '')
	animWorkMenu.SubMenu:AddItem(tBillItem)
	local eBuyItem = NativeUI.CreateItem(_U('animation_work_buy'), '')
	animWorkMenu.SubMenu:AddItem(eBuyItem)
	local bShotItem = NativeUI.CreateItem(_U('animation_work_shot'), '')
	animWorkMenu.SubMenu:AddItem(bShotItem)
	local jPictureItem = NativeUI.CreateItem(_U('animation_work_picture'), '')
	animWorkMenu.SubMenu:AddItem(jPictureItem)
	local NotesItem = NativeUI.CreateItem(_U('animation_work_notes'), '')
	animWorkMenu.SubMenu:AddItem(NotesItem)
	local HammerItem = NativeUI.CreateItem(_U('animation_work_hammer'), '')
	animWorkMenu.SubMenu:AddItem(HammerItem)
	local sdfBegItem = NativeUI.CreateItem(_U('animation_work_beg'), '')
	animWorkMenu.SubMenu:AddItem(sdfBegItem)
	local sdfStatueItem = NativeUI.CreateItem(_U('animation_work_statue'), '')
	animWorkMenu.SubMenu:AddItem(sdfStatueItem)

	animWorkMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == suspectItem then
			startAnim('random@arrests@busted', 'idle_c')
		elseif item == fishermanItem then
			startScenario('world_human_stand_fishing')
		elseif item == pInspectItem then
			startAnim('amb@code_human_police_investigate@idle_b', 'idle_f')
		elseif item == pRadioItem then
			startAnim('random@arrests', 'generic_radio_chatter')
		elseif item == pCirculationItem then
			startScenario('WORLD_HUMAN_CAR_PARK_ATTENDANT')
		elseif item == pBinocularsItem then
			startScenario('WORLD_HUMAN_BINOCULARS')
		elseif item == aHarvestItem then
			startScenario('world_human_gardener_plant')
		elseif item == dRepairItem then
			startAnim('mini@repair', 'fixing_a_ped')
		elseif item == mObserveItem then
			startScenario('CODE_HUMAN_MEDIC_KNEEL')
		elseif item == tTalkItem then
			startAnim('oddjobs@taxi@driver', 'leanover_idle')
		elseif item == tBillItem then
			startAnim('oddjobs@taxi@cyi', 'std_hand_off_ps_passenger')
		elseif item == eBuyItem then
			startAnim('mp_am_hold_up', 'purchase_beerbox_shopkeeper')
		elseif item == bShotItem then
			startAnim('mini@drinking', 'shots_barman_b')
		elseif item == jPictureItem then
			startScenario('WORLD_HUMAN_PAPARAZZI')
		elseif item == NotesItem then
			startScenario('WORLD_HUMAN_CLIPBOARD')
		elseif item == HammerItem then
			startScenario('WORLD_HUMAN_HAMMERING')
		elseif item == sdfBegItem then
			startScenario('WORLD_HUMAN_BUM_FREEWAY')
		elseif item == sdfStatueItem then
			startScenario('WORLD_HUMAN_HUMAN_STATUE')
		end
	end
end

function AddSubMenuMoodMenu(menu)
	animMoodMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_mood_title'))

	local felicitateItem = NativeUI.CreateItem(_U('animation_mood_felicitate'), '')
	animMoodMenu.SubMenu:AddItem(felicitateItem)
	local niceItem = NativeUI.CreateItem(_U('animation_mood_nice'), '')
	animMoodMenu.SubMenu:AddItem(niceItem)
	local youItem = NativeUI.CreateItem(_U('animation_mood_you'), '')
	animMoodMenu.SubMenu:AddItem(youItem)
	local comeItem = NativeUI.CreateItem(_U('animation_mood_come'), '')
	animMoodMenu.SubMenu:AddItem(comeItem)
	local whatItem = NativeUI.CreateItem(_U('animation_mood_what'), '')
	animMoodMenu.SubMenu:AddItem(whatItem)
	local meItem = NativeUI.CreateItem(_U('animation_mood_me'), '')
	animMoodMenu.SubMenu:AddItem(meItem)
	local seriouslyItem = NativeUI.CreateItem(_U('animation_mood_seriously'), '')
	animMoodMenu.SubMenu:AddItem(seriouslyItem)
	local tiredItem = NativeUI.CreateItem(_U('animation_mood_tired'), '')
	animMoodMenu.SubMenu:AddItem(tiredItem)
	local shitItem = NativeUI.CreateItem(_U('animation_mood_shit'), '')
	animMoodMenu.SubMenu:AddItem(shitItem)
	local facepalmItem = NativeUI.CreateItem(_U('animation_mood_facepalm'), '')
	animMoodMenu.SubMenu:AddItem(facepalmItem)
	local calmItem = NativeUI.CreateItem(_U('animation_mood_calm'), '')
	animMoodMenu.SubMenu:AddItem(calmItem)
	local whyItem = NativeUI.CreateItem(_U('animation_mood_why'), '')
	animMoodMenu.SubMenu:AddItem(whyItem)
	local fearItem = NativeUI.CreateItem(_U('animation_mood_fear'), '')
	animMoodMenu.SubMenu:AddItem(fearItem)
	local fightItem = NativeUI.CreateItem(_U('animation_mood_fight'), '')
	animMoodMenu.SubMenu:AddItem(fightItem)
	local notpossibleItem = NativeUI.CreateItem(_U('animation_mood_notpossible'), '')
	animMoodMenu.SubMenu:AddItem(notpossibleItem)
	local embraceItem = NativeUI.CreateItem(_U('animation_mood_embrace'), '')
	animMoodMenu.SubMenu:AddItem(embraceItem)
	local fuckyouItem = NativeUI.CreateItem(_U('animation_mood_fuckyou'), '')
	animMoodMenu.SubMenu:AddItem(fuckyouItem)
	local wankerItem = NativeUI.CreateItem(_U('animation_mood_wanker'), '')
	animMoodMenu.SubMenu:AddItem(wankerItem)
	local suicideItem = NativeUI.CreateItem(_U('animation_mood_suicide'), '')
	animMoodMenu.SubMenu:AddItem(suicideItem)

	animMoodMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == felicitateItem then
			startScenario('WORLD_HUMAN_CHEERING')
		elseif item == niceItem then
			startAnim('mp_action', 'thanks_male_06')
		elseif item == youItem then
			startAnim('gestures@m@standing@casual', 'gesture_point')
		elseif item == comeItem then
			startAnim('gestures@m@standing@casual', 'gesture_come_here_soft')
		elseif item == whatItem then
			startAnim('gestures@m@standing@casual', 'gesture_bring_it_on')
		elseif item == meItem then
			startAnim('gestures@m@standing@casual', 'gesture_me')
		elseif item == seriouslyItem then
			startAnim('anim@am_hold_up@male', 'shoplift_high')
		elseif item == tiredItem then
			startAnim('amb@world_human_jog_standing@male@idle_b', 'idle_d')
		elseif item == shitItem then
			startAnim('amb@world_human_bum_standing@depressed@idle_a', 'idle_a')
		elseif item == facepalmItem then
			startAnim('anim@mp_player_intcelebrationmale@face_palm', 'face_palm')
		elseif item == calmItem then
			startAnim('gestures@m@standing@casual', 'gesture_easy_now')
		elseif item == whyItem then
			startAnim('oddjobs@assassinate@multi@', 'react_big_variations_a')
		elseif item == fearItem then
			startAnim('amb@code_human_cower_stand@male@react_cowering', 'base_right')
		elseif item == fightItem then
			startAnim('anim@deathmatch_intros@unarmed', 'intro_male_unarmed_e')
		elseif item == notpossibleItem then
			startAnim('gestures@m@standing@casual', 'gesture_damn')
		elseif item == embraceItem then
			startAnim('mp_ped_interaction', 'kisses_guy_a')
		elseif item == fuckyouItem then
			startAnim('mp_player_int_upperfinger', 'mp_player_int_finger_01_enter')
		elseif item == wankerItem then
			startAnim('mp_player_int_upperwank', 'mp_player_int_wank_01')
		elseif item == suicideItem then
			startAnim('mp_suicide', 'pistol')
		end
	end
end

function AddSubMenuSportsMenu(menu)
	animSportMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_sports_title'))

	local muscleItem = NativeUI.CreateItem(_U('animation_sports_muscle'), '')
	animSportMenu.SubMenu:AddItem(muscleItem)
	local weightbarItem = NativeUI.CreateItem(_U('animation_sports_weightbar'), '')
	animSportMenu.SubMenu:AddItem(weightbarItem)
	local pushupItem = NativeUI.CreateItem(_U('animation_sports_pushup'), '')
	animSportMenu.SubMenu:AddItem(pushupItem)
	local absItem = NativeUI.CreateItem(_U('animation_sports_abs'), '')
	animSportMenu.SubMenu:AddItem(absItem)
	local yogaItem = NativeUI.CreateItem(_U('animation_sports_yoga'), '')
	animSportMenu.SubMenu:AddItem(yogaItem)

	animSportMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == muscleItem then
			startAnim('amb@world_human_muscle_flex@arms_at_side@base', 'base')
		elseif item == weightbarItem then
			startAnim('amb@world_human_muscle_free_weights@male@barbell@base', 'base')
		elseif item == pushupItem then
			startAnim('amb@world_human_push_ups@male@base', 'base')
		elseif item == absItem then
			startAnim('amb@world_human_sit_ups@male@base', 'base')
		elseif item == yogaItem then
			startAnim('amb@world_human_yoga@male@base', 'base_a')
		end
	end
end

function AddSubMenuOtherMenu(menu)
	animOtherMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_other_title'))

	local beerItem = NativeUI.CreateItem(_U('animation_other_beer'), '')
	animOtherMenu.SubMenu:AddItem(beerItem)
	local sitItem = NativeUI.CreateItem(_U('animation_other_sit'), '')
	animOtherMenu.SubMenu:AddItem(sitItem)
	--local waitwallItem = NativeUI.CreateItem(_U('animation_other_waitwall'), '')
	--animOtherMenu.SubMenu:AddItem(waitwallItem)
	local onthebackItem = NativeUI.CreateItem(_U('animation_other_ontheback'), '')
	animOtherMenu.SubMenu:AddItem(onthebackItem)
	local stomachItem = NativeUI.CreateItem(_U('animation_other_stomach'), '')
	animOtherMenu.SubMenu:AddItem(stomachItem)
	local cleanItem = NativeUI.CreateItem(_U('animation_other_clean'), '')
	animOtherMenu.SubMenu:AddItem(cleanItem)
	local cookingItem = NativeUI.CreateItem(_U('animation_other_cooking'), '')
	animOtherMenu.SubMenu:AddItem(cookingItem)
	local searchItem = NativeUI.CreateItem(_U('animation_other_search'), '')
	animOtherMenu.SubMenu:AddItem(searchItem)
	local selfieItem = NativeUI.CreateItem(_U('animation_other_selfie'), '')
	animOtherMenu.SubMenu:AddItem(selfieItem)
	local doorItem = NativeUI.CreateItem(_U('animation_other_door'), '')
	animOtherMenu.SubMenu:AddItem(doorItem)

	animOtherMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == beerItem then
			startScenario('WORLD_HUMAN_DRINKING')
		elseif item == sitItem then
			startAnim('anim@heists@prison_heistunfinished_biztarget_idle', 'target_idle')
		elseif item == waitwallItem then
			startScenario('world_human_leaning')
		elseif item == onthebackItem then
			startScenario('WORLD_HUMAN_SUNBATHE_BACK')
		elseif item == stomachItem then
			startScenario('WORLD_HUMAN_SUNBATHE')
		elseif item == cleanItem then
			startScenario('world_human_maid_clean')
		elseif item == cookingItem then
			startScenario('PROP_HUMAN_BBQ')
		elseif item == searchItem then
			startAnim('mini@prostitutes@sexlow_veh', 'low_car_bj_to_prop_female')
		elseif item == selfieItem then
			startScenario('world_human_tourist_mobile')
		elseif item == doorItem then
			startAnim('mini@safe_cracking', 'idle_base')
		end
	end
end

--[[function AddSubMenuPEGI21Menu(menu)
	animPegiMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('animation_pegi_title'))

	local hSuckItem = NativeUI.CreateItem(_U('animation_pegi_hsuck'), '')
	animPegiMenu.SubMenu:AddItem(hSuckItem)
	local fSuckItem = NativeUI.CreateItem(_U('animation_pegi_fsuck'), '')
	animPegiMenu.SubMenu:AddItem(fSuckItem)
	local hFuckItem = NativeUI.CreateItem(_U('animation_pegi_hfuck'), '')
	animPegiMenu.SubMenu:AddItem(hFuckItem)
	local fFuckItem = NativeUI.CreateItem(_U('animation_pegi_ffuck'), '')
	animPegiMenu.SubMenu:AddItem(fFuckItem)
	local scratchItem = NativeUI.CreateItem(_U('animation_pegi_scratch'), '')
	animPegiMenu.SubMenu:AddItem(scratchItem)
	local charmItem = NativeUI.CreateItem(_U('animation_pegi_charm'), '')
	animPegiMenu.SubMenu:AddItem(charmItem)
	local golddiggerItem = NativeUI.CreateItem(_U('animation_pegi_golddigger'), '')
	animPegiMenu.SubMenu:AddItem(golddiggerItem)
	local breastItem = NativeUI.CreateItem(_U('animation_pegi_breast'), '')
	animPegiMenu.SubMenu:AddItem(breastItem)
	local strip1Item = NativeUI.CreateItem(_U('animation_pegi_strip1'), '')
	animPegiMenu.SubMenu:AddItem(strip1Item)
	local strip2Item = NativeUI.CreateItem(_U('animation_pegi_strip2'), '')
	animPegiMenu.SubMenu:AddItem(strip2Item)
	local stripfloorItem = NativeUI.CreateItem(_U('animation_pegi_stripfloor'), '')
	animPegiMenu.SubMenu:AddItem(stripfloorItem)

	animPegiMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == hSuckItem then
			startAnim('oddjobs@towing', 'm_blow_job_loop')
		elseif item == fSuckItem then
			startAnim('oddjobs@towing', 'f_blow_job_loop')
		elseif item == hFuckItem then
			startAnim('mini@prostitutes@sexlow_veh', 'low_car_sex_loop_player')
		elseif item == fFuckItem then
			startAnim('mini@prostitutes@sexlow_veh', 'low_car_sex_loop_female')
		elseif item == scratchItem then
			startAnim('mp_player_int_uppergrab_crotch', 'mp_player_int_grab_crotch')
		elseif item == charmItem then
			startAnim('mini@strip_club@idles@stripper', 'stripper_idle_02')
		elseif item == golddiggerItem then
			startScenario('WORLD_HUMAN_PROSTITUTE_HIGH_CLASS')
		elseif item == breastItem then
			startAnim('mini@strip_club@backroom@', 'stripper_b_backroom_idle_b')
		elseif item == strip1Item then
			startAnim('mini@strip_club@lap_dance@ld_girl_a_song_a_p1', 'ld_girl_a_song_a_p1_f')
		elseif item == strip2Item then
			startAnim('mini@strip_club@private_dance@part2', 'priv_dance_p2')
		elseif item == stripfloorItem then
			startAnim('mini@strip_club@private_dance@part3', 'priv_dance_p3')
		end
	end
end--]]
function AddSubMenuExtraMenu(menu)
	local ped = GetPlayerPed(-1)
	current 	   = GetPlayersLastVehicle(GetPlayerPed(-1), true)
	engineHealth = GetVehicleEngineHealth(current)
	print("Fahrzeugschaden: "..engineHealth)
	
	
	if engineHealth < 1000.0000 then
		ESX.ShowNotification("Dein Fahrzeug ist beschädigt. Du kannst keine ~b~Extras~s~ anbringen/entfernen!")
	else
		extravehiclemenu = _menuPool:AddSubMenu(menu.SubMenu, "~s~Extras~s~")

		local veh_extras = {['vehicleExtras'] = {}}
		local items = {['vehicle'] = {}}
		local ped = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(ped, false)
	
	
    
		for extraID = 0, 20 do
			if DoesExtraExist(vehicle, extraID) then
				veh_extras.vehicleExtras[extraID] = (IsVehicleExtraTurnedOn(vehicle, extraID) == 1)
			end
		end
	
		for k, v in pairs(veh_extras.vehicleExtras) do
                local extraItem = NativeUI.CreateCheckboxItem('Extra ' .. k, veh_extras.vehicleExtras[k],"")
				--local extraItem = NativeUI.CreateCheckboxItem('Extra ' .. k, veh_extras.vehicleExtras[k],"Toggle for Extra "..k)
                extravehiclemenu.SubMenu:AddItem(extraItem)
                items.vehicle[k] = extraItem
		end

		extravehiclemenu.SubMenu.OnCheckboxChange = function(sender, item, checked)
			for k, v in pairs(items.vehicle) do
				if item == v then
					if engineHealth > 999.99999 then---ADD-------------------------------------------------------------------------------
						veh_extras.vehicleExtras[k] = checked
						if veh_extras.vehicleExtras[k] then
						SetVehicleExtra(vehicle, k, 0)
						else
						SetVehicleExtra(vehicle, k, 1)
						end
					else---ADD-------------------------------------------------------------------------------
						ESX.ShowNotification("Dein Fahrzeug ist beschädigt. Du kannst keine ~b~Extras~s~ anbringen/entfernen!")---ADD-------------------------------------------------------------------------------
					end---ADD-------------------------------------------------------------------------------
				end
			end
		end
	end
end




function AddSubMenuLiveryMenu(menu)
	liveryMenu = _menuPool:AddSubMenu(menu.SubMenu, "Lackierungen")
	local ped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(ped, false)
	local livery_count = GetVehicleLiveryCount(vehicle)
	local livery_list = {}
	local livery = {['vehicle'] = {}}
	local fetched_liveries = false
	
	current 	   = GetPlayersLastVehicle(GetPlayerPed(-1), true)
	engineHealth = GetVehicleEngineHealth(current)
	
	for liveryID = 1, livery_count do
		livery_list[liveryID] = liveryID
		fetched_liveries = true
    end
	
	if fetched_liveries then
		for k, v in pairs(livery_list) do
			local liveryItem = NativeUI.CreateItem('Lackierung ' .. k, "Lackierung wechseln"..k)
			liveryMenu.SubMenu:AddItem(liveryItem)
			livery.vehicle[k] = liveryItem
		end
		
		liveryMenu.SubMenu.OnItemSelect = function(sender, item, index)
			for k, v in pairs(livery.vehicle) do
				if item == v then
					if engineHealth > 999.99999 then
						ped = GetPlayerPed(-1)
						vehicle = GetVehiclePedIsIn(ped, false)
					
						SetVehicleLivery(vehicle, k)
					else---ADD-------------------------------------------------------------------------------
						ESX.ShowNotification("Dein Fahrzeug ist beschädigt. Du kannst deine ~b~Lackierung~s~ nicht ändern!")---ADD-------------------------------------------------------------------------------
					end---ADD-------------------------------------------------------------------------------
				end
			end
		end
	end
end

function AddMenuVehicleMenu(menu)
	vehicleMenu = _menuPool:AddSubMenu(menu, _U('vehicle_title'))

	vehTempomatMenu = _menuPool:AddSubMenu(vehicleMenu.SubMenu, "Tempomat")
		vehTempomatAus = NativeUI.CreateItem("Tempomat deaktiviert", "Schaltet dein Tempomat aus")
		vehTempomat30kmh = NativeUI.CreateItem("30 km/h", "Stellt deinen Tempomat auf 30 km/h ein")
		vehTempomat50kmh = NativeUI.CreateItem("50 km/h", "Stellt deinen Tempomat auf 50 km/h ein")
		vehTempomat70kmh = NativeUI.CreateItem("70 km/h", "Stellt deinen Tempomat auf 70 km/h ein")
		vehTempomat80kmh = NativeUI.CreateItem("80 km/h", "Stellt deinen Tempomat auf 80 km/h ein")
		vehTempomat100kmh = NativeUI.CreateItem("100 km/h", "Stellt deinen Tempomat auf 100 km/h ein")
		vehTempomat130kmh = NativeUI.CreateItem("130 km/h", "Stellt deinen Tempomat auf 130 km/h ein")
		vehTempomat200kmh = NativeUI.CreateItem("200 km/h", "Stellt deinen Tempomat auf 200 km/h ein")
		vehTempomat250kmh = NativeUI.CreateItem("250 km/h", "Stellt deinen Tempomat auf 250 km/h ein")
		vehTempomatMenu.SubMenu:AddItem(vehTempomatAus)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat30kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat50kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat70kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat80kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat100kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat130kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat200kmh)
		vehTempomatMenu.SubMenu:AddItem(vehTempomat250kmh)
		vehTempomatAus.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				local maxspeed = GetVehicleHandlingFloat(plyVehicle, "CHandlingData","fInitialDriveMaxFlatVel")
				SetEntityMaxSpeed(plyVehicle, maxspeed)
				ESX.ShowNotification("Tempomat wurde deaktiviert.")
			end
		end
		vehTempomat30kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 28/3.6)
				ESX.ShowNotification("Tempomat wurde auf 30 km/h gesetzt.")
			end
		end
		vehTempomat50kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 48/3.6)
				ESX.ShowNotification("Tempomat wurde auf 50 km/h gesetzt.")
			end
		end
		vehTempomat70kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 68/3.6)
				ESX.ShowNotification("Tempomat wurde auf 70 km/h gesetzt.")
			end
		end
		vehTempomat80kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 78/3.62)
				ESX.ShowNotification("Tempomat wurde auf 80 km/h gesetzt.")
			end
		end
		vehTempomat100kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 98/3.6)
				ESX.ShowNotification("Tempomat wurde auf 100 km/h gesetzt.")
			end
		end
		vehTempomat200kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 198/3.6)
				ESX.ShowNotification("Tempomat wurde auf 200 km/h gesetzt.")
			end
		end
		vehTempomat250kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 248/3.6)
				ESX.ShowNotification("Tempomat wurde auf 250 km/h gesetzt.")
			end
		end
		vehTempomat130kmh.Activated = function(sender, item, index)
			if not IsPedSittingInAnyVehicle(plyPed) then
				ESX.ShowNotification(_U('no_vehicle'))
			else
				plyVehicle = GetVehiclePedIsIn(plyPed, false)
				SetEntityMaxSpeed(plyVehicle, 128/3.62)
				ESX.ShowNotification("Tempomat wurde auf 130 km/h gesetzt.")
			end
		end
	
	AddSubMenuExtraMenu(vehicleMenu)
	--AddSubMenuTempomatMenu(vehicleMenu)
	AddSubMenuLiveryMenu(vehicleMenu)
	
	personalmenu.frontLeftDoorOpen = false
	personalmenu.frontRightDoorOpen = false
	personalmenu.backLeftDoorOpen = false
	personalmenu.backRightDoorOpen = false
	personalmenu.hoodDoorOpen = false
	personalmenu.trunkDoorOpen = false
	personalmenu.doorList = {
		_U('vehicle_door_frontleft'),
		_U('vehicle_door_frontright'),
		_U('vehicle_door_backleft'),
		_U('vehicle_door_backright'),
	}
	personalmenu.windowList = {
		"Vorne Links",
		"Vorne Rechts",
		"Hinten Links",
		"Hinten Rechts",
		"Alle Hoch",
		"Alle Runter",
	}
	
	
	
	----Lackierung-----------------------------------------------------------------------------------------------------------------
	--[[
	local ped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(ped, false)
	local livery_count = GetVehicleLiveryCount(vehicle)
	local livery_list = {}
	local fetched_liveries = false
	
	for liveryID = 1, livery_count do
		livery_list[liveryID] = liveryID
		fetched_liveries = true
    end
	
	print("Lackierungen: "..livery_count)
	
	if livery_count > -1 then
		local liveryItem = NativeUI.CreateListItem("Lackierung", livery_list, GetVehicleLivery(vehicle))
		vehicleMenu.SubMenu:AddItem(liveryItem)
	end
	--]]
	----Lackierung-----------------------------------------------------------------------------------------------------------------

	local vehEngineItem = NativeUI.CreateItem(_U('vehicle_engine_button'), '')
	vehicleMenu.SubMenu:AddItem(vehEngineItem)
	--local Liverytest = NativeUI.CreateItem("Test", '')
	--vehicleMenu.SubMenu:AddItem(Liverytest)
	
	local vehDoorListItem = NativeUI.CreateListItem("Tür", personalmenu.doorList, 1)
	vehicleMenu.SubMenu:AddItem(vehDoorListItem)
	
	local vehWindowListItem = NativeUI.CreateListItem("Fenster", personalmenu.windowList, 1)
	vehicleMenu.SubMenu:AddItem(vehWindowListItem)
	
	local vehHoodItem = NativeUI.CreateItem(_U('vehicle_hood_button'), '')
	vehicleMenu.SubMenu:AddItem(vehHoodItem)
	local vehTrunkItem = NativeUI.CreateItem(_U('vehicle_trunk_button'), '')
	vehicleMenu.SubMenu:AddItem(vehTrunkItem)
	
	local ped_extra = PlayerPedId()
	local player_extra = PlayerPedId()
	local vehicle_extra = GetVehiclePedIsIn(player_extra)
	local extra1 = false
	vehicleMenu.SubMenu.OnListSelect = function(sender, item, index)
		if not IsPedSittingInAnyVehicle(plyPed) then
			ESX.ShowNotification(_U('no_vehicle'))
		elseif IsPedSittingInAnyVehicle(plyPed) then
			plyVehicle = GetVehiclePedIsIn(plyPed, false)
			if item == vehDoorListItem then
				if index == 1 then
					if not personalmenu.frontLeftDoorOpen then
						personalmenu.frontLeftDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 0, false, false)
					elseif personalmenu.frontLeftDoorOpen then
						personalmenu.frontLeftDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 0, false, false)
					end
				elseif index == 2 then
					if not personalmenu.frontRightDoorOpen then
						personalmenu.frontRightDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 1, false, false)
					elseif personalmenu.frontRightDoorOpen then
						personalmenu.frontRightDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 1, false, false)
					end
				elseif index == 3 then
					if not personalmenu.backLeftDoorOpen then
						personalmenu.backLeftDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 2, false, false)
					elseif personalmenu.backLeftDoorOpen then
						personalmenu.backLeftDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 2, false, false)
					end
				elseif index == 4 then
					if not personalmenu.backRightDoorOpen then
						personalmenu.backRightDoorOpen = true
						SetVehicleDoorOpen(plyVehicle, 3, false, false)
					elseif personalmenu.backRightDoorOpen then
						personalmenu.backRightDoorOpen = false
						SetVehicleDoorShut(plyVehicle, 3, false, false)
					end
				end
				
			end
			--
			if item == vehWindowListItem then
				if index == 1 then
					if not leftfrontwindows then
						leftfrontwindows = true
						RollUpWindow(plyVehicle, 0, false)
					elseif leftfrontwindows then
						leftfrontwindows = false
						RollDownWindow(plyVehicle, 0, false)
					end
				elseif index == 2 then
					if not leftfrontwindows then
						leftfrontwindows = true
						RollUpWindow(plyVehicle, 1, false)
					elseif leftfrontwindows then
						leftfrontwindows = false
						RollDownWindow(plyVehicle, 1, false)
					end
				elseif index == 3 then
					if not leftfrontwindows then
						leftfrontwindows = true
						RollUpWindow(plyVehicle, 2, false)
					elseif leftfrontwindows then
						leftfrontwindows = false
						RollDownWindow(plyVehicle, 2, false)
					end
				elseif index == 4 then
					if not leftfrontwindows then
						leftfrontwindows = true
						RollUpWindow(plyVehicle, 3, false)
					elseif leftfrontwindows then
						leftfrontwindows = false
						RollDownWindow(plyVehicle, 3, false)
					end
				elseif index == 5 then
					leftfrontwindows = false
					rightfrontwindows = false
					leftbackwindow = false
					rightbackwindow = false
					RollUpWindow(plyVehicle, 0, false)
					RollUpWindow(plyVehicle, 1, false)
					RollUpWindow(plyVehicle, 2, false)
					RollUpWindow(plyVehicle, 3, false)
				elseif index == 6 then
					leftfrontwindows = true
					rightfrontwindows = true
					leftbackwindow = true
					rightbackwindow = true
					RollDownWindows(plyVehicle)
				end
			
			end	
		end	
	end
	vehicleMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if not IsPedSittingInAnyVehicle(plyPed) then
			ESX.ShowNotification(_U('no_vehicle'))
		elseif IsPedSittingInAnyVehicle(plyPed) then
			plyVehicle = GetVehiclePedIsIn(plyPed, false)
			if item == vehEngineItem then
				if GetIsVehicleEngineRunning(plyVehicle) then
					SetVehicleEngineOn(plyVehicle, false, false, true)
					SetVehicleUndriveable(plyVehicle, true)
				elseif not GetIsVehicleEngineRunning(plyVehicle) then
					SetVehicleEngineOn(plyVehicle, true, false, true)
					SetVehicleUndriveable(plyVehicle, false)
				end
			elseif item == Liverytest then
					SetVehicleLivery(plyVehicle,2)
			elseif item == vehHoodItem then
				if not personalmenu.hoodDoorOpen then
					personalmenu.hoodDoorOpen = true
					SetVehicleDoorOpen(plyVehicle, 4, false, false)
				elseif personalmenu.hoodDoorOpen then
					personalmenu.hoodDoorOpen = false
					SetVehicleDoorShut(plyVehicle, 4, false, false)
				end
			elseif item == noliveryItem then
				ESX.ShowNotification("~r~Keine~s~ andere Lackierung verfügbar")
			elseif item == vehTrunkItem then
				if not personalmenu.trunkDoorOpen then
					personalmenu.trunkDoorOpen = true
					SetVehicleDoorOpen(plyVehicle, 5, false, false)
				elseif personalmenu.trunkDoorOpen then
					personalmenu.trunkDoorOpen = false
					SetVehicleDoorShut(plyVehicle, 5, false, false)
				end
		end
	end
end
	--[[
	vehicleMenu.SubMenu.OnListChange = function(sender, item, index)
		if not IsPedSittingInAnyVehicle(plyPed) then
			ESX.ShowNotification(_U('no_vehicle'))
		elseif IsPedSittingInAnyVehicle(plyPed) then
			plyVehicle = GetVehiclePedIsIn(plyPed, false)
			if item == liveryItem then
				playerPed    = GetPlayerPed(-1)
				current 	   = GetPlayersLastVehicle(GetPlayerPed(-1), true)
				engineHealth = GetVehicleEngineHealth(plyVehicle)
	
				if engineHealth > 999.99999 then---ADD-------------------------------------------------------------------------------
					SetVehicleLivery(plyVehicle,item:IndexToItem(index))
				else---ADD-------------------------------------------------------------------------------
					ESX.ShowNotification("Dein Fahrzeug ist beschädigt. Du kannst deine ~b~Lakierung~s~ nicht ändern!")---ADD-------------------------------------------------------------------------------
				end---ADD-------------------------------------------------------------------------------
			end
        end
    end
	--]]
end

function AddMenuExtraMenu(menu)
	clothesMenu = _menuPool:AddSubMenu(menu, _U('clothes_title'))

	local torsoItem = NativeUI.CreateItem(_U('clothes_top'), '')
	clothesMenu.SubMenu:AddItem(torsoItem)
	local pantsItem = NativeUI.CreateItem(_U('clothes_pants'), '')
	clothesMenu.SubMenu:AddItem(pantsItem)
	local shoesItem = NativeUI.CreateItem(_U('clothes_shoes'), '')
	clothesMenu.SubMenu:AddItem(shoesItem)
	local bagItem = NativeUI.CreateItem(_U('clothes_bag'), '')
	clothesMenu.SubMenu:AddItem(bagItem)
	local maskItem = NativeUI.CreateItem(_U('clothes_maskItem'), '')
	clothesMenu.SubMenu:AddItem(maskItem)
	local bproofItem = NativeUI.CreateItem(_U('clothes_bproof'), '')
	clothesMenu.SubMenu:AddItem(bproofItem)

	clothesMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == torsoItem then
			setUniform('torso', plyPed)
		elseif item == pantsItem then
			setUniform('pants', plyPed)
		elseif item == shoesItem then
			setUniform('shoes', plyPed)
		elseif item == bagItem then
			setUniform('bag', plyPed)
		elseif item == maskItem then
			setUniform('maskItem', plyPed)
		elseif item == bproofItem then
			setUniform('bproof', plyPed)
		end
	end
end

function AddMenuBossMenu(menu)
	bossMenu = _menuPool:AddSubMenu(menu, _U('bossmanagement_title', ESX.PlayerData.job.label))

	local coffreItem = nil

	if societymoney ~= nil then
		coffreItem = NativeUI.CreateItem(_U('bossmanagement_chest_button'), '')
		coffreItem:RightLabel('$' .. societymoney)
		bossMenu.SubMenu:AddItem(coffreItem)
	end

	local recruterItem = NativeUI.CreateItem(_U('bossmanagement_hire_button'), '')
	bossMenu.SubMenu:AddItem(recruterItem)
	local virerItem = NativeUI.CreateItem(_U('bossmanagement_fire_button'), '')
	bossMenu.SubMenu:AddItem(virerItem)
	local promouvoirItem = NativeUI.CreateItem(_U('bossmanagement_promote_button'), '')
	bossMenu.SubMenu:AddItem(promouvoirItem)
	local destituerItem = NativeUI.CreateItem(_U('bossmanagement_demote_button'), '')
	bossMenu.SubMenu:AddItem(destituerItem)

	bossMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == recruterItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer', GetPlayerServerId(personalmenu.closestPlayer), ESX.PlayerData.job.name, 0)
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == virerItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_virerplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == promouvoirItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == destituerItem then
			if ESX.PlayerData.job.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		end
	end
end

function AddMenuBossMenu2(menu)
	bossMenu2 = _menuPool:AddSubMenu(menu, _U('bossmanagement2_title', ESX.PlayerData.job2.label))

	local coffre2Item = nil

	if societymoney2 ~= nil then
		coffre2Item = NativeUI.CreateItem(_U('bossmanagement2_chest_button'), '')
		coffre2Item:RightLabel('$' .. societymoney2)
		bossMenu2.SubMenu:AddItem(coffre2Item)
	end

	local recruter2Item = NativeUI.CreateItem(_U('bossmanagement2_hire_button'), '')
	bossMenu2.SubMenu:AddItem(recruter2Item)
	local virer2Item = NativeUI.CreateItem(_U('bossmanagement2_fire_button'), '')
	bossMenu2.SubMenu:AddItem(virer2Item)
	local promouvoir2Item = NativeUI.CreateItem(_U('bossmanagement2_promote_button'), '')
	bossMenu2.SubMenu:AddItem(promouvoir2Item)
	local destituer2Item = NativeUI.CreateItem(_U('bossmanagement2_demote_button'), '')
	bossMenu2.SubMenu:AddItem(destituer2Item)

	bossMenu2.SubMenu.OnItemSelect = function(sender, item, index)
		if item == recruter2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2', GetPlayerServerId(personalmenu.closestPlayer), ESX.PlayerData.job2.name, 0)
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == virer2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_virerplayer2', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == promouvoir2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer2', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == destituer2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer2', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		end
	end
end

function AddMenuDemarcheVoixGPS(menu)
	personalmenu.gps = {
		'Entfernen',
		'Polizei',
		'Garage MP',
		'Krankenhaus',
		'Dealer',
		'Jobcenter',
		'Fahrschule'
		--[['Auto école',
		'Téquila-la'--]]
	}

	personalmenu.demarche = {
		'Normal',
		'Homme effiminer',
		'Bouffiasse',
		'Dépressif',
		'Dépressive',
		'Muscle',
		'Hipster',
		'Business',
		'Intimide',
		'Bourrer',
		'Malheureux',
		'Triste',
		'Choc',
		'Sombre',
		'Fatiguer',
		'Presser',
		'Frimeur',
		'Fier',
		'Petite course',
		'Pupute',
		'Impertinente',
		'Arrogante',
		'Blesser',
		'Trop manger',
		'Casual',
		'Determiner',
		'Peureux',
		'Trop Swag',
		'Travailleur',
		'Brute',
		'Rando',
		'Gangstère',
		'Gangster'
	}

	--[[personalmenu.nivVoix = {
		_U('voice_whisper'),
		_U('voice_normal'),
		_U('voice_cry')
	}--]]

	local gpsItem = NativeUI.CreateListItem(_U('mainmenu_gps_button'), personalmenu.gps, actualGPSIndex)
	menu:AddItem(gpsItem)
	local demarcheItem = NativeUI.CreateListItem(_U('mainmenu_approach_button'), personalmenu.demarche, actualDemarcheIndex)
	menu:AddItem(demarcheItem)
	--[[local voixItem = NativeUI.CreateListItem(_U('mainmenu_voice_button'), personalmenu.nivVoix, actualVoiceIndex)
	menu:AddItem(voixItem)--]]

	menu.OnListSelect = function(sender, item, index)
		if item == gpsItem then
			actualGPS = item:IndexToItem(index)
			actualGPSIndex = index

			--ESX.ShowNotification(_U('gps', actualGPS))

			if actualGPS == 'Entfernen' then
				local plyCoords = GetEntityCoords(plyPed)
				SetNewWaypoint(plyCoords.x, plyCoords.y)
			elseif actualGPS == 'Polizei' then
				SetNewWaypoint(425.1, -979.55)
			elseif actualGPS == 'Krankenhaus' then
				SetNewWaypoint(302.59, -586.75)
			elseif actualGPS == 'Dealer' then
				SetNewWaypoint(-1172.13, -1571.93)
			elseif actualGPS == 'Garage MP' then
				SetNewWaypoint(213.83, -809.23)
			elseif actualGPS == 'Jobcenter' then
				SetNewWaypoint(-234.37, -920.93)
			elseif actualGPS == 'Fahrschule' then
				SetNewWaypoint(207.13, -1384.79)
			end
		elseif item == demarcheItem then
			TriggerEvent('skinchanger:getSkin', function(skin)
				actualDemarche = item:IndexToItem(index)
				actualDemarcheIndex = index

				--ESX.ShowNotification(_U('approach', actualDemarche))

				if actualDemarche == 'Normal' then
					if skin.sex == 0 then
						startAttitude('move_m@multiplayer', 'move_m@multiplayer')
					elseif skin.sex == 1 then
						startAttitude('move_f@multiplayer', 'move_f@multiplayer')
					end
				elseif actualDemarche == 'Homme effiminer' then
					startAttitude('move_m@confident', 'move_m@confident')
				elseif actualDemarche == 'Bouffiasse' then
					startAttitude('move_f@heels@c','move_f@heels@c')
				elseif actualDemarche == 'Dépressif' then
					startAttitude('move_m@depressed@a','move_m@depressed@a')
				elseif actualDemarche == 'Dépressive' then
					startAttitude('move_f@depressed@a','move_f@depressed@a')
				elseif actualDemarche == 'Muscle' then
					startAttitude('move_m@muscle@a','move_m@muscle@a')
				elseif actualDemarche == 'Hipster' then
					startAttitude('move_m@hipster@a','move_m@hipster@a')
				elseif actualDemarche == 'Business' then
					startAttitude('move_m@business@a','move_m@business@a')
				elseif actualDemarche == 'Intimide' then
					startAttitude('move_m@hurry@a','move_m@hurry@a')
				elseif actualDemarche == 'Bourrer' then
					startAttitude('move_m@hobo@a','move_m@hobo@a')
				elseif actualDemarche == 'Malheureux' then
					startAttitude('move_m@sad@a','move_m@sad@a')
				elseif actualDemarche == 'Triste' then
					startAttitude('move_m@leaf_blower','move_m@leaf_blower')
				elseif actualDemarche == 'Choc' then
					startAttitude('move_m@shocked@a','move_m@shocked@a')
				elseif actualDemarche == 'Sombre' then
					startAttitude('move_m@shadyped@a','move_m@shadyped@a')
				elseif actualDemarche == 'Fatiguer' then
					startAttitude('move_m@buzzed','move_m@buzzed')
				elseif actualDemarche == 'Presser' then
					startAttitude('move_m@hurry_butch@a','move_m@hurry_butch@a')
				elseif actualDemarche == 'Frimeur' then
					startAttitude('move_m@money','move_m@money')
				elseif actualDemarche == 'Fier' then
					startAttitude('move_m@posh@','move_m@posh@')
				elseif actualDemarche == 'Petite course' then
					startAttitude('move_m@quick','move_m@quick')
				elseif actualDemarche == 'Pupute' then
					startAttitude('move_f@maneater','move_f@maneater')
				elseif actualDemarche == 'Impertinente' then
					startAttitude('move_f@sassy','move_f@sassy')
				elseif actualDemarche == 'Arrogante' then
					startAttitude('move_f@arrogant@a','move_f@arrogant@a')
				elseif actualDemarche == 'Blesser' then
					startAttitude('move_m@injured','move_m@injured')
				elseif actualDemarche == 'Trop manger' then
					startAttitude('move_m@fat@a','move_m@fat@a')
				elseif actualDemarche == 'Casual' then
					startAttitude('move_m@casual@a','move_m@casual@a')
				elseif actualDemarche == 'Determiner' then
					startAttitude('move_m@brave@a','move_m@brave@a')
				elseif actualDemarche == 'Peureux' then
					startAttitude('move_m@scared','move_m@scared')
				elseif actualDemarche == 'Trop Swag' then
					startAttitude('move_m@swagger@b','move_m@swagger@b')
				elseif actualDemarche == 'Travailleur' then
					startAttitude('move_m@tool_belt@a','move_m@tool_belt@a')
				elseif actualDemarche == 'Brute' then
					startAttitude('move_m@tough_guy@','move_m@tough_guy@')
				elseif actualDemarche == 'Rando' then
					startAttitude('move_m@hiking','move_m@hiking')
				elseif actualDemarche == 'Gangstère' then
					startAttitude('move_m@gangster@ng','move_m@gangster@ng')
				elseif actualDemarche == 'Gangster' then
					startAttitude('move_m@gangster@generic','move_m@gangster@generic')
				end
			end)
		end
	end
end

function AddMenuAdminMenu(menu, playerGroup)
	adminMenu = _menuPool:AddSubMenu(menu, _U('admin_title'))

	if playerGroup == 'mod' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), '')
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), '')
		adminMenu.SubMenu:AddItem(tptoMeItem)
		local tptoXYZItem = NativeUI.CreateItem(_U('admin_tpxyz_button'), '')
		adminMenu.SubMenu:AddItem(tptoXYZItem)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), '')
		adminMenu.SubMenu:AddItem(noclipItem)
		local godmodeItem = NativeUI.CreateItem(_U('admin_godmode_button'), '')
		adminMenu.SubMenu:AddItem(godmodeItem)
		local ghostmodeItem = NativeUI.CreateItem(_U('admin_ghostmode_button'), '')
		adminMenu.SubMenu:AddItem(ghostmodeItem)
		local spawnVehItem = NativeUI.CreateItem(_U('admin_spawnveh_button'), '')
		adminMenu.SubMenu:AddItem(spawnVehItem)
		local repairVehItem = NativeUI.CreateItem(_U('admin_repairveh_button'), '')
		adminMenu.SubMenu:AddItem(repairVehItem)
		local returnVehItem = NativeUI.CreateItem(_U('admin_flipveh_button'), '')
		adminMenu.SubMenu:AddItem(returnVehItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), '')
		adminMenu.SubMenu:AddItem(showXYZItem)
		
		local copy_coords_vector3 = NativeUI.CreateItem("Koordinaten kopieren | Vector3", '')
		adminMenu.SubMenu:AddItem(copy_coords_vector3)
		local copy_coords_einzelnd = NativeUI.CreateItem("Koordinaten kopieren | x, y, z", '')
		adminMenu.SubMenu:AddItem(copy_coords_einzelnd)
		local copy_coords_heading = NativeUI.CreateItem("Ausrichtung kopieren", '')
		adminMenu.SubMenu:AddItem(copy_coords_heading)
		
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), '')
		adminMenu.SubMenu:AddItem(showPlrNameItem)
		local tptoWaypointItem = NativeUI.CreateItem(_U('admin_tpmarker_button'), '')
		adminMenu.SubMenu:AddItem(tptoWaypointItem)
		local revivePlrItem = NativeUI.CreateItem(_U('admin_revive_button'), '')
		adminMenu.SubMenu:AddItem(revivePlrItem)
		local skinPlrItem = NativeUI.CreateItem(_U('admin_changeskin_button'), '')
		adminMenu.SubMenu:AddItem(skinPlrItem)
		local saveSkinPlrItem = NativeUI.CreateItem(_U('admin_saveskin_button'), '')
		adminMenu.SubMenu:AddItem(saveSkinPlrItem)
		local aduty = NativeUI.CreateItem("Team Kleidung", '')
		adminMenu.SubMenu:AddItem(aduty)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == tptoMeItem then
				admin_tp_playertome()
				_menuPool:CloseAllMenus()
			elseif item == tptoXYZItem then
				admin_tp_pos()
				_menuPool:CloseAllMenus()
			elseif item == noclipItem then
				admin_no_clip()
				_menuPool:CloseAllMenus()
			elseif item == godmodeItem then
				admin_godmode()
			elseif item == ghostmodeItem then
				admin_mode_fantome()
			elseif item == spawnVehItem then
				admin_vehicle_spawn()
				_menuPool:CloseAllMenus()
			elseif item == repairVehItem then
				admin_vehicle_repair()
			elseif item == returnVehItem then
				admin_vehicle_flip()
			elseif item == showXYZItem then
				modo_showcoord()
				
			elseif item == copy_coords_vector3 then
				local plyCoords = GetEntityCoords(plyPed)
				TriggerEvent('sendToClipBoard', ""..plyCoords.."")
				print("Kopiert: ")
				print(plyCoords)
			elseif item == copy_coords_heading then
				local plyCoords = GetEntityCoords(plyPed)
				Ausrichtung = GetEntityHeading(plyPed)
				TriggerEvent('sendToClipBoard', ""..Ausrichtung.."")
				print("Kopiert: ")
				print(Ausrichtung)
			elseif item == copy_coords_einzelnd then
				local plyCoords = GetEntityCoords(plyPed)
				x = plyCoords.x
				y = plyCoords.y
				z = plyCoords.z
				print("Kopiert: ")
				print("x = "..x..", y = "..y..", z = "..z.."")
				TriggerEvent('sendToClipBoard', "x = "..x..", y = "..y..", z = "..z.."")
				
				
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == tptoWaypointItem then
				admin_tp_marker()
			elseif item == revivePlrItem then
				admin_heal_player()
				_menuPool:CloseAllMenus()
			elseif item == skinPlrItem then
				changer_skin()
			elseif item == saveSkinPlrItem then
				save_skin()
			elseif item == aduty then
				ExecuteCommand("aduty")
			elseif item == flipvehicle then
				flipvehicle()
			end
		end
	elseif playerGroup == 'support' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), '')
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), '')
		adminMenu.SubMenu:AddItem(showXYZItem)
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), '')
		adminMenu.SubMenu:AddItem(showPlrNameItem)
		local aduty = NativeUI.CreateItem("Team Kleidung", '')
		adminMenu.SubMenu:AddItem(aduty)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), '')
		adminMenu.SubMenu:AddItem(noclipItem)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == showXYZItem then
				modo_showcoord()
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == aduty then
				ExecuteCommand("aduty")
			elseif item == noclipItem then
				admin_no_clip()
				_menuPool:CloseAllMenus()
			end
		end
	elseif playerGroup == 'admin' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), '')
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), '')
		adminMenu.SubMenu:AddItem(tptoMeItem)
		local tptoXYZItem = NativeUI.CreateItem(_U('admin_tpxyz_button'), '')
		adminMenu.SubMenu:AddItem(tptoXYZItem)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), '')
		adminMenu.SubMenu:AddItem(noclipItem)
		local godmodeItem = NativeUI.CreateItem(_U('admin_godmode_button'), '')
		adminMenu.SubMenu:AddItem(godmodeItem)
		local ghostmodeItem = NativeUI.CreateItem(_U('admin_ghostmode_button'), '')
		adminMenu.SubMenu:AddItem(ghostmodeItem)
		local spawnVehItem = NativeUI.CreateItem(_U('admin_spawnveh_button'), '')
		adminMenu.SubMenu:AddItem(spawnVehItem)
		local repairVehItem = NativeUI.CreateItem(_U('admin_repairveh_button'), '')
		adminMenu.SubMenu:AddItem(repairVehItem)
		local returnVehItem = NativeUI.CreateItem(_U('admin_flipveh_button'), '')
		adminMenu.SubMenu:AddItem(returnVehItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), '')
		adminMenu.SubMenu:AddItem(showXYZItem)
		
		local copy_coords_vector3 = NativeUI.CreateItem("Koordinaten kopieren | Vector3", '')
		adminMenu.SubMenu:AddItem(copy_coords_vector3)
		local copy_coords_einzelnd = NativeUI.CreateItem("Koordinaten kopieren | x, y, z", '')
		adminMenu.SubMenu:AddItem(copy_coords_einzelnd)
		local copy_coords_heading = NativeUI.CreateItem("Ausrichtung kopieren", '')
		adminMenu.SubMenu:AddItem(copy_coords_heading)
		
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), '')
		adminMenu.SubMenu:AddItem(showPlrNameItem)
		local tptoWaypointItem = NativeUI.CreateItem(_U('admin_tpmarker_button'), '')
		adminMenu.SubMenu:AddItem(tptoWaypointItem)
		local revivePlrItem = NativeUI.CreateItem(_U('admin_revive_button'), '')
		adminMenu.SubMenu:AddItem(revivePlrItem)
		local skinPlrItem = NativeUI.CreateItem(_U('admin_changeskin_button'), '')
		adminMenu.SubMenu:AddItem(skinPlrItem)
		local saveSkinPlrItem = NativeUI.CreateItem(_U('admin_saveskin_button'), '')
		adminMenu.SubMenu:AddItem(saveSkinPlrItem)
		local aduty = NativeUI.CreateItem("Team Kleidung", '')
		adminMenu.SubMenu:AddItem(aduty)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == tptoMeItem then
				admin_tp_playertome()
				_menuPool:CloseAllMenus()
			elseif item == tptoXYZItem then
				admin_tp_pos()
				_menuPool:CloseAllMenus()
			elseif item == noclipItem then
				admin_no_clip()
				_menuPool:CloseAllMenus()
			elseif item == godmodeItem then
				admin_godmode()
			elseif item == ghostmodeItem then
				admin_mode_fantome()
			elseif item == spawnVehItem then
				admin_vehicle_spawn()
				_menuPool:CloseAllMenus()
			elseif item == repairVehItem then
				admin_vehicle_repair()
			elseif item == returnVehItem then
				admin_vehicle_flip()
			elseif item == showXYZItem then
				modo_showcoord()
				
			elseif item == copy_coords_vector3 then
				local plyCoords = GetEntityCoords(plyPed)
				TriggerEvent('sendToClipBoard', ""..plyCoords.."")
				print("Kopiert: ")
				print(plyCoords)
			elseif item == copy_coords_heading then
				local plyCoords = GetEntityCoords(plyPed)
				Ausrichtung = GetEntityHeading(plyPed)
				TriggerEvent('sendToClipBoard', ""..Ausrichtung.."")
				print("Kopiert: ")
				print(Ausrichtung)
			elseif item == copy_coords_einzelnd then
				local plyCoords = GetEntityCoords(plyPed)
				x = plyCoords.x
				y = plyCoords.y
				z = plyCoords.z
				print("Kopiert: ")
				print("x = "..x..", y = "..y..", z = "..z.."")
				TriggerEvent('sendToClipBoard', "x = "..x..", y = "..y..", z = "..z.."")
				
				
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == tptoWaypointItem then
				admin_tp_marker()
			elseif item == revivePlrItem then
				admin_heal_player()
				_menuPool:CloseAllMenus()
			elseif item == skinPlrItem then
				changer_skin()
			elseif item == saveSkinPlrItem then
				save_skin()
			elseif item == aduty then
				ExecuteCommand("aduty")
			elseif item == flipvehicle then
				flipvehicle()
			end
		end
	elseif playerGroup == 'skin' then
		local skinPlrItem = NativeUI.CreateItem(_U('admin_changeskin_button'), '')
		adminMenu.SubMenu:AddItem(skinPlrItem)
		local saveSkinPlrItem = NativeUI.CreateItem(_U('admin_saveskin_button'), '')
		adminMenu.SubMenu:AddItem(saveSkinPlrItem)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == saveSkinPlrItem then
				save_skin()
			elseif item == skinPlrItem then
				changer_skin()
			end
		end
	elseif playerGroup == 'superadmin' or playerGroup == 'owner' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), '')
		adminMenu.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), '')
		adminMenu.SubMenu:AddItem(tptoMeItem)
		local tptoXYZItem = NativeUI.CreateItem(_U('admin_tpxyz_button'), '')
		adminMenu.SubMenu:AddItem(tptoXYZItem)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), '')
		adminMenu.SubMenu:AddItem(noclipItem)
		local godmodeItem = NativeUI.CreateItem(_U('admin_godmode_button'), '')
		adminMenu.SubMenu:AddItem(godmodeItem)
		local ghostmodeItem = NativeUI.CreateItem(_U('admin_ghostmode_button'), '')
		adminMenu.SubMenu:AddItem(ghostmodeItem)
		local spawnVehItem = NativeUI.CreateItem(_U('admin_spawnveh_button'), '')
		adminMenu.SubMenu:AddItem(spawnVehItem)
		local repairVehItem = NativeUI.CreateItem(_U('admin_repairveh_button'), '')
		adminMenu.SubMenu:AddItem(repairVehItem)
		local returnVehItem = NativeUI.CreateItem(_U('admin_flipveh_button'), '')
		adminMenu.SubMenu:AddItem(returnVehItem)
		local givecashItem = NativeUI.CreateItem(_U('admin_givemoney_button'), '')
		adminMenu.SubMenu:AddItem(givecashItem)
		local givebankItem = NativeUI.CreateItem(_U('admin_givebank_button'), '')
		adminMenu.SubMenu:AddItem(givebankItem)
		local givedirtyItem = NativeUI.CreateItem(_U('admin_givedirtymoney_button'), '')
		adminMenu.SubMenu:AddItem(givedirtyItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), '')
		adminMenu.SubMenu:AddItem(showXYZItem)
		
		local copy_coords_vector3 = NativeUI.CreateItem("Koordinaten kopieren | Vector3", '')
		adminMenu.SubMenu:AddItem(copy_coords_vector3)
		local copy_coords_einzelnd = NativeUI.CreateItem("Koordinaten kopieren | x, y, z", '')
		adminMenu.SubMenu:AddItem(copy_coords_einzelnd)
		local copy_coords_heading = NativeUI.CreateItem("Ausrichtung kopieren", '')
		adminMenu.SubMenu:AddItem(copy_coords_heading)
		
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), '')
		adminMenu.SubMenu:AddItem(showPlrNameItem)
		local tptoWaypointItem = NativeUI.CreateItem(_U('admin_tpmarker_button'), '')
		adminMenu.SubMenu:AddItem(tptoWaypointItem)
		local revivePlrItem = NativeUI.CreateItem(_U('admin_revive_button'), '')
		adminMenu.SubMenu:AddItem(revivePlrItem)
		local skinPlrItem = NativeUI.CreateItem(_U('admin_changeskin_button'), '')
		adminMenu.SubMenu:AddItem(skinPlrItem)
		local saveSkinPlrItem = NativeUI.CreateItem(_U('admin_saveskin_button'), '')
		adminMenu.SubMenu:AddItem(saveSkinPlrItem)
		local aduty = NativeUI.CreateItem("Team Kleidung", '')
		adminMenu.SubMenu:AddItem(aduty)
		--local flipvehicle = NativeUI.CreateItem("Fahrzeug umdrehen", '')	
		--adminMenu.SubMenu:AddItem(flipvehicle)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				_menuPool:CloseAllMenus()
			elseif item == tptoMeItem then
				admin_tp_playertome()
				_menuPool:CloseAllMenus()
			elseif item == tptoXYZItem then
				admin_tp_pos()
				_menuPool:CloseAllMenus()
			elseif item == noclipItem then
				admin_no_clip()
				_menuPool:CloseAllMenus()
			elseif item == godmodeItem then
				admin_godmode()
			elseif item == ghostmodeItem then
				admin_mode_fantome()
			elseif item == spawnVehItem then
				admin_vehicle_spawn()
				_menuPool:CloseAllMenus()
			elseif item == repairVehItem then
				admin_vehicle_repair()
			elseif item == returnVehItem then
				admin_vehicle_flip()
			elseif item == givecashItem then
				admin_give_money()
				_menuPool:CloseAllMenus()
			elseif item == givebankItem then
				admin_give_bank()
				_menuPool:CloseAllMenus()
			elseif item == givedirtyItem then
				admin_give_dirty()
				_menuPool:CloseAllMenus()
			elseif item == showXYZItem then
				modo_showcoord()
				
			elseif item == copy_coords_vector3 then
				local plyCoords = GetEntityCoords(plyPed)
				TriggerEvent('sendToClipBoard', ""..plyCoords.."")
				print("Kopiert: ")
				print(plyCoords)
			elseif item == copy_coords_heading then
				local plyCoords = GetEntityCoords(plyPed)
				Ausrichtung = GetEntityHeading(plyPed)
				TriggerEvent('sendToClipBoard', ""..Ausrichtung.."")
				print("Kopiert: ")
				print(Ausrichtung)
			elseif item == copy_coords_einzelnd then
				local plyCoords = GetEntityCoords(plyPed)
				x = plyCoords.x
				y = plyCoords.y
				z = plyCoords.z
				print("Kopiert: ")
				print("x = "..x..", y = "..y..", z = "..z.."")
				TriggerEvent('sendToClipBoard', "x = "..x..", y = "..y..", z = "..z.."")
				
				
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == tptoWaypointItem then
				admin_tp_marker()
			elseif item == revivePlrItem then
				admin_heal_player()
				_menuPool:CloseAllMenus()
			elseif item == skinPlrItem then
				changer_skin()
			elseif item == saveSkinPlrItem then
				save_skin()
			elseif item == aduty then
				ExecuteCommand("aduty")
			elseif item == flipvehicle then
				flipvehicle()
			end
		end
	end
end


--AKTIONEN


function closestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

function AddMenuAktionen(menu, playerGroup)
	aktionenMenu = _menuPool:AddSubMenu(menu, "Aktionen")
	
	local search = NativeUI.CreateItem("Durchsuchen", "Durchsuche eine Person")
	aktionenMenu.SubMenu:AddItem(search)
	--local tragen = NativeUI.CreateItem("Tragen", "Trage eine Person")
	--aktionenMenu.SubMenu:AddItem(tragen)
	--local putinvehicle = NativeUI.CreateItem("Ins Fahrzeug setzen", "Setze die Person ins Fahrzeug die du aktuell trägst")
	--aktionenMenu.SubMenu:AddItem(putinvehicle)
	--local outthevehicle = NativeUI.CreateItem("Aus dem Fahrzeug rausholen", "Hole die gefesselte Person aus dem Fahrzeug raus")
	--aktionenMenu.SubMenu:AddItem(outthevehicle)
	local haendehoch = NativeUI.CreateItem("Händer hoch", "Hände hochnehmen")
	aktionenMenu.SubMenu:AddItem(haendehoch)
	local hinknien = NativeUI.CreateItem("Hinknien", "Hinknien und Hände an den Kopf")
	aktionenMenu.SubMenu:AddItem(hinknien)
	local sitzplatzwechseln = NativeUI.CreateItem("Fahrersitz", "Auf den Fahrersitz wechseln")
	aktionenMenu.SubMenu:AddItem(sitzplatzwechseln)
	
	aktionenMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == haendehoch then
				RequestAnimDict('random@mugging3')

					while not HasAnimDictLoaded('random@mugging3') do
						Citizen.Wait(10)
					end

					TaskPlayAnim(plyPed, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0, 0, 0, 0)
					_menuPool:CloseAllMenus()
			elseif item == sitzplatzwechseln then
				ExecuteCommand("shuff")
				_menuPool:CloseAllMenus()
			elseif action == tragen then
				TriggerServerEvent('esx_police:drag', GetPlayerServerId(closestPlayer))
				_menuPool:CloseAllMenus()
			elseif item == hinknien then
				ExecuteCommand("huk")
				_menuPool:CloseAllMenus()
			elseif item == documentenmenu then
				ExecuteCommand("docs")
				_menuPool:CloseAllMenus()
			elseif item == reportaktion then
				local reportnachricht = KeyboardInput('KORIOZ_BOX_MESSAGE', "Nachricht:", '', 200)
				local spieler_id = GetPlayerServerId(PlayerId())
				local spielername = GetPlayerName(PlayerId())
				TriggerServerEvent('nils_script:report', reportnachricht, spielername, spieler_id, false)
				_menuPool:CloseAllMenus()
			end
		end
end


--OpenBodySearchMenu für das Durchsuchen--

function search(menu)
    local newitem = NativeUI.CreateItem("Person durchsuchen", "Durchsuche eine Person auf Gegenstände")
    menu:AddItem(newitem)
    menu.OnItemSelect = function(sender, item, index)
        if item == newitem then
            TriggerServerEvent('esx_policejob:message', GetPlayerServerId(closestPlayer), _U('being_searched'))
            ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
                local elements = {}
        
                for i=1, #data.accounts, 1 do
                    if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
                        table.insert(elements, {
                            label    = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
                            value    = 'black_money',
                            itemType = 'item_account',
                            amount   = data.accounts[i].money
                        })
        
                        break
                    end
                end
        
                table.insert(elements, {label = _U('guns_label')})
        
                for i=1, #data.weapons, 1 do
                    table.insert(elements, {
                        label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
                        value    = data.weapons[i].name,
                        itemType = 'item_weapon',
                        amount   = data.weapons[i].ammo
                    })
                end
        
                table.insert(elements, {label = _U('inventory_label')})
        
                for i=1, #data.inventory, 1 do
                    if data.inventory[i].count > 0 then
                        table.insert(elements, {
                            label    = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
                            value    = data.inventory[i].name,
                            itemType = 'item_standard',
                            amount   = data.inventory[i].count
                        })
                    end
                end
        
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
                    title    = _U('search'),
                    align    = 'top-right',
                    elements = elements
                }, function(data, menu)
                    if data.current.value then
                        TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
                        OpenBodySearchMenu(player)
                    end
                end, function(data, menu)
                    menu.close()
                end)
            end, GetPlayerServerId(player))
        else
            ESX.ShowNotification('Aktion nicht möglich')
        end
    end
end


--Drag zum Tragen/Ins Fahrzeug setzen/rausholen
RegisterNetEvent('esx_policejob:drag')
AddEventHandler('esx_policejob:drag', function(copId)
	if IsHandcuffed then
		dragStatus.isDragged = not dragStatus.isDragged
		dragStatus.CopId = copId
	end
end)

Citizen.CreateThread(function()
	local wasDragged

	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if IsHandcuffed and dragStatus.isDragged then
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Citizen.Wait(1000)
				end
			else
				wasDragged = false
				dragStatus.isDragged = false
				DetachEntity(playerPed, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(playerPed, true, false)
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()
	if IsHandcuffed then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if IsAnyVehicleNearPoint(coords, 5.0) then
			local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

			if DoesEntityExist(vehicle) then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

				for i=maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end

				if freeSeat then
					TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
					dragStatus.isDragged = false
				end
			end
		end
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 16)
	end
end)

--AKTIONEN ENDE
--Einstellungen

function AddMenuEinstellungen(menu, playerGroup)
	einstellungenMenu = _menuPool:AddSubMenu(menu, "Einstellungen")
	
	local sprachweite = NativeUI.CreateItem("Sprachweite", "Sprachweite umschalten")
	aktionenMenu.SubMenu:AddItem(sprachweite)
	
end
--Einstellungen Ende
function flipvehicle()
	local plyCoords = GetEntityCoords(plyPed)
	local newCoords = plyCoords + vector3(0.0, 2.0, 0.0)
	local closestVeh = GetClosestVehicle(plyCoords, 10.0, 0, 70)

	SetEntityCoords(closestVeh, newCoords)
	--ESX.ShowNotification(_U('admin_vehicleflip'))
end
				
function GeneratePersonalMenu(playerGroup)
	
	AddMenuAktionen(mainMenu)
	--AddMenuInventoryMenu(mainMenu)

	AddMenuWeaponMenu(mainMenu)
	AddMenuWalletMenu(mainMenu)
	AddMenuClothesMenu(mainMenu)
	--AddMenuAccessoryMenu(mainMenu)
	--AddMenuAnimationMenu(mainMenu)
	--AddMenuEinstellungen(mainMenu)
	if IsPedSittingInAnyVehicle(plyPed) then
		if (GetPedInVehicleSeat(GetVehiclePedIsIn(plyPed, false), -1) == plyPed) then
			AddMenuVehicleMenu(mainMenu)
		end
	end
	

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		AddMenuBossMenu(mainMenu)
	end

	if Config.doublejob then
		if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
			AddMenuBossMenu2(mainMenu)
		end
	end

	AddMenuFacturesMenu(mainMenu)
	AddMenuDemarcheVoixGPS(mainMenu)

	if playerGroup ~= nil and (playerGroup == 'moderator' or playerGroup == 'skin' or playerGroup == 'support' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then
		AddMenuAdminMenu(mainMenu, playerGroup)
	end

	_menuPool:RefreshIndex()
end

Citizen.CreateThread(function()
	while true do
		if IsControlJustReleased(0, Config.Menu.clavier) and not isDead then
			if mainMenu ~= nil and not mainMenu:Visible() then
				ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(playerGroup)
					ESX.PlayerData = ESX.GetPlayerData()
					GeneratePersonalMenu(playerGroup)
					mainMenu:Visible(true)
					Citizen.Wait(10)
				end)
			end
		end
		
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		if _menuPool ~= nil then
			_menuPool:ProcessMenus()
		end
		
		Citizen.Wait(0)
	end
end)
Citizen.CreateThread(function()
	while true do
		while _menuPool ~= nil and _menuPool:IsAnyMenuOpen() do
			Citizen.Wait(0)

			if not _menuPool:IsAnyMenuOpen() then
				mainMenu:Clear()
				itemMenu:Clear()
				weaponItemMenu:Clear()

				_menuPool:Clear()
				_menuPool:Remove()

				personalmenu = {}

				invItem = {}
				wepItem = {}
				billItem = {}

				collectgarbage()

				_menuPool = NativeUI.CreatePool()

				mainMenu = NativeUI.CreateMenu(Config.servername, _U('mainmenu_subtitle'))
				itemMenu = NativeUI.CreateMenu(Config.servername, _U('inventory_actions_subtitle'))
				weaponItemMenu = NativeUI.CreateMenu(Config.servername, _U('loadout_actions_subtitle'))
				_menuPool:Add(mainMenu)
				_menuPool:Add(itemMenu)
				_menuPool:Add(weaponItemMenu)
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()
		
		if IsControlJustReleased(0, Config.stopAnim.clavier) and GetLastInputMethod(2) and not isDead then
			handsup, pointing = false, false
			ClearPedTasks(plyPed)
		end

		if IsControlPressed(1, Config.TPMarker.clavier1) and IsControlJustReleased(1, Config.TPMarker.clavier2) and GetLastInputMethod(2) and not isDead then
			ESX.TriggerServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(playerGroup)
				if playerGroup ~= nil and (playerGroup == 'moderator' or playerGroup == 'support' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then
					admin_tp_marker()
				end
			end)
		end

		if showcoord then
			local playerPos = GetEntityCoords(plyPed)
			Text('~r~X: ' .. playerPos.x .. ' ~n~~r~Y:~r~ ' .. playerPos.y .. ' ~n~~r~Z: ' .. playerPos.z .. ' ~n~~r~Angle: ' .. GetEntityHeading(plyPed))--Text('~r~X~s~: ' .. playerPos.x .. ' ~b~Y~s~: ' .. playerPos.y .. ' ~g~Z~s~: ' .. playerPos.z .. ' ~y~Angle~s~: ' .. GetEntityHeading(plyPed))
		end

		if noclip then
			local coords = GetEntityCoords(plyPed)
			local camCoords = getCamDirection()

			SetEntityVelocity(plyPed, 0.01, 0.01, 0.01)

			if IsControlPressed(0, 32) then
				coords = coords + (Config.noclip_speed * camCoords)
			end

			if IsControlPressed(0, 269) then
				coords = coords - (Config.noclip_speed * camCoords)
			end

			SetEntityCoordsNoOffset(plyPed, coords, true, true, true)
		end

		if showname then
			for k, v in ipairs(GetActivePlayers()) do
				local otherPed = GetPlayerPed(v)
				if otherPed ~= plyPed then
					local closeEnough = Vdist2(GetEntityCoords(plyPed), GetEntityCoords(otherPed)) < 10000.0
					if closeEnough and gamerTags[v] == nil then
						gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('%s [%s]'):format(GetPlayerName(v), GetPlayerServerId(v)), false, false, '', 0)
					elseif not closeEnough then
						RemoveMpGamerTag(gamerTags[v])
						gamerTags[v] = nil
					end
				end
			end
		end
		
		Citizen.Wait(0)
	end
end)


[[-----
Dont touch this right here
]]