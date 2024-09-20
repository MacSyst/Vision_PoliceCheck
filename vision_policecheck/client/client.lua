local PlayerData = {}
local notifiedOfficers = {}
local Time = 5000

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(Vision.delay)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterCommand(Vision.command, function()
    if PlayerData.job and PlayerData.job.name == Vision.jobname then
        if IsPlayerDead(PlayerId()) then
            print("[^6VisionPolice^0 - ^6Info^0]^1 You are dead!^0")
            return
        end
        TriggerServerEvent('vision-police:sendFunk', GetEntityCoords(PlayerPedId()))
    else
        print("[^6VisionPolice^0 - ^6Info^0]^1 You're not a police officer!^0") 

        if Vision.OkokNotify then
            exports['okokNotify']:Alert("Error", "You're not a police officer!", Time, 'error')
        end

    end
end, false)

RegisterKeyMapping(Vision.command, 'Police-Check', 'keyboard', 'F10')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if PlayerData.job and PlayerData.job.name == Vision.jobname then
            if #notifiedOfficers > 0 then
                SetTextComponentFormat('STRING')
                AddTextComponentString('Press '.. Vision.keyaccept ..' to accept or Press '.. Vision.keyreject ..' to reject.')
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustPressed(0, Vision.acceptreport) then -- 38
                    local officerCoords = notifiedOfficers[1].coords
                    SetNewWaypoint(officerCoords.x, officerCoords.y)
                    notifiedOfficers = {}
                    if Vision.debug then
                        print("[^6VisionPolice^0 - ^6Info^0]^1 You have accepted it!^0")
                    end

                    if Vision.OkokNotify then
                        exports['okokNotify']:Alert("Success", "You have accepted it!", Time, 'success')
                    end

                    if Vision.OkokNotify == false then
                        BeginTextCommandThefeedPost("STRING")
                        AddTextComponentSubstringPlayerName("You have ~g~accepted~s~ it!")
                        EndTextCommandThefeedPostTicker(true, true)
                    end

                elseif IsControlJustPressed(0, Vision.rejectreport) then -- 44
                    notifiedOfficers = {}
                    if Vision.debug then
                        print("[^6VisionPolice^0 - ^6Info^0]^1 You have declined it!^0")
                    end

                    if Vision.OkokNotify then
                        exports['okokNotify']:Alert("Error", "You have declined it!", Time, 'error')
                    end

                    if Vision.OkokNotify == false then
                        BeginTextCommandThefeedPost("STRING")
                        AddTextComponentSubstringPlayerName("You have ~r~declined~s~ it!")
                        EndTextCommandThefeedPostTicker(true, true)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('vision-police:receiveFunk')
AddEventHandler('vision-police:receiveFunk', function(coords, senderName)
    if Vision.debug then
        print("[^6VisionPolice^0 - ^6Info^0]^1 You have released your position!^0")
    end
    if PlayerData.job and PlayerData.job.name == 'police' then
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)

        if Vision.OkokNotify == false then
            ESX.ShowAdvancedNotification('Police Check', 'Location', '~b~' .. senderName .. '~s~ determines its location!', 'CHAR_CALL911', 1)
        end

        if Vision.OkokNotify then
            exports['okokNotify']:Alert("Success", "" .. senderName .. " determines its location!", 10000, 'warning')
        end
        
        table.insert(notifiedOfficers, {coords = coords, senderName = senderName})
    end
end)
