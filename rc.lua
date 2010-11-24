-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

naughty.config.presets.low.border_color = "#FFFFFF"
naughty.config.presets.normal.border_color = "#FFFFFF"
naughty.config.presets.critical.border_color = "#FFFFFF"

naughty.config.presets.low.max_width = 500
naughty.config.presets.normal.max_width = 500
naughty.config.presets.critical.max_width = 500

naughty.config.presets.low.min_width = 250
naughty.config.presets.normal.min_width = 250
naughty.config.presets.critical.min_width = 250

data_dir = os.getenv("HOME") .. "/.local/share/awesome/"

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(data_dir .. "/grodzik/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
terminal_title_param = " -T "
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

function escape(text)
    local xml_entities = {
        ["\""] = "&quot;",
        ["&"]  = "&amp;",
        ["'"]  = "&apos;",
        ["<"]  = "&lt;",
        [">"]  = "&gt;"
    }

    return text and text:gsub("[\"&'<>]", xml_entities)
end

function focus_or_create(str, cmd)
    local clients = client.get()
    for i, c in pairs(clients) do
--        naughty.notify({ text = c.name })
        if string.find(c.class .. " " .. c.name .. " " .. c.instance, str) then
            local ctags = c:tags()
            if table.getn(ctags) == 0 then
                awful.client.movetotag(awful.tag.selected(), c)
            else
                awful.tag.viewonly(ctags[1])
            end
            client.focus = c
            c:raise()
            return
        end
    end
    awful.util.spawn(cmd)
end

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "terms", "web", "im", "mail", "media", "terms2", "vm", "d8", "d9" }, s, layouts[3])
end
awful.tag.setproperty(tags[1][1], "mwfact", 0.7)
awful.tag.setproperty(tags[1][1], "nmaster", 2)
awful.tag.setproperty(tags[1][2], "mwfact", 0.9)
awful.tag.setproperty(tags[1][2], "layout", layouts[5])
awful.tag.setproperty(tags[1][3], "layout", layouts[5])
awful.tag.setproperty(tags[1][4], "layout", layouts[5])
awful.tag.setproperty(tags[1][5], "mwfact", 0.7)
awful.tag.setproperty(tags[1][5], "layout", layouts[1])
awful.tag.setproperty(tags[1][5], "ncol", 2)
awful.tag.setproperty(tags[1][7], "layout", layouts[8])
awful.tag.setproperty(tags[1][8], "layout", layouts[8])
awful.tag.setproperty(tags[1][9], "layout", layouts[5])

-- }}}

require("usermenu")

---}}}

-- {{{ Wibox
require("userwidgets")

require("userkeys")
root.keys(globalkeys)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    widgets["prompt"][s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    widgets["layoutbox"][s] = awful.widget.layoutbox(s)
    widgets["layoutbox"][s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    widgets["layoutbox"][s].layout = awful.widget.layout.horizontal.rightleft
    -- Create a taglist widget
    widgets["taglist"][s] = awful.widget.taglist(s, awful.widget.taglist.label.all, widgets["taglist"].buttons)

    -- Create a tasklist widget
    widgets["tasklist"][s] = awful.widget.tasklist(function(c) return
        awful.widget.tasklist.label.focused(c, s) end, widgets["tasklist"].buttons)
    widgets["tasklist"][s].layout = awful.widget.layout.horizontal.flex

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 20 })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { 
        { 
            widgets["layoutbox"][s], 
            widgets["mail"],
            widgets["mailtext"],
            widgets["systray"],
            widgets["curtag"],
            widgets["prompt"][s], 
            layout = awful.widget.layout.horizontal.leftright 
        }, 
        { 
            widgets["calendarimage"], 
            widgets["clockimage"], 
            widgets["textclock"], 
            widgets["separator"], 
            widgets["hdapsimage"],
            widgets["separator"], 
            widgets["batimage"],
            widgets["bat_text"], 
            widgets["separator"], 
            widgets["tempimage"],
            widgets["temp"],
            widgets["separator"], 
            widgets["swapimage"], 
            widgets["swap_text"], 
            widgets["ramimage"], 
            widgets["ram_text"], 
            widgets["separator"], 
            widgets["procimage"], 
            widgets["cpu_text"], 
            widgets["separator"], 
            widgets["disks"],
            widgets["separator"], 
            widgets["downloadimage"],
            widgets["net_stat_down"],
            widgets["uploadimage"],
            widgets["net_stat_up"],
            widgets["netimage"],
            layout = awful.widget.layout.horizontal.rightleft 
        }, 
        widgets["tasklist"][s], 
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
second_wibox = awful.wibox({ position = "bottom", screen = 1, height = 20 })
second_wibox.widgets = {
    widgets["mpd"]["song"],
    widgets["mpd"]["album"],
    widgets["mpd"]["timing"],
    widgets["mpd"]["percent"],
    layout = awful.widget.layout.horizontal.leftright
}

clientkeys = awful.util.table.join( 
                awful.key({ modkey, "Shift" }, "f", 
                    function (c) c.fullscreen = not c.fullscreen  end), 
                awful.key({ modkey, }, "q", 
                    function (c) c:kill() end),
                awful.key({ modkey, "Control" }, "space",
                        awful.client.floating.toggle ), 
                awful.key({ modkey, "Shift" }, "r", 
                    function (c) c:redraw() end), 
                awful.key({ modkey, "Shift" }, "m",
                    function (c) c.maximazed_horizontal = not c.maximized_horizontal end),
                awful.key({ modkey, "Shift" }, "n",
                    function (c) 
                        c.maximized_horizontal = not c.maximized_horizontal 
                        c.maximized_vertical = not c.maximized_vertical end), 
                awful.key({ modkey, "Shift" }, "b",
                    function (c) c.maximazed_vertical = not c.maximized_horizontal end),
                awful.key({ modkey, "Control" }, "Return", 
                    function (c) c:swap(awful.client.getmaster()) end)
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { }, properties = { border_width = beautiful.border_width,
    border_color = beautiful.border_normal, focus = true, keys = clientkeys,
    buttons = clientbuttons } }, 
    { rule = { class = "MPlayer" }, properties = {
        floating = true,
        tag = tags[1][5],
        switchtotag = tags[1][5] } }, 
    { rule = { class = "Skype" }, properties = {
        floating = true } },
    { rule = { class = "pinentry" }, properties = {
            floating = true } }, 
    { rule = { class = "Gimp" }, properties = {
            tag = tags[1][5],
            switchtotag = tags[1][5] } },
    { rule = { class = "Claws Mail" }, properties = {
            tag = tags[1][4],
            switchtotag = tags[1][5] } },
    { rule = { class = "wine" }, properties = {
                floating = true } },
    { rule = { name = "EKG2" }, properties = {
            tag = tags[1][3],
            switchtotag = tags[1][3] } },
    { rule = { name = "IRSSI" }, properties = {
            tag = tags[1][3],
            switchtotag = tags[1][3] } },
    { rule = { name = ".*Simutrans.*" }, properties = {
                floating = false } },
    { rule = { name = ".*Wine.*" }, properties = {
                floating = true } },
    { rule = { name = ".*VirtualBox" }, properties = {
            tag = tags[1][7],
            switchtotag = tags[1][7] } },
    { rule = { name = ".*UltraStar Delux.*" }, properties = {
            tag = tags[1][8],
            switchtotag = tags[1][8] } },
    -- Set Firefox to always map on tags number 2 of screen 1.  { rule = {
    -- class = "Firefox" }, properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("list", function (c)
    widgets["curtag"].text = " " .. awful.tag.selected().name .. ":" .. #awful.tag.selected():clients() .. " "
    if awful.tag.selected() == tags[1][1] then
        if #tags[1][1]:clients() > 2 then
            awful.tag.setproperty(tags[1][1], "nmaster", 2)
            awful.tag.setproperty(tags[1][1], "mwfact", 0.7)
        else
            awful.tag.setproperty(tags[1][1], "nmaster", 1)
            awful.tag.setproperty(tags[1][1], "mwfact", 0.6)
        end
    end
end)
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

for s = 1, screen.count() do
    for t = 1, #tags[s] do
        tags[s][t]:add_signal("tagged", function ()
            if awful.tag.selected() ~= nil then
                widgets["curtag"].text = " " .. awful.tag.selected().name .. ":" .. #awful.tag.selected():clients() .. " "
            end
            if s == 1 and t == 1 then
                if #tags[s][t]:clients() > 2 then
                    awful.tag.setproperty(tags[s][t], "nmaster", 2)
                    awful.tag.setproperty(tags[s][t], "mwfact", 0.7)
                else
                    awful.tag.setproperty(tags[s][t], "nmaster", 1)
                    awful.tag.setproperty(tags[s][t], "mwfact", 0.6)
                end
            end
        end)
        tags[s][t]:add_signal("property::selected", function ()
            if awful.tag.selected() ~= nil then
                widgets["curtag"].text = " " .. awful.tag.selected().name .. ":" .. #awful.tag.selected():clients() .. " "
            end
        end)
    end
end
-- }}}
