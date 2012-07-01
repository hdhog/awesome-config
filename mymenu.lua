require('freedesktop.menu')
freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'oxygen' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
menu_items = freedesktop.menu.new()
myawesomemenu = {
	{ "Manual", terminal .. " -e man awesome" },
	{ "Edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "Restart", awesome.restart },
	{ "Quit", awesome.quit }
}

table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

mymainmenu = awful.menu.new({ items = menu_items, width = 150 })
