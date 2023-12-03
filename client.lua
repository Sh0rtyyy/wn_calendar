local Options = {}
local sortedDates = {}
for date, _ in pairs(Config.Days) do
    table.insert(sortedDates, date)
end
table.sort(sortedDates)

local Options = {}
lib.callback('wn_adventcalendar:getDate', false, function(data)
    for i=1, #sortedDates do
        local dateData = Config.Days[sortedDates[i]]
        if dateData then
            if (data.year == dateData.date.year and data.month == dateData.date.month and data.day >= dateData.date.day) then
                Options[i] = {
                    title = dateData.title,
                    arrow = true,
                    icon = "https://cdn.discordapp.com/attachments/1176269936008642621/1178802966229159946/christmas-gift.png?ex=657778d0&is=656503d0&hm=2b8bfea49aeca9162aff9fcfaa3af7097af94b05097bd581b0d98bd4981d2fd4&",
                    image = "https://cdn.discordapp.com/attachments/1176269936008642621/1178802966229159946/christmas-gift.png?ex=657778d0&is=656503d0&hm=2b8bfea49aeca9162aff9fcfaa3af7097af94b05097bd581b0d98bd4981d2fd4&",
                    onSelect = function()
                        TriggerServerEvent("wn_adventcalendar:giveitems", sortedDates[i], dateData.date)
                    end,
                }
            end
        else
            print("Invalid config !")
        end
    end
end)

lib.callback.register('wn_calendar:serverprogress', function()

    return lib.progressBar({
        duration = 3500,
        label = 'Opening . . .',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = "mp_arresting",
            clip = "a_uncuff",
            flags = 49,
        },
        prop = {
            model = `v_ret_ps_box_02`,
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.0, 0.0, -1.5) 
        },
    })
end)

local function calendarOpen()
    lib.registerContext({
        id = 'calendar_menu',
        title = "Calendar",
        options = Options,
    })
    lib.showContext('calendar_menu')
end

RegisterCommand('calendar', calendarOpen)
RegisterNetEvent('wn_calendar:open', calendarOpen)
