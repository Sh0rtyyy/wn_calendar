local Options = {}

-- Extract dates and sort them as strings
local sortedDates = {}
for date, _ in pairs(Config.Days) do
    table.insert(sortedDates, date)
end
table.sort(sortedDates)

-- Iterate over the sorted dates
for _, date in ipairs(sortedDates) do
    local dateData = Config.Days[date]

    if dateData then

        Options[date] = {
            title = dateData.title,
            --description = dateData.description,
            icon = "fa-solid fa-snowflake",
            image = "https://cdn.discordapp.com/attachments/1176269936008642621/1178802966229159946/christmas-gift.png?ex=657778d0&is=656503d0&hm=2b8bfea49aeca9162aff9fcfaa3af7097af94b05097bd581b0d98bd4981d2fd4&",
            onSelect = function()
                TriggerServerEvent("wn_calendar:giveitems", date)
            end,
        }
    else
        print("Invalid config !")
    end
end

RegisterNetEvent('wn_calendar:open', function()
    lib.registerContext({
        id = 'calendar_menu',
        title = "Calendar",
        options = Options,
    })
    lib.showContext('calendar_menu')
end)

RegisterCommand("calendar", function(source, args, rawCommand)
    TriggerEvent("wn_calendar:open")
end, false)
