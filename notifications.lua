notifications = {}
offset = 0

date_events = {{}}
newday, newevent = ""
newmonth = os.date("%m")
newyear = os.date("%Y")
newetype = ""

function load_events()
    local f = io.open(data_dir .. "/date_events.txt", "r")
    local day, month, year, event, etype
    for line in f:lines() do
        day, month, year, etype, event = string.match(line, "^\ *([%d]+)\ +([%d]+)\ +([%d]+)\ +([%w]+)\ +(.*)$")
        if tonumber(year) >= tonumber(os.date("%Y")) or ( tonumber(month) < tonumber(os.date("%m")) and tonumber(year) > tonumber(os.date("%Y"))) then
            day = string.format("%2s", day)
            month = string.format("%2s", month)
            year = string.format("%4s", year)
            if date_events[year] == nil then
                date_events[year] = {}
            end
            if date_events[year][month] == nil then
                date_events[year][month] = {}
            end
            date_events[year][month][#date_events[year][month]+1] = { day, month, year, etype, event }
            local d = os.date("*t")
            if tonumber(d.day) == tonumber(day) and tonumber(d.month) == tonumber(month) and tonumber(d.year) == tonumber(year) then
                naughty.notify({ title = string.format('<span color="white">Today event:</span>'), text = event })
            end
        elseif etype == "r" then
            local y = string.format("%4s", tonumber(year)+1)
            if date_events[y] == nil then
                date_events[y] = {}
            end
            if date_events[y][month] == nil then
                date_events[y][month] = {}
            end
            date_events[y][month][#date_events[y][month]+1] = { day, month, y, etype, event }
        end
    end
    f:close()
    save_events()
end

function save_events()
    local f = io.open(data_dir .. "/date_events.txt", "w")
    for y,y1 in pairs(date_events) do
        for m,m1 in pairs(y1) do
            for e,e1 in pairs(m1) do
                f:write(string.format("%2s %2s %4s %1s %s\n", 
                    e1[1],
                    e1[2],
                    e1[3],
                    e1[4],
                    e1[5]))
            end
        end
    end
    f:close()
end

load_events()

function add_event()
    awful.prompt.run({ 
        text = newevent, 
        selectall = true,
        prompt = '<span color="green">Add event: </span>', },
        widgets["prompt"][mouse.screen].widget,
        function (expr)
            newevent = expr
            if newevent == "" or newevent == nil then
                return
            end
            awful.prompt.run({ 
                prompt = '<span color="red">The Day: </span>',
                selectall = true,
                text = newday, },
                widgets["prompt"][mouse.screen].widget,
                function (expr)
                    newday = expr
                    if newday == "" or newday == nil then
                        return
                    end
                    if tonumber(newday) > 31 and tonumber(newday) < 1 then
                        naughty.notify({ text = "Bad day" })
                        return
                    end
                    newday = string.format("%2s", tonumber(newday))
                    awful.prompt.run({ 
                        prompt = '<span color="cyan">The month: </span>', 
                        selectall = true,
                        text = newmonth, },
                        widgets["prompt"][mouse.screen].widget,
                        function (expr)
                            newmonth = expr
                            if newmonth == "" or newmonth == nil then
                                return
                            end
                            if tonumber(newmonth) > 12 and tonumber(month) < 1 then
                                naughty.notify({ text = "Bad month" })
                                return
                            end
                            newmonth = string.format("%2s", tonumber(newmonth))
                            awful.prompt.run({ 
                                prompt = '<span color="red">The Year: </span>', 
                                selectall = true,
                                text = newyear, },
                                widgets["prompt"][mouse.screen].widget,
                                function (expr)
                                    newyear = expr
                                    if newyear == "" or newyear == nil then
                                        return
                                    end
                                    if tonumber(newyear) < tonumber(os.date("%Y")) then
                                        naughty.notify({ text = "Bad year" })
                                        return
                                    end
                                    awful.prompt.run({ 
                                        prompt = '<span color="yellow">Repeat yearly?(r/n): </span>', 
                                        selectall = true,
                                        text = newetype, },
                                        widgets["prompt"][mouse.screen].widget,
                                        function (expr)
                                            newetype = expr
                                            if newetype == "" or newetype == nil then
                                                return
                                            end
                                            if newetype ~= "r" and newetype ~= "n" then
                                                naughty.notify({ text = "Bad answer" })
                                                return
                                            end
                                            newetype = string.format("%1s", newetype)
                                            if date_events[newyear] == nil then
                                                date_events[newyear] = {}
                                            end
                                            if date_events[newyear][newmonth] == nil then
                                                date_events[newyear][newmonth] = {}
                                            end
                                            date_events[newyear][newmonth][#date_events[newyear][newmonth]+1] = { newday, newmonth, newyear, newetype, newevent }
                                            table.sort(date_events[newyear][newmonth], function(a1, a2)
                                                if a1[1] < a2[1] then
                                                    return true
                                                else
                                                    return false
                                                end
                                            end)
                                            save_events()
                                            newday = ""
                                            newmonth = os.date("%m")
                                            newyear = os.date("%Y")
                                            newetype = ""
                                            newevent = ""
                                        end,
                                        nil)
                                end,
                                nil)
                        end,
                        nil)
                end,
                nil)
        end,
        nil)
end

function delete_event()
    awful.prompt.run({ text = "", 
                     selectall = true,
                     prompt = '<span color="red">Select day(date dd/mm/yyy): </span>', },
                     widgets["prompt"][mouse.screen].widget,
                     function (expr)
                         newevent = expr
                         if newevent == "" or newevent == nil then
                             return
                         end
                         local day, month, year = string.match(newevent, "([%d]+)[/.-]+([%d]+)[/.-]+([%d][%d][%d][%d])")
                         local str
                         str = ""
                         day = string.format("%2s", tonumber(day))
                         month = string.format("%2s", tonumber(month))
                         year = string.format("%4s", tonumber(year))
                         for key,val in pairs(date_events[year][month]) do
                             if tonumber(val[1]) == tonumber(day) then
                                 str = string.format('%s<span color="red">%s</span> - <span color="white">%s</span>\n', str, key, val[5])
                             end
                         end
                         if str ~= nil and str ~= "" then
                             naughty.notify({ title = "Choose(from notification):", text = str, timeout = 10 })
                             awful.prompt.run({ text = "", 
                                             selectall = true,
                                             prompt = '<span color="green">Select event: </span>', },
                                             widgets["prompt"][mouse.screen].widget,
                                             function (expr)
                                                 if expr == "" or expr == nil then
                                                     return
                                                 end
                                                 local day, month, year = string.match(newevent, "([%d]+)[/.-]+([%d]+)[/.-]+([%d][%d][%d][%d])")
                                                 day = string.format("%2s", tonumber(day))
                                                 month = string.format("%2s", tonumber(month))
                                                 year = string.format("%4s", tonumber(year))
                                                 expr = tonumber(expr)
                                                 if date_events[year][month][expr] ~= nil then
                                                     table.remove(date_events[year][month], expr)
                                                     save_events()
                                                 end
                                             end,
                                             nil)
                         else
                             naughty.notify({ text = '<span color="green">Nothing to remove on that day</span>' })
                         end
                     end,
                     nil)
end

function remove_notification(n)
    if notifications[n] ~= nil then
        naughty.destroy(notifications[n])
        notifications[n] = nil
        offset = 0
    end
end

function add_notification(n, args)
    notifications[n] = naughty.notify( args )
end

function add_calendar(inc_offset, tout)
    local save_offset = offset
    remove_notification("calendar")
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    local month = string.format("%2s", datespec%12 + 1)
    local year = string.format("%4s", math.floor(datespec / 12))
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local day = string.format("%2s", tonumber(os.date("%d")))
    local cal = awful.util.pread("cal -m " .. datespec .. "| sed 's/\\([ [:alnum:]]\\+ [ [:alnum:]]\\+ [ [:alnum:]]\\+ [ [:alnum:]]\\+ [ [:alnum:]]\\+ [ [:alnum:]]\\+ \\)\\([ [:alnum:]]\\{2\\}\\)/<span color=\"white\">\\1<\\/span><span color=\"red\">\\2<\\/span>/'|sed 's/\\([^0-9]\\+\\)\\(".. day .. "\\)\\([ <]\\{1\\}\\)/\\1<span color=\"cyan\">\\2<\\/span>\\3/g'")
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    local events, today, prev, tomorrow, future
    today = ""
    tomorrow = ""
    prev = ""
    future = ""
    if date_events[year] ~= nil then
        if date_events[year][month] ~= nil then
            for e = 1, #date_events[year][month] do
                if tonumber(date_events[year][month][e][1]) == tonumber(os.date("%d")) then
                    today = today .. string.format('\n<span color="green">%s</span> - <span color="white">%s</span> (<span color="cyan">%s</span>)', date_events[year][month][e][1], date_events[year][month][e][5], date_events[year][month][e][4])
                elseif tonumber(date_events[year][month][e][1]) > tonumber(os.date("%d"))+1 then
                    future = future .. string.format('\n<span color="green">%s</span> - <span color="white">%s</span> (<span color="cyan">%s</span>)', date_events[year][month][e][1], date_events[year][month][e][5], date_events[year][month][e][4])
                elseif tonumber(date_events[year][month][e][1]) == tonumber(os.date("%d"))+1 then
                    tomorrow = tomorrow .. string.format('\n<span color="green">%s</span> - <span color="white">%s</span> (<span color="cyan">%s</span>)', date_events[year][month][e][1], date_events[year][month][e][5], date_events[year][month][e][4])
                elseif tonumber(date_events[year][month][e][1]) < tonumber(os.date("%d")) then
                    prev = prev .. string.format('\n<span color="green">%s</span> - <span color="white">%s</span> (<span color="cyan">%s</span>)', date_events[year][month][e][1], date_events[year][month][e][5], date_events[year][month][e][4])
                end
            end
        end
    end
    if #today > 0 then
        today = "\n\nToday events:" .. today
    end
    if #tomorrow > 0 then
        tomorrow = "\n\nTomorrow events:" .. tomorrow
    end
    if #prev > 0 then
        prev = "\n\nThis month past events:" .. prev
    end
    if #future > 0 then
        future = "\n\nThis month upcomming events:" .. future
    end
    events = string.format("%s%s%s%s", prev, today, tomorrow, future)
    if tonumber(month) == 12 then
        year = string.format("%4s", tonumber(year)+1)
        month = string.format("%2s", 1)
    else
        month = string.format("%2s", tonumber(month)+1)
    end
    local nextm = ""
    if date_events[year] ~= nil then
        if date_events[year][month] ~= nil then
            for e = 1, #date_events[year][month] do
                nextm = nextm .. string.format('\n<span color="green">%s</span> - <span color="white">%s</span> (<span color="cyan">%s</span>)', date_events[year][month][e][1], date_events[year][month][e][5], date_events[year][month][e][4])
            end
        end
    end
    if #nextm > 0 then
        events = events .. "\n\nNext month events:" .. nextm
    end
    add_notification("calendar", 
        {text = string.format('<span font_desc="%s">Today is:\n%s</span>', "monospace", os.date("%a, %d %B %Y") .. "\n\n" .. cal .. events),
        timeout = tout, hover_timeout = 0.5,
    })
end

function netcard_show(tout)
    local mac, ip, mask, broadcast
    remove_notification("netcard_stats")
    local f = io.popen("/sbin/ifconfig|sed -n '/^"..net_active_dev.."/,/^[[:blank:]]*inet/p'", "r")
    local i = 1
    for line in f:lines() do
        if i == 1 then
            mac = string.match(line, "([%w%d]+:[%w%d]+:[%w%d]+:[%w%d]+:[%w%d]+:[%w%d]+)")
            i = i+1
        else
            ip, broadcast, mask = string.match(line, "inet addr:([%d]+.[%d]+.[%d]+.[%d]+)\ +Bcast:([%d]+.[%d]+.[%d]+.[%d]+)\ +Mask:([%d]+.[%d]+.[%d]+.[%d+])")
        end
    end
    f:close()
    local lq, essid, str, ap, br
    str = ""
    if net_active_dev == "wlan0" then
        f = io.popen("/sbin/iwconfig wlan0|sed -n 's/.*ESSID:\"\\([^\"]\\+\\)\"/\\1/p;s/.*Access Point: \\(.*\\)/\\1/p;s/.*Bit Rate=\\([0-9]\\+ Mb\\/s\\).*/\\1/p;s/.*Link Quality=\\([0-9]\\+\\/[0-9]\\+\\).*/\\1/p'", "r")
        local j = 1
        for line in f:lines() do
            if j == 1 then
                essid = line
            elseif j == 2 then
                ap = line
            elseif j == 3 then
                br = line
            else
                lq = line
            end
            j = j + 1
        end

        str = string.format('\n<span font="monospace">%15s: <span color="green">%s</span>\n%15s: <span color="yellow">%s</span>\n%15s: <span color="red">%s</span>\n%15s: <span color="white">%s</span></span>', "ESSID",essid, "Quality", lq, "Bit Rate", br, "Access Point", ap)
    end
    add_notification("netcard_stats", { text = string.format(
        '<span font="monospace">%15s: <span color="gray">%s</span>\n%15s: <span color="green">%s</span>\n%15s: <span color="yellow">%s</span>\n%15s: <span color="cyan">%s</span></span>' .. str,
         "MAC", mac, "IP", ip, "Mask", mask, "Broadcast", broadcast), timeout = tout} )

end

function disks_show(tout)
    local f = io.popen("df -h", "r")
    local ds
    ds = ""
    local i = 1
    remove_notification("disks_stats")
    for line in f:lines() do
        if i%2 == 0 then
            ds = ds .. '<span color="white">' .. line .. '</span>\n'
        else
            ds = ds .. '<span color="green">' .. line .. '</span>\n'
        end
        i = i + 1
    end
    f:close()
    add_notification("disks_stats", { text = "<span font=\"monospace\">"..ds.."</span>", timeout = tout })
end

