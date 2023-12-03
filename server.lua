if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qbcore" then
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

RegisterNetEvent('wn_adventcalendar:giveitems')
AddEventHandler('wn_adventcalendar:giveitems', function(prizeName, targetDate)
    local src = source
    -- Get player identifiers
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        identifiers = xPlayer.identifier
    elseif Config.Framework == "qbcore" then
        xPlayer = QBCore.Functions.GetPlayer(src)
        identifiers = xPlayer.PlayerData.citizenid
    end
    local currentDate = os.date("*t")
    local isMatchingDate = currentDate.year == targetDate.year and currentDate.month >= targetDate.month and currentDate.day >= targetDate.day
    if not isMatchingDate then
        return 
        lib.notify(src, { 
            title = 'Advent Calendar', 
            description = "This isn't the correct day to open.", 
            icon = "fa-solid fa-calendar-day", 
            type = 'inform', 
            duration = 7500 
        })
    end
    local hasReceivedPrize = MySQL.Sync.fetchScalar(
        "SELECT COUNT(*) FROM player_prizes WHERE player_identifier = @playerIdentifier AND prize_name = @prizeName", {
            ['@playerIdentifier'] = identifiers,
            ['@prizeName'] = prizeName
        }
    )
    if hasReceivedPrize == 0 then
        local dateData = Config.Days[prizeName]
        lib.callback.await('wn_calendar:serverprogress', src, text)
        if dateData.cash then
            if dateData.cash.money then
                AddMoney('money', dateData.cash.money, src)
                lib.notify(src, {
                    title = 'Advent Calendar',
                    description = "You successfully received money with an amount of: " .. dateData.cash.money .. "",
                    type = 'success'
                })
            end
            if dateData.cash.bank then
                AddMoney('bank', dateData.cash.bank, src)
                lib.notify(src, {
                    title = 'Calendar',
                    description = "$" .. dateData.cash.bank .. " was deposited in your bank account",
                    icon = "fa-solid fa-calendar-day",
                    duration = 7500,
                    type = 'success'
                })
            end
        end
        if dateData and type(dateData.items) == "table" then
            for _, item in ipairs(dateData.items) do
                local itemstogive = item.name
                AddItem(itemstogive, item.quantity, src)
            end
        else
            print("No items to give or invalid item data for prizeName: " .. prizeName)
        end
        MySQL.Async.execute(
            "INSERT INTO player_prizes (player_identifier, prize_name) VALUES (@playerIdentifier, @prizeName)", {
                ['@playerIdentifier'] = identifiers,
                ['@prizeName'] = prizeName
            }
        )
    else
        lib.notify(src, { 
            title = 'Advent Calendar', 
            description = 'You have already opened the Advent Calendar for this day', 
            icon = "fa-solid fa-calendar-day", 
            type = 'error', 
            duration = 7500 
        })
    end
end)

lib.callback.register('wn_adventcalendar:getDate', function()
    local currentDate = os.date("*t")  -- Get the current date and time
    return ({day = currentDate.day, month = currentDate.month, year = currentDate.year})
end)
