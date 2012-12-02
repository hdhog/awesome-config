require('freedesktop.menu')
local awful = require("awful")
local beautiful = require("beautiful")

freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = {'nuvola','oxygen'} -- look inside /usr/share/icons/, default: nil (don't use icon theme)

menu_items = freedesktop.menu.new()

shutdown_command='dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
reboot_command='dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'
sleep_command='dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend'
hibernate_command='dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate'
screen_lock_command="slimlock"

myawesomemenu = {
	{ "Конфиг", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'preferences-system' })  },
	{ "Перезапустить", awesome.restart },
	{ "Выход", awesome.quit }
}
-- TODO добавить проверку наличия бокса
function gen_vbox_menu()
	local f = io.popen('VBoxManage list vms |  egrep -o \"\\".*\\"\"') -- runs command
	local line = ""
	local rez = {}

	while line ~= nil do
		line = f:read("*l")
		if line ~= nil then
			table.insert(rez,{line,"VBoxManage startvm " .. line })
		end
	end

	return rez
end

vbox_menu = gen_vbox_menu()

exit_menu = {
	{ "Блокировать экран", screen_lock_command, freedesktop.utils.lookup_icon({ icon = 'system-lock-screen' })  },
	{ "Выключение", shutdown_command, freedesktop.utils.lookup_icon({ icon = 'system-shutdown' })  },
	{ "Перезагрузка" , reboot_command, freedesktop.utils.lookup_icon({ icon = 'system-reboot' })  },
	{ "Сон" , sleep_command , freedesktop.utils.lookup_icon({ icon = 'system-suspend' }) },
	{ "Гибернация" , hibernate_command, freedesktop.utils.lookup_icon({ icon = 'system-suspend-hibernate' })  }
}

table.insert(menu_items, { "Awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "Завершение работы",exit_menu , freedesktop.utils.lookup_icon({ icon = 'system-shutdown' }) })
table.insert(menu_items, { "VirtualBox",vbox_menu, freedesktop.utils.lookup_icon({ icon = 'virtualbox'}) })
table.insert(menu_items, { "Terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

mymainmenu = awful.menu.new({ items = menu_items, width = 170 })
