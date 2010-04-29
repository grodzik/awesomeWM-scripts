function game_start(game)
    awful.tag.viewonly(tags[1][7])
    awful.util.spawn(game)
end

programmingmenu = {
    { "Vim", terminal .. " -e vim" },
    { "gVim", "gvim" },
    { "MySQL-Workbench", "mysql-workbench" },
    { "MySQL-Workbench-bin", "mysql-workbench-bin" }
}

netmenu = {
    { "Skype", "skype" },
    { "EKG2", terminal .. " -e ekg2" },
    { "Mutt", terminal .. " -e mutt" },
    { "GoogleEarth", "googleearth" }
}

virtualmenu = {
    { "Server", "VBoxManage startvm server" },
    { "Windows", "VBoxManage startvm windows" },
    { "VirtualBox", "VirtualBox" }
}

officemenu = {
    { "&Acrobat Reader", "acroread" },
    { "Writer", "oowriter" },
    { "Calc", "oocalc" },
    { "Impress", "ooimpres" },
    { "Math", "oomath" },
    { "Draw", "oodraw" }, 
    { "Office", "ooffice" },
    { "Base", "oobase" }
}

multimediamenu = {
    { "Gimp", "gimp" },
    { "Gqview", "gqview" },
    { "XFBurn", "xfburn" }
}

gamesmenu = {
    { "Frozen-Bubble", function () game_start("frozen-bubble") end },
    { "Icy Tower", function () game_start("wine start /unix \"/home/grodzik/.wine/drive_c/games/icytower1.4/icytower14.exe\"") end },
    { "Atomic Tanks", function () game_start("atanks") end },
--    { "Diablo 2: LoD", function () game_start("wine start /unix \"/home/grodzik/.wine/drive_c/Diablo II/Diablo II.exe\"") end },
    { "Simutrans", function () game_start("simutrans") end },
    { "Wesnoth", function () game_start("wesnoth") end }
}

awesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mainmenu = awful.menu({
        items = { 
            { "&xterm", terminal },
            { "&root", terminal .. " -e su -" },
            { "&Programming", programmingmenu },
            { "&Net", netmenu },
            { "&Multimedia", multimediamenu },
            { "&VM", virtualmenu },
            { "&Office", officemenu },
            { "&Games", gamesmenu },
            { "&Awesome", awesomemenu }
        }
    })
