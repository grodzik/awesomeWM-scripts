require("notifications")

cpus_old = {}
widgets = {}
timers = {}
nets_old = {}

net_active_dev = "eth0"
net_width = 40

perc_width = 31
cpufreq_width = 48
psign = "%"

widgets["textclock"] = awful.widget.textclock({ align = "right" }, "%H:%M" )
widgets["textclock"].layout = awful.widget.layout.horizontal.rightleft

widgets["clockimage"] = widget({ type = "imagebox" })
widgets["clockimage"].image = image(data_dir .. "/grodzik/images/time.png")

widgets["calendarimage"] = widget({ type = "imagebox" })
widgets["calendarimage"].image = image(data_dir .. "/grodzik/images/cal.png")

widgets["calendarimage"]:add_signal("mouse::enter", function()
    add_calendar(0, 0)
end)
widgets["calendarimage"]:add_signal("mouse::leave", function()
    remove_notification("calendar")
end)

widgets["calendarimage"]:buttons(
    awful.util.table.join(
        awful.button({ }, 1, function()
            add_calendar(-1, 0)
        end),
        awful.button({ }, 3, function()
            add_calendar( 1, 0)
        end)
    ) 
)

function cpu_update(acpu)
    local file = assert(io.open("/proc/stat","r"))
    for line in file:lines() do
        local newstats = string.match(line, acpu .. "\ +(%d+)")
        if newstats then
            if not cpus_old[acpu] then
                cpus_old[acpu] = newstats
            end
            local v = (newstats-cpus_old[acpu])
            cpus_old[acpu] = newstats
            file:close()
            return v
        end
    end
    file:close()
end

function cpufreq_update(cpunum)
    local file = io.popen("sed -n -e '/processor[[:blank:]:]\\+" .. cpunum .. "/,/processor[[:blank:]:]\\+[^" .. cpunum .. "]\\+/p' /proc/cpuinfo|sed -n 's/cpu MHz[[:blank:]:]\\+\\([0-9\.]\\+\\)/\\1/p'", "r")
    local state = tonumber(file:read("*a"))
    file:close()
    return state
end

function mem_update(what)
    local memtotal, memfree, buff, cached, swapfree, swaptotal
    local str, val
    local file = assert(io.open("/proc/meminfo", "r"))
    for line in file:lines() do
        str, val = string.match(line, "([%w_]+):\ +(%d+)")
        if  str == "MemTotal" then
            memtotal = val
        elseif str == "MemFree" then
            memfree = val
        elseif str == "Buffers" then
            buff = val
        elseif str == "Cached" then
            cached = val
        elseif str == "SwapFree" then
            swapfree = val
        elseif str == "SwapTotal" then
            swaptotal = val
        end
    end
    file:close()
    if what == "ram" then
        local mem = ( memtotal - ( memfree + buff + cached ) ) * 100 / memtotal
        return math.floor(mem + 0.5)
    else
        if tonumber(swaptotal) > 0 then
            local swap = ( swaptotal - swapfree ) * 100 / swaptotal
            return math.floor(swap + 0.5)
        else
            return 0
        end
    end
end

function bat_update()
    local cfull, cnow
    local file = io.open("/sys/class/power_supply/BAT0/energy_now")
    cnow = tonumber(file:read("*a"))
    file:close()
    file = io.open("/sys/class/power_supply/BAT0/energy_full_design")
    cfull = tonumber(file:read("*a"))
    file:close()
    return math.floor( (cnow / cfull) * 100 + 0.5)
end

function temp_update(zone)
    local temp
    local file = io.open("/sys/devices/virtual/thermal/thermal_zone" .. zone .. "/temp")
    temp = math.floor(tonumber(file:read("*a"))/1000)
    file:close()
    return tostring(temp)
end

function hdaps_update()
    local state
    local file = io.open("/sys/block/sda/device/unload_heads")
    state = tonumber(file:read("*a"))
    file:close()
    return state
end

function disk_update()
    local mount, used
    local str = " "
    local file = io.popen("df -h", "r")
    for line in file:lines() do
        used, mount = string.match(line, "/dev/%w+\ +[%w,]+\ +[%w,]+\ +([%w,]+)\ +%w+.?\ +[/%w]*(/%w*)$")
        if mount == '/' or mount == '/home' or mount == '/other' then
            str = str .. mount .. ":" .. tostring(used) .. " "
        end
    end
    file:close()
    return str
end

function net_update()
    local f = io.open("/proc/net/dev")
    local str = {}
    local recv = -1
    local send = -1

    for line in f:lines() do
        if string.match(line, "^[%s]?[%s]?[%s]?[%s]?" .. net_active_dev .. ":") then
            recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
            send = tonumber(string.match(line,
             "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

            if nets_old[net_active_dev] == nil then 
                nets_old[net_active_dev] = {}
                nets_old[net_active_dev].time = os.time()
            else
                local interval = os.time() - nets_old[net_active_dev].time
                nets_old[net_active_dev].time = os.time()
                local down = (recv - nets_old[net_active_dev][1])/interval
                local up   = (send - nets_old[net_active_dev][2])/interval
                str["up"] = string.format(" %.1f ", up/1024)
                str["down"] = string.format("%.1f ", down/1024)
            end
            nets_old[net_active_dev][1] = recv
            nets_old[net_active_dev][2] = send
        end
    end
    if recv == -1 then
        timers["net_misc"]:emit_signal("timeout")
    end
    f:close()

    return str
end

function active_net_dev_update()
    local f = io.open("/proc/net/route")
    local net_dev = "lo"

    for line in f:lines() do
        local d = string.match(line, "^([%w]+)[%s]+[%w]+[%s]+[%w]+[%s]+0003")
        if d == "wlan0" or d == "eth0" then
            net_dev = d
        end
    end
    f:close()

    return net_dev
end

widgets["cpu_text"] = widget({ type = "textbox" })
widgets["cpu_text"].width = perc_width
widgets["cpu_text"].align = "right"
widgets["cpu_text"].text = tostring( math.floor(cpu_update("cpu")/2 + 0.5)) .. psign

timers["cpu"] = timer({ timeout = 1 })
timers["cpu"]:add_signal("timeout", 
    function () 
        local v = cpu_update("cpu")
        widgets["cpu_text"].text = tostring( math.floor(v/2 + 0.5) ) .. psign
    end)
timers["cpu"]:start()

widgets["ram_text"] = widget({ type = "textbox" })
widgets["ram_text"].width = perc_width
widgets["ram_text"].align = "right"
widgets["ram_text"].text = mem_update("ram") .. psign

widgets["swap_text"] = widget({ type = "textbox" })
widgets["swap_text"].width = perc_width
widgets["swap_text"].align = "right"
widgets["swap_text"].text = mem_update("swap") .. psign

timers["mem"] = timer({ timeout = 15 })
timers["mem"]:add_signal("timeout", function () 
        widgets["ram_text"].text = mem_update("ram") .. psign
        widgets["swap_text"].text = mem_update("swap") .. psign
    end)
timers["mem"]:start()

widgets["bat_text"] = widget({ type="textbox", align="right" })
widgets["bat_text"].text = string.format('%s%s', bat_update(), psign)
widgets["bat_text"].align = "right"
widgets["bat_text"].width = perc_width

widgets["batimage"] = widget({ type = "imagebox" })
widgets["batimage"].image = image(data_dir .. "/grodzik/images/bat.png")

-- 1 full, 2 low, 3 critical
timers["bat"] = timer({ timeout = 30 })
timers["bat"]:add_signal("timeout", function () 
    local v = bat_update() 
    widgets["bat_text"].text = string.format('%s%s', v, psign)
end)
timers["bat"]:start()

widgets["temp"] = widget({ type = "textbox", align = "right" })
widgets["temp"].text = temp_update("0") .. "C " .. temp_update("1") .. "C "

timers["temp"] = timer({ timeout = 15 })
timers["temp"]:add_signal("timeout", function ()
    widgets["temp"].text = temp_update("0") .. "C " .. temp_update("1") .. "C "
end)
timers["temp"]:start()

widgets["tempimage"] = widget({ type = "imagebox" })
widgets["tempimage"].image = image(data_dir .. "/grodzik/images/temp.png")

widgets["hdapsimage"] = widget({ type = "imagebox" })
widgets["hdapsimage"].image = image(data_dir .. "/grodzik/images/hdaps-off.png")

timers["hdaps"] = timer({ timeout = 1 })
hdaps = 1
timers["hdaps"]:add_signal("timeout", function ()
        local s = hdaps_update()
        if s ~= 0 and hdaps == 1 then
            widgets["hdapsimage"].image = image(data_dir .. "/grodzik/images/hdaps-on.png")
            hdaps = 2
        elseif s == 0 and hdaps == 2 then
            widgets["hdapsimage"].image = image(data_dir .. "/grodzik/images/hdaps-off.png")
            hdaps = 1
        end
    end)
timers["hdaps"]:start()

widgets["disks"] = widget({ type = "textbox" })
widgets["disks"].align = "right"
widgets["disks"].text = disk_update()

widgets["disks"]:add_signal("mouse::enter", function()
    disks_show(0)
end)
widgets["disks"]:add_signal("mouse::leave", function()
    remove_notification("disks_stats")
end)

timers["disks"] = timer({ timeout = 20 })
timers["disks"]:add_signal("timeout", function ()
    widgets["disks"].text = disk_update()
end)
timers["disks"]:start()

widgets["netimage"] = widget({ type = "imagebox" })

net_active_dev = active_net_dev_update()

if net_active_dev == "eth0" then
    widgets["netimage"].image = image(data_dir .. "/grodzik/images/wire.png")
else
    widgets["netimage"].image = image(data_dir .. "/grodzik/images/wifi.png")
end
widgets["net_dev"] = widget({ type = "textbox"})
widgets["net_dev"].align = "right"
widgets["net_dev"].text = net_active_dev .. " "
widgets["net_stat_up"] = widget({ type = "textbox"})
widgets["net_stat_up"].align = "right"
widgets["net_stat_up"].text = "0 kB "
widgets["net_stat_up"].width = net_width
widgets["net_stat_down"] = widget({ type = "textbox"})
widgets["net_stat_down"].align = "right"
widgets["net_stat_down"].text = "0 kB "
widgets["net_stat_down"].width = net_width

widgets["netimage"]:add_signal("mouse::enter", function()
    netcard_show(0)
end)
widgets["netimage"]:add_signal("mouse::leave", function()
    remove_notification("netcard_stats")
end)

timers["net_stats"] = timer({ timeout = 1 })
timers["net_stats"]:add_signal("timeout", function ()
    local arr = net_update()
    widgets["net_stat_up"].text = arr["up"]
    widgets["net_stat_down"].text = arr["down"]
end)
timers["net_stats"]:start()

timers["net_misc"] = timer({ timeout = 30 })
timers["net_misc"]:add_signal("timeout", function ()
    local nad = active_net_dev_update()
    if nad ~= net_active_dev then
        net_active_dev = nad
        if net_active_dev == "eth0" then
            widgets["netimage"].image = image(data_dir .. "/images/network-wire.png")
        else
            widgets["netimage"].image = image(data_dir .. "/grodzik/images/wifi.png")
        end
    end
end)
timers["net_misc"]:start()

widgets["uploadimage"] = widget({ type = "imagebox" })
widgets["uploadimage"].image = image(data_dir .. "/grodzik/images/up.png")

widgets["downloadimage"] = widget({ type = "imagebox" })
widgets["downloadimage"].image = image(data_dir .. "/grodzik/images/down.png")

widgets["separator"] = widget({ type="imagebox" })
widgets["separator"].image = image(data_dir .. "/grodzik/images/separator.png")

widgets["procimage"] = widget({ type = "imagebox" })
widgets["procimage"].image = image(data_dir .. "/grodzik/images/cpu.png")

widgets["ramimage"] = widget({ type = "imagebox" })
widgets["ramimage"].image = image(data_dir .. "/grodzik/images/mem.png")

widgets["swapimage"] = widget({ type = "imagebox" })
widgets["swapimage"].image = image(data_dir .. "/grodzik/images/disk.png")

-- Create a systray
widgets["systray"] = widget({ type = "systray" })
widgets["systray"].layout = awful.widget.layout.horizontal.rightleft

-- Create a wibox for each screen and add it
mywibox = {}
widgets["prompt"] = {}
widgets["layoutbox"] = {}
widgets["taglist"] = {}
widgets["taglist"].buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
widgets["tasklist"] = {}

widgets["curtag"] = widget({ type = "textbox" })
widgets["curtag"].layout = awful.widget.layout.horizontal.leftright
widgets["curtag"].align = "left"
widgets["curtag"].text = " " .. awful.tag.selected().name .. ":" .. #awful.tag.selected():clients() .. " "

