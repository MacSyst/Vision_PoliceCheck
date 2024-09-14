RegisterServerEvent('vision-police:sendFunk')
AddEventHandler('vision-police:sendFunk', function(coords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.job.name == Config.jobname then
        TriggerClientEvent('vision-police:receiveFunk', -1, coords, xPlayer.getName())
    end
end)
