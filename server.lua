if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports['qb-core']:GetCoreObject()
end

function AddItem(name, count, source)
    local src = source 

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(name, count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.AddItem(name, count, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[name], "add", count)
    end
end

function AddMoney(type, count, source)
    local src = source 

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney(type, count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.AddMoney(type, count)
    end
end

RegisterNetEvent('wn_calendar:giveitems')
AddEventHandler('wn_calendar:giveitems', function(prizeName)
    local src = source

    -- Get player identifiers
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        identifiers = xPlayer.identifier
    elseif Config.Framework == "qbcore" then
        xPlayer = QBCore.Functions.GetPlayer(src)
        identifiers = xPlayer.PlayerData.citizenid
    end

    -- Check if the player has already received a prize on the specified date/prizeName
    local hasReceivedPrize = MySQL.Sync.fetchScalar(
        "SELECT COUNT(*) FROM player_prizes WHERE player_identifier = @playerIdentifier AND prize_name = @prizeName",
        {['@playerIdentifier'] = identifiers, ['@prizeName'] = prizeName}
    )

    if hasReceivedPrize == 0 then
        -- Retrieve prize data from the configuration based on the prizeName
        local dateData = Config.Days[prizeName]

        if dateData.cash then
            if dateData.cash.money then
                AddMoney('money', dateData.cash.money, src)
                lib.notify(src, {
                    title = 'Calendar',
                    description = "You successfully received money with an amount of: " .. dateData.cash.money .. "",
                    type = 'success'
                })
            end
        
            if dateData.cash.bank then
                AddMoney('bank', dateData.cash.bank, src)
                lib.notify(src, {
                    title = 'Calendar',
                    description = "You successfully received bank value with an amount of: " .. dateData.cash.bank .. "",
                    type = 'success'
                })
            end
        end        

        if dateData and type(dateData.items) == "table" then
            for _, item in ipairs(dateData.items) do 
                local itemstogive = item.name
                local quantity = item.quantity
        
                lib.notify(src, {
                    title = 'Calendar',
                    description = "You successfully received: " .. itemstogive .. " quantity: " .. quantity .. "",
                    type = 'success'
                })
        
                for i = 1, quantity do
                    -- Add item to the player's inventory
                    AddItem(itemstogive, 1, src)
                end
            end
        else
            print("No items to give or invalid item data for prizeName: " .. prizeName)
        end
        
        -- Record that the player has received a prize on the specified date/prizeName
        MySQL.Async.execute(
            "INSERT INTO player_prizes (player_identifier, prize_name) VALUES (@playerIdentifier, @prizeName)",
            {['@playerIdentifier'] = identifiers, ['@prizeName'] = prizeName}
        )        
    else
        lib.notify(src, {
            title = 'Calendar',
            description = 'You allready had collected prises for this date !',
            type = 'error'
        })
    end
end)
