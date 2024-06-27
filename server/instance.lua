local instance = json.decode(LoadResourceFile("dvr_instance", 'server/data/instance.json'))
local VORPcore = exports.vorp_core:GetCore() 
CreateThread(function()
    SaveResourceFile(GetCurrentResourceName(), "./server/data/instance.json", json.encode(instance, {indent=true}), -1) 
end)

local function GenerateInstanceId()
    local timestamp = os.time()
    local randomSeed = math.random(1000, 9999)
    local hash = 0
    
    while randomSeed > 0 do
        hash = hash + randomSeed % 10
        randomSeed = math.floor(randomSeed / 10)
    end
 
    return timestamp + hash
end

RegisterNetEvent('dvr_instance:setInstance', function(instance)
    local _source = source 
    GlobalState.instance = instance
    SetPlayerRoutingBucket(_source, instance or 0)
end)

RegisterNetEvent('dvr_instance:loadInstance', function()
    local _source = source
    TriggerClientEvent('dvr_instance:InstanceTable', _source, instance)
end)

RegisterNetEvent('dvr_instance:removeInstance', function(instanceID, type)
    local _source = source 
    local instanceID = tonumber(instanceID)
    local xPlayers = GetPlayers()

    for i, v in ipairs(instance) do
        if v.number == instanceID then
            table.remove(instance, i)
            break
        end
    end

    VORPcore.NotifyTip(_source, "Instance n° " ..instanceID.. " : " ..type.. " à bien été supprimé ", 4000)
    SaveResourceFile(GetCurrentResourceName(), "./server/data/instance.json", json.encode(instance, {indent=true}), -1) 

    for _, xsources in pairs(xPlayers) do
        if GetPlayerRoutingBucket(xsources) == instanceID then 
            SetPlayerRoutingBucket(xsources, 0)
        end

        TriggerClientEvent('dvr_instance:InstanceTable', xsources, instance)
    end
end)

RegisterNetEvent('dvr_instance:createInstance', function(name, instanceID, coords, type)
    local _source = source 
    local xPlayers = GetPlayers()
    if instanceID == nil or instanceID == "" then 
        instanceID = GenerateInstanceId()
    end

    for _, v in ipairs(instance) do
        if v.number == instanceID then
            VORPcore.NotifyTip(_source, "Instance n° " ..instanceID.. " existe déjà ", 4000)
            return
        end
    end

    table.insert(instance, {
        name = name,
        number = instanceID,
        coords = coords,
        type = type
    })

    VORPcore.NotifyTip(_source, "Instance n° " ..instanceID.. " : " ..type.. " à bien été crée ", 4000)
    SaveResourceFile(GetCurrentResourceName(), "./server/data/instance.json", json.encode(instance, {indent=true}), -1) 

    for _, xsources in pairs(xPlayers) do
        TriggerClientEvent('dvr_instance:InstanceTable', xsources, instance)
    end
end)