function notifyMusic(cmd)
    music = musicParse(cmd)
    remove_notification("mpd");
    add_notification("mpd", { timeout = 5, title = awful.util.linewrap(music["song"], 50, 0),
                     text = string.format("State: %s\nTiming: %s\nPercentage: %s", music["state"], music["timing"], music["percent"] .. "%"),
                     width = 350, icon = "/usr/share/icons/gentoo/l33t/l33t_MED_mplayer3.png" })
end

myfinder = awful.mouse.finder()

function calculator()
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
end

--- {{{ Keybindings
val = nil
globalkeys = awful.util.table.join(
        awful.key({ modkey, }, "Next",   awful.tag.viewprev       ),
        awful.key({ modkey, }, "g",   function () awful.mouse.finder.find(myfinder) end     ),
        awful.key({ modkey, }, "Prior",  awful.tag.viewnext       ),
        awful.key({ modkey, }, "0", function ()
            awful.tag.viewnone()
            widgets["curtag"].text = " zero"
        end),
        awful.key({ modkey, }, "p", function()
            awful.util.spawn_with_shell("xclip -o | xclip -i -selection clipboard")
        end),
        awful.key({ modkey, }, "Return", 
            function() mainmenu:show({keygrabber=true})    end),
        awful.key({ }, "Menu", 
            function() mainmenu:show({keygrabber=true})    end),
        awful.key({ modkey, "Control" }, "Up",
            function ()
                awful.client.focus.byidx( 1)
                if client.focus then client.focus:raise() end
            end),
        awful.key({ modkey, "Control" }, "Down",
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
        awful.key({ modkey, }, "Left",
            function () awful.client.focus.bydirection("left") end),
        awful.key({ modkey, }, "Right",
            function () awful.client.focus.bydirection("right") end),
        awful.key({ modkey, }, "Up",
            function () awful.client.focus.bydirection("up") end),
        awful.key({ modkey, }, "Down",
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
        awful.key({ modkey, }, "x",
            function () awful.util.spawn(terminal) end),
        awful.key({ modkey, }, "t",
            function () 
                awful.util.spawn(terminal .. terminal_title_param .. " RTORRENT -e screen -r rtorrent") 
            end),
        awful.key({ modkey, "Mod1" }, "r",
            function () 
                awful.util.spawn(terminal .. terminal_title_param .. " RSGET.PL -e screen -r rsget") 
            end),
        awful.key({ modkey, "Control"}, "w",
            function () 
                awful.util.spawn(terminal .. terminal_title_param .. " WICD -e wicd-curses") 
            end),
        awful.key({ modkey, }, "u",
            function () awful.util.spawn_with_shell("uzbl-browser >> " .. os.getenv("HOME") .. "/.uzbl-errors 2>&1") end),
        awful.key({ modkey, }, "w",
            function () awful.util.spawn_with_shell("luakit >> " .. os.getenv("HOME") .. "/.luakit-errors 2>&1") end),
        awful.key({ modkey, }, "e",
            function () 
                awful.tag.viewonly(tags[1][3])
                focus_or_create("EKG2", terminal .. terminal_title_param .. " EKG2 -e ekg2") 
            end),
        awful.key({ modkey, }, "i",
            function () 
                awful.tag.viewonly(tags[1][3])
                focus_or_create("IRSSI", terminal .. terminal_title_param .. " IRSSI -e screen -R -S IRSSI -t IRSSI irssi") 
            end),
        awful.key({ }, "XF86Search",
            function () 
                awful.tag.viewonly(tags[1][5])
                focus_or_create("MUSIC", terminal .. terminal_title_param .. " MUSIC -e ncmpcpp") 
            end),
        awful.key({ modkey, }, "f",
            function () 
--                awful.tag.viewonly(tags[1][3])
                focus_or_create("firefox", "firefox") 
            end),
--        awful.key({ modkey, }, "m",
        awful.key({ }, "XF86Mail",
            function () 
                awful.tag.viewonly(tags[1][4])
                -- focus_or_create("MUTT", terminal .. terminal_title_param .. " MUTT -e \"sleep 0.2; l=0; for x in `find ${HOME}/.maildir -type d -iname \"new\"`; do if [ `ls $x|wc -l` != 0 ]; then mutt -Z; l=1; break; fi; done; [ $l -eq 1 ] || mutt\"")
                focus_or_create("MUTT", terminal .. terminal_title_param .. " MUTT -e sh -c \"TERM='xterm-256color' mutt\"")
                -- focus_or_create("Thunderbird", "thunderbird")
            end),
        awful.key({ modkey, }, "r",
            function () awesome.restart() end),
        awful.key({  }, "XF86AudioRaiseVolume",
            function ()
                remove_notification("volume");
                add_notification("volume", { timout = 5, text = io.popen(".local/share/bin/sound-ctl.sh up"):read("*a") })
            end),
        awful.key({  }, "XF86AudioLowerVolume",
            function ()
                remove_notification("volume");
                add_notification("volume", { timout = 5, text = io.popen(".local/share/bin/sound-ctl.sh down"):read("*a") })
            end),
        awful.key({  }, "XF86AudioMute",
            function ()
                remove_notification("volume");
                add_notification("volume", { timeout = 5, text = io.popen(".local/share/bin/sound-ctl.sh toggle"):read("*a") })
            end),
        awful.key({  }, "XF86AudioNext",
            function ()
                notifyMusic("mpc next ")
            end),
        awful.key({  }, "XF86AudioPrev",
            function ()
                notifyMusic("mpc prev ")
            end),
        awful.key({  }, "XF86AudioPlay",
            function ()
                notifyMusic("mpc toggle ")
            end),
        awful.key({  }, "XF86AudioStop",
            function ()
                os.execute("mpc stop -q")
            end),
        awful.key({ modkey,  }, "/",
            function ()
                notifyMusic("mpc ")
            end),
        awful.key({ modkey, }, "F9", 
            function ()
                notifyMusic("mpc clear -q; mpc -q load metal; mpc play")
            end),
        awful.key({ modkey, }, "F10", 
            function ()
                notifyMusic("mpc clear -q; mpc -q load queen; mpc play")
            end),
        awful.key({ modkey, }, "F11", 
            function ()
                notifyMusic("mpc clear -q; mpc -q load ulubione; mpc play")
            end),
        awful.key({ modkey, }, "F12", 
            function ()
                notifyMusic("mpc clear -q; mpc -q load radiozet; mpc play")
            end),
        awful.key({  }, "Print",
            function ()
                os.execute("import -window root screen-`date +%s`.png")
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

              -- Calculator mappings
        awful.key({ modkey, }, "k", function () calculator() end),
        awful.key({ }, "XF86Calculator" , function () calculator() end),

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
