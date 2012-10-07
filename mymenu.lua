require('freedesktop.menu')

freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'nuvola' -- look inside /usr/share/icons/, default: nil (don't use icon theme)

menu_items = freedesktop.menu.new()

shutdown_command='dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
reboot_command='dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'
sleep_command='dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend'
hibernate_command='dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate'
screen_lock_command="slimlock"
myawesomemenu = {
	{ "Конфиг", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "Перезапустить", awesome.restart },
	{ "Выход", awesome.quit }
}

exit_menu = {
	{ "Блокировать экран",screen_lock_command },
	{ "Выключение",shutdown_command },
	{ "Перезагрузка" , reboot_command },
	{ "Сон" , sleep_command },
	{ "Гибернация" , hibernate_command }
}

table.insert(menu_items, { "Awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "Завершение работы",exit_menu , beautiful.awesome_icon })
table.insert(menu_items, { "Terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

mymainmenu = awful.menu.new({ items = menu_items, width = 170 })
