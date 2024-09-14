local PlayerData = {}
local notifiedOfficers = {}

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(Config.delay)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterCommand(Config.command, function()
    if PlayerData.job and PlayerData.job.name == 'police' then
        if IsPlayerDead(PlayerId()) then
            print("[^6VisionPolice^0 - ^6Info^0]^1 You are dead!^0")
            return
        end
        TriggerServerEvent('vision-police:sendFunk', GetEntityCoords(PlayerPedId()))
    else
        print("[^6VisionPolice^0 - ^6Info^0]^1 You're not a police officer!^0") 
    end
end, false)

RegisterKeyMapping(Config.command, 'Police-Check', 'keyboard', 'F10')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if PlayerData.job and PlayerData.job.name == 'police' then
            if #notifiedOfficers > 0 then
                SetTextComponentFormat('STRING')
                AddTextComponentString('Press '.. Config.keyaccept ..' or Press '.. Config.keyreject ..' to reject.')
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustPressed(0, Config.acceptreport) then -- 38
                    local officerCoords = notifiedOfficers[1].coords
                    SetNewWaypoint(officerCoords.x, officerCoords.y)
                    notifiedOfficers = {}
                    if Config.debug then
                        print("[^6VisionPolice^0 - ^6Info^0]^1 You have accepted it!^0")
                    end
                elseif IsControlJustPressed(0, Config.rejectreport) then -- 44
                    notifiedOfficers = {}
                    if Config.debug then
                        print("[^6VisionPolice^0 - ^6Info^0]^1 You have declined it!^0")
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('vision-police:receiveFunk')
AddEventHandler('vision-police:receiveFunk', function(coords, senderName)
    if Config.debug then
        print("[^6VisionPolice^0 - ^6Info^0]^1 You have released your position!^0")
    end
    if PlayerData.job and PlayerData.job.name == 'police' then
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)

        ESX.ShowAdvancedNotification('Police Check', 'Location', '~b~' .. senderName .. '~s~ determines its location!', 'CHAR_CALL911', 1)
        
        table.insert(notifiedOfficers, {coords = coords, senderName = senderName})
    end
end)
