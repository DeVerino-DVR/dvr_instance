local VORPMenu, lastInstance = {}, 0
local Instance = {}
local VORPcore = exports.vorp_core:GetCore() 
local playerSetInInstance = false 
local PolyStart = false 
TriggerEvent("vorp_menu:getData",function(cb)
    VORPMenu = cb
end)

CreateThread(function()
    if not LocalPlayer.state.IsInSession then
        repeat Wait(0) until LocalPlayer.state.IsInSession and LocalPlayer.state.Character and not IsLoadingScreenVisible() and not IsScreenFadedOut()
    end

    TriggerServerEvent('dvr_instance:loadInstance')
end)

RegisterNetEvent('dvr_instance:InstanceTable', function(IstTable)
    Instance = IstTable
end)

local function drawMe(x, y, z, text, dist, marker)
	local playerCoords = GetEntityCoords(PlayerPedId())
	if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, x, y, z, true) < dist then
		local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
		local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
		if onScreen then
			SetTextScale(0.30, 0.30)
			SetTextFontForCurrentCommand(1)
			SetTextColor(180, 180, 240, 205)
			SetTextCentre(1)
			DisplayText(str,_x,_y)
			local factor = (string.len(text)) / 225
			if marker ~= nil then
				Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, x, y, z-1.0, 0, 0, 0, 0, 0, 0, 1.3, 1.3, 0.4, 255, 200, 122, 155, 0, 0, 2, 0, 0, 0, 0)
			end
		end
	end
end

local function IsPlayerInsidePolygon(playerPos, polyPoints, debug)
    local oddNodes = false
    local x, y = playerPos.x, playerPos.y

    for i = 1, #polyPoints do
        if debug then
            local label = tostring(i)
            drawMe(polyPoints[i].x, polyPoints[i].y, polyPoints[i].z + 1.0, label, 4.0)
            Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, polyPoints[i].x, polyPoints[i].y, polyPoints[i].z - 1.0, 0, 0, 0, 0, 0, 0, 0.05, 0.05, 4.0, 255, 255, 255, 100, 0, 0, 2, 0, 0, 0, 0)
        end

        local j = i % #polyPoints + 1
        if ((polyPoints[i].y <= y and polyPoints[j].y > y) or (polyPoints[j].y <= y and polyPoints[i].y > y)) then
            if (polyPoints[i].x + (y - polyPoints[i].y) / (polyPoints[j].y - polyPoints[i].y) * (polyPoints[j].x - polyPoints[i].x) < x) then
                oddNodes = not oddNodes
            end
        end
    end

    return oddNodes
end

local function GetInteriorPolyZone()
    for _, data in ipairs(Instance) do
        if data.coords ~= "none" then 
            local isInside = IsPlayerInsidePolygon(GetEntityCoords(PlayerPedId()), data.coords, false)
            if isInside then
                return true, data.number
            end
        end
    end

    return false, 0
end

CreateThread(function()
    if not LocalPlayer.state.IsInSession then
        repeat Wait(0) until LocalPlayer.state.IsInSession and LocalPlayer.state.Character and not IsLoadingScreenVisible() and not IsScreenFadedOut()
    end

    while true do
        local playerPed = PlayerPedId()
        local interiorID = GetInteriorFromEntity(playerPed)
        local interiorPoly, instance = GetInteriorPolyZone()
        if interiorPoly and not playerSetInInstance then
            TriggerServerEvent('dvr_instance:setInstance', instance)
            playerSetInInstance = true
            print("Envoyer le joueur dans l'instance:", instance)
        elseif not interiorPoly and playerSetInInstance then
            print("Retirer le joueur de l'instance")
            playerSetInInstance = false
            TriggerServerEvent('dvr_instance:setInstance', 0)
        else
            if interiorID ~= lastInstance then
                local currentInstanceData = nil
                for _, data in ipairs(Instance) do
                    if tostring(data.number) == tostring(interiorID) then
                        currentInstanceData = data
                        break
                    end
                end

                if currentInstanceData ~= nil then
                    print("Envoyer le joueur dans l'instance:", currentInstanceData.number)
                    TriggerServerEvent('dvr_instance:setInstance', currentInstanceData.number)
                elseif interiorID == 0 and lastInstance ~= 0 then
                    print("Retirer le joueur de l'instance")
                    TriggerServerEvent('dvr_instance:setInstance', 0)
                end
            end
        end

        lastInstance = interiorID

        if tonumber(GlobalState.instance) ~= 0 then
            Wait(1000)
        else
            Wait(5)
        end
    end
end)

local function ExecutePoly(name, instanceNumber)
    CreateThread(function()
        local points = {}
        while true do 
            local coords = GetEntityCoords(PlayerPedId())
            IsPlayerInsidePolygon(coords, points, true)
            if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x07B8BEAF) then
                table.insert(points, vector3(coords.x, coords.y, coords.z))
            end

            if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x53296B75) then
                if #points > 0 then
                    table.remove(points, #points)
                    if #points == 0 then 
                        points = {}
                    end
                end
            end

            if Citizen.InvokeNative(0x91AEF906BCA88877, 0, 0x2CD5343E) then
                TriggerServerEvent('dvr_instance:createInstance', name, instanceNumber, points, "poly")
                points = {}
                return false
            end
            Wait(1)
        end
    end)
end

function OpenInstanceMenu()
    VORPMenu.CloseAll()
    if Instance then
        local elements = {
            {label = "Créer une nouvelle instance", value = "create"},
            {label = "⇩⇩⇩ INSTANCES EXISTANTES ⇩⇩⇩"}
        }

        for _, v in ipairs(Instance) do
            table.insert(elements, {label = v.name, value = v, desc = "Instance n°"..v.number.. " type " ..v.type})
        end

        VORPMenu.Open("default", GetCurrentResourceName(), "chest_type_menu", {
            title = "Instances",
            subtext = "Sélectionnez une instance",
            align = "align", 
            elements = elements, 
            itemHeight = "2vh", 
        },
        function(data, menu)
            if data.current.value == "create" then 
                local alert = lib.alertDialog({
                    header = 'Crée une instance',
                    content = 'Vous allez crée une instance',
                    centered = false,
                    cancel = true,
                    size = "xs",
                    labels = {
                        cancel = "Interieur",
                        confirm = "Poly"
                    }
                })

                local input = lib.inputDialog('Information', {"Nom de l'instance (ex Banque de Valentine)"})
                if not input then return end
                if input[1] then 
                    local playerPed = PlayerPedId()
                    local interiorID = GetInteriorFromEntity(playerPed)
                    if alert == "cancel" then 
                        if interiorID == 0 then 
                            return VORPcore.NotifyTip("Aucun interieur de disponible merci de faire une polyzone", 4000)
                        end

                        TriggerServerEvent('dvr_instance:createInstance', input[1], interiorID, "none", "interior")
                        menu.close()
                    elseif alert == "confirm" then
                        if interiorID ~= 0 then 
                            return VORPcore.NotifyTip("Interieur n°" ..interiorID.. " disponible merci de ne pas faire de polyzone ici", 4000)
                        end
                 
                        ExecutePoly(input[1], nil)
                        menu.close() 
                    end
                else
                    VORPcore.NotifyTip("Vous n'avez pas mis de nom", 4000)
                end
            else
                if data.current.value ~= nil then 
                    local alert = lib.alertDialog({
                        header = 'ATTENTION',
                        content = "Voulez vous supprimer l'instance n°" ..data.current.value.number .. " type: " .. data.current.value.type,
                        centered = true,
                        cancel = true,
                        size = "xl"
                    })
                    
                    if alert == "confirm" then
                        TriggerServerEvent('dvr_instance:removeInstance', data.current.value.number, data.current.value.type)
                        menu.close() 
                    end
                end
            end
        end,
        function(_, menu)
            menu.close()
        end)
    end
end

RegisterCommand('getInstance', function()
    local interiorPoly, instance = GetInteriorPolyZone()
    print("interiorPoly: " ..tostring(interiorPoly))
    print("instance: " ..instance)
end)

RegisterCommand('createInstance', function()
    if LocalPlayer.state.Character.Group == "admin" then
        OpenInstanceMenu()
    end
end, false)

RegisterCommand('instance', function()
    local playerPed = PlayerPedId()
    local interiorID = GetInteriorFromEntity(playerPed)
    if interiorID == 0 then 
        print('Aucun interieur disponible ici merci d\'utiliser la polyzone !')
        return VORPcore.NotifyTip("Aucun interieur disponible ici merci d\'utiliser la polyzone !", 4000)
    end


    print("Interieur disponible: " ..interiorID)
    VORPcore.NotifyTip("Interieur disponible: " ..interiorID, 4000)
end, false)

exports('GetInteriorPolyZone', GetInteriorPolyZone)