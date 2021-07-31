local isVisible = false
local tabletObject = nil
local callBip = nil
local zones = { ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }


TriggerServerEvent("prp-mdt:getOffensesAndOfficer")

RegisterNetEvent("prp-mdt:toggleVisibilty")
AddEventHandler("prp-mdt:toggleVisibilty", function(reports, warrants, officer, job)
    local playerPed = PlayerPedId()
    if not isVisible then
        local dict = "amb@world_human_seat_wall_tablet@female@base"
        RequestAnimDict(dict)
        if tabletObject == nil then
            tabletObject = CreateObject(GetHashKey('prop_cs_tablet'), GetEntityCoords(playerPed), 1, 1, 1)
            AttachEntityToEntity(tabletObject, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.03, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        end
        while not HasAnimDictLoaded(dict) do Citizen.Wait(100) end
        if not IsEntityPlayingAnim(playerPed, dict, 'base', 3) then
            TaskPlayAnim(playerPed, dict, "base", 8.0, 1.0, -1, 49, 1.0, 0, 0, 0)
        end
    else
        DeleteEntity(tabletObject)
        ClearPedTasks(playerPed)
        tabletObject = nil
    end
    if #warrants == 0 then warrants = false end
    if #reports == 0 then reports = false end
    SendNUIMessage({
        type = "recentReportsAndWarrantsLoaded",
        reports = reports,
        warrants = warrants,
        officer = officer,
        department = job
    })
    ToggleGUI()
    TriggerServerEvent("prp-mdt:getOffensesAndOfficer")
end)

RegisterNetEvent("prp-mdt:hotKeyOpen")
AddEventHandler("prp-mdt:hotKeyOpen", function()
    local myjob = exports["prp_manager"]:isPed("myjob")
    if myjob == "police" then
        TriggerServerEvent('prp-mdt:Open', "police")
    elseif myjob == "DOJ" then
        TriggerServerEvent('prp-mdt:Open', "DOJ")
    end
end)

RegisterNUICallback("close", function(data, cb)
    local playerPed = PlayerPedId()
    DeleteEntity(tabletObject)
    ClearPedTasks(playerPed)
    tabletObject = nil
    ToggleGUI(false)
    cb('ok')
end)

RegisterNUICallback("performOffenderSearch", function(data, cb)
    TriggerServerEvent("prp-mdt:performOffenderSearch", data.query)
    cb('ok')
end)

RegisterNUICallback("viewOffender", function(data, cb)
    TriggerServerEvent("prp-mdt:getOffenderDetails", data.offender)
    cb('ok')
end)

RegisterNUICallback("saveOffenderChanges", function(data, cb)
    TriggerServerEvent("prp-mdt:saveOffenderChanges", data.id, data.changes, data.identifier)
    cb('ok')
end)

RegisterNUICallback("submitNewReport", function(data, cb)
    TriggerServerEvent("prp-mdt:submitNewReport", data)
    cb('ok')
end)

RegisterNUICallback("performReportSearch", function(data, cb)
    TriggerServerEvent("prp-mdt:performReportSearch", data.query)
    cb('ok')
end)

RegisterNUICallback("getOffender", function(data, cb)
    TriggerServerEvent("prp-mdt:getOffenderDetailsById", data.char_id)

    cb('ok')
end)

RegisterNUICallback("deleteReport", function(data, cb)
    TriggerServerEvent("prp-mdt:deleteReport", data.id)
    TriggerServerEvent("prp-mdt:delreport")
    cb('ok')
end)

RegisterNUICallback("saveReportChanges", function(data, cb)
    TriggerServerEvent("prp-mdt:saveReportChanges", data)
    cb('ok')
end)

-- RegisterNUICallback("vehicleSearch", function(data, cb)
--     TriggerServerEvent("prp-mdt:performVehicleSearch", data.plate)
--     cb('ok')
-- end)

-- RegisterNUICallback("getVehicle", function(data, cb)
--     TriggerServerEvent("prp-mdt:getVehicle", data.vehicle)
--     cb('ok')
-- end)

RegisterNUICallback("getWarrants", function(data, cb)
    TriggerServerEvent("prp-mdt:getWarrants")
end)

RegisterNUICallback("submitNewWarrant", function(data, cb)
    TriggerServerEvent("prp-mdt:submitNewWarrant", data)
    cb('ok')
end)

RegisterNUICallback("deleteWarrant", function(data, cb)
    TriggerServerEvent("prp-mdt:deleteWarrant", data.id)
    TriggerServerEvent('prp-mdt:delwarrant')
    cb('ok')
end)

RegisterNUICallback("getReport", function(data, cb)
    TriggerServerEvent("prp-mdt:getReportDetailsById", data.id)
    cb('ok')
end)

-- RegisterNUICallback("saveVehicleChanges", function(data, cb)
--     TriggerServerEvent("prp-mdt:saveVehicleChanges", data)
--     cb('ok')
-- end)

RegisterNetEvent("prp-mdt:returnOffenderSearchResults")
AddEventHandler("prp-mdt:returnOffenderSearchResults", function(results)
    SendNUIMessage({
        type = "returnedPersonMatches",
        matches = results
    })
end)

RegisterNetEvent("prp-mdt:closeModal")
AddEventHandler("prp-mdt:closeModal", function()
    SendNUIMessage({
        type = "closeModal"
    })
end)

RegisterNetEvent("prp-mdt:returnOffenderDetails")
AddEventHandler("prp-mdt:returnOffenderDetails", function(data)
    -- for i = 1, #data.vehicles do
    --     data.vehicles[i].model = GetLabelText(GetDisplayNameFromVehicleModel(data.vehicles[i].model))
    -- end
    SendNUIMessage({
        type = "returnedOffenderDetails",
        details = data
    })
end)

RegisterNetEvent("prp-mdt:returnOffensesAndOfficer")
AddEventHandler("prp-mdt:returnOffensesAndOfficer", function(data, name)
    SendNUIMessage({
        type = "offensesAndOfficerLoaded",
        offenses = data,
        name = name
    })
end)

RegisterNetEvent("prp-mdt:returnReportSearchResults")
AddEventHandler("prp-mdt:returnReportSearchResults", function(results)
    SendNUIMessage({
        type = "returnedReportMatches",
        matches = results
    })
end)

-- RegisterNetEvent("prp-mdt:returnVehicleSearchInFront")
-- AddEventHandler("prp-mdt:returnVehicleSearchInFront", function(results, plate)
--     SendNUIMessage({
--         type = "returnedVehicleMatchesInFront",
--         matches = results,
--         plate = plate
--     })
-- end)

-- RegisterNetEvent("prp-mdt:returnVehicleSearchResults")
-- AddEventHandler("prp-mdt:returnVehicleSearchResults", function(results)
--     SendNUIMessage({
--         type = "returnedVehicleMatches",
--         matches = results
--     })
-- end)

-- RegisterNetEvent("prp-mdt:returnVehicleDetails")
-- AddEventHandler("prp-mdt:returnVehicleDetails", function(data)
--     if type(data.model) == 'number' then
--         data.model = GetLabelText(GetDisplayNameFromVehicleModel(data.model))
--     end
--     SendNUIMessage({
--         type = "returnedVehicleDetails",
--         details = data
--     })
-- end)

RegisterNetEvent("prp-mdt:returnWarrants")
AddEventHandler("prp-mdt:returnWarrants", function(data)
    SendNUIMessage({
        type = "returnedWarrants",
        warrants = data
    })
end)

RegisterNetEvent("prp-mdt:completedWarrantAction")
AddEventHandler("prp-mdt:completedWarrantAction", function(data)
    SendNUIMessage({
        type = "completedWarrantAction"
    })
end)

RegisterNetEvent("prp-mdt:returnReportDetails")
AddEventHandler("prp-mdt:returnReportDetails", function(data)
    SendNUIMessage({
        type = "returnedReportDetails",
        details = data
    })
end)

RegisterNetEvent("prp-mdt:sendNUIMessage")
AddEventHandler("prp-mdt:sendNUIMessage", function(messageTable)
    SendNUIMessage(messageTable)
end)

RegisterNetEvent("prp-mdt:sendNotification")
AddEventHandler("prp-mdt:sendNotification", function(message)
    SendNUIMessage({
        type = "sendNotification",
        message = message
    })
end)


function ToggleGUI(explicit_status)
  if explicit_status ~= nil then
    isVisible = explicit_status
  else
    isVisible = not isVisible
  end
  SetNuiFocus(isVisible, isVisible)
  SendNUIMessage({
    type = "enable",
    isVisible = isVisible
  })
end

