--- {{{ Keybindings
val = nil
globalkeys = awful.util.table.join(
        awful.key({ modkey, }, "Left",   awful.tag.viewprev       ),
        awful.key({ modkey, }, "Right",  awful.tag.viewnext       ),
        awful.key({ modkey, }, "0", function ()
            awful.tag.viewnone()
            widgets["curtag"].text = " zero"
        end),
        awful.key({ modkey, }, "p", function()
--            widgets["curtag"].text = awful.tag.selected().name
              tags[1][1]:emit_signal("selected")
        end),
        awful.key({ modkey, }, "Return", 
            function() mainmenu:show(true)    end),
        awful.key({ modkey, }, "Up",
            function ()
                awful.client.focus.byidx( 1)
                if client.focus then client.focus:raise() end
            end),
        awful.key({ modkey, }, "Down",
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end),
        -- Layout manipulation
        awful.key({ modkey, "Shift" }, "Right", 
            function () awful.client.swap.byidx(  1)    end),
        awful.key({ modkey, "Shift" }, "Left", 
            function () awful.client.swap.byidx( -1)    end),
        awful.key({ modkey, }, "Tab",
            function ()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end),
        awful.key({ modkey, }, "space", 
            function () awful.layout.inc(layouts,  1) end),
        awful.key({ modkey, "Mod1" }, "space", 
            function () awful.layout.inc(layouts, -1) end),
        awful.key({ modkey, "Control" }, "Left",
            function () awful.client.focus.bydirection("left") end),
        awful.key({ modkey, "Control" }, "Right",
            function () awful.client.focus.bydirection("right") end),
        awful.key({ modkey, "Control" }, "Up",
            function () awful.client.focus.bydirection("up") end),
        awful.key({ modkey, "Control" }, "Down",
            function () awful.client.focus.bydirection("down") end),
        awful.key({ modkey, "Mod1" }, "Up",
            function () awful.tag.incnmaster( 1) end),
        awful.key({ modkey, "Mod1" }, "Down",
            function () awful.tag.incnmaster(-1) end),
        awful.key({ modkey, "Mod1" }, "Right", 
            function () awful.tag.incncol( 1) end),
        awful.key({ modkey, "Mod1" }, "Left",
            function () awful.tag.incncol(-1) end),
        awful.key({ modkey, "Mod1", "Control" }, "Right", 
            function () awful.tag.incmwfact( 0.05) end),
        awful.key({ modkey, "Mod1", "Control" }, "Left", 
            function () awful.tag.incmwfact(-0.05) end),
        --- programs ---
        awful.key({ modkey, }, "`",
            function () awful.util.spawn(terminal) end),
        awful.key({ modkey, }, "t",
            function () 
                awful.util.spawn(terminal .. " -e screen -r rtorrent") 
            end),
        awful.key({ modkey, }, "u",
            function () awful.util.spawn("uzbl-browser") end),
        awful.key({ modkey, }, "e",
            function () 
                awful.tag.viewonly(tags[1][3])
                focus_or_create("ekg2", terminal .. " -e ekg2") 
            end),
        awful.key({ modkey, }, "f",
            function () 
--                awful.tag.viewonly(tags[1][3])
                focus_or_create("firefox", "firefox") 
            end),
        awful.key({ modkey, }, "m",
            function () 
                awful.tag.viewonly(tags[1][4])
                focus_or_create("mutt", terminal .. " -e \"sleep 1; mutt\"")
            end),
        awful.key({ modkey, }, "r",
            function () awesome.restart() end),
        awful.key({  }, "XF86AudioRaiseVolume",
            function ()
                naughty.notify({ text = io.popen("echo -n `amixer -c 0 sset PCM 5%+|sed -n 's/.*Front Left: Playback [0-9]* \\[\\([0-9]*\\)\\%\\] .*/Volume: \\1%/p'`"):read("*a") })
            end),
        awful.key({  }, "XF86AudioLowerVolume",
            function ()
                naughty.notify({ text = io.popen("echo -n `amixer -c 0 sset PCM 5%-|sed -n 's/.*Front Left: Playback [0-9]* \\[\\([0-9]*\\)\\%\\] .*/Volume: \\1%/p'`"):read("*a") })
            end),
        awful.key({  }, "XF86AudioMute",
            function ()
                os.execute("amixer -c 0 set Master toggle mutt")
                local on_off = io.popen("echo -n `amixer -c 0 get Master|sed -n 's/.*Front Left: Playback [0-9]* \\[[0-9]*\\%\\] \\[[^ ]*\\] \\[\\([a-z]*\\)\\].*/\\1/p'`"):read("*a")
                if on_off == "on" then
                    naughty.notify({ text = io.popen("echo -n `amixer -c 0 get PCM |sed -n 's/.*Front Left: Playback [0-9]* \\[\\([0-9]*\\)\\%\\] .*/Volume ON:\\1%/p'`"):read("*a") })
                else
                    naughty.notify({ text = "Volume OFF" })
                end
            end),
        awful.key({  }, "XF86AudioNext",
            function ()
                os.execute("xsong.pl n")
            end),
        awful.key({  }, "XF86AudioPrev",
            function ()
                os.execute("xsong.pl p")
            end),
        awful.key({  }, "XF86AudioPlay",
            function ()
                os.execute("xsong.pl t")
            end),
        awful.key({  }, "XF86AudioPause",
            function ()
                os.execute("xsong.pl t")
            end),
        awful.key({  }, "XF86AudioStop",
            function ()
                os.execute("mocp -x")
            end),
        awful.key({  }, "Print",
            function ()
                os.execute("import -window root screen.png")
            end),
        awful.key({ modkey, }, "o",
            function ()
                widgets["prompt"][mouse.screen]:run()
            end),
        awful.key({ modkey, }, "l",
              function ()
                  awful.prompt.run({ prompt = "<span color='green'>Run Lua code:</span> " },
                  widgets["prompt"][mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
        awful.key({ modkey, }, "k", 
            function ()
                awful.prompt.run({  text = val and tostring(val),
                selectall = true,
                prompt = "<span color='#00A5AB'>Calc:</span> " },
                widgets["prompt"][mouse.screen].widget,
                function(expr)
                    awful.util.eval("val=" .. expr)
                    naughty.notify({ text = expr .. ' = <span color="white">' .. val .. "</span>",
                    timeout = 10,
                    run = function() 
                        local f = io.popen("echo -n ".. val .. " | xsel -i -b && echo -n " .. val .. "|xsel -i -p && echo -n "..val.."|xsel -i -s")
                        f:close() 
                    end, })
                end,
                nil, awful.util.getdir("cache") .. "/calc")
            end),
        awful.key({ modkey, }, "n",
            function ()
                add_event()
            end),
        awful.key({ modkey, "Mod1", }, "n",
            function ()
                delete_event()
            end),
        awful.key({ modkey, "Control", }, "n",
            function ()
                add_calendar(0, 5)
            end),
        awful.key({ modkey, "Control", }, "d",
            function ()
                disks_show(5)
            end),
        awful.key({ modkey, "Control", }, "e",
            function ()
                netcard_show(5)
            end)
        )

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key(  { modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          local screen = client.focus.screen
                          awful.client.movetotag(tags[screen][i])
                          awful.tag.viewonly(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end
