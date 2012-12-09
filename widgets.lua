local vicious = require("vicious")
local gears = require("gears")
require("blingbling")
require("awesompd/awesompd")
require("iwlist")
require("markup")
local naughty = require("naughty")
local cal = require("cal")
require("awesompd/awesompd")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
awful.util = require("awful.util")
local exec   	= awful.util.spawn
local sexec  	= awful.util.spawn_with_shell

--{{{ MPD виджет
musicwidget 			= awesompd:create()
musicwidget.font 		= "Snap 8"
musicwidget.scrolling 		= true
musicwidget.output_size 	= 30
musicwidget.update_interval 	= 5
musicwidget.path_to_icons 	= "/home/serg/.config/awesome/icons"
musicwidget.jamendo_format 	= awesompd.FORMAT_MP3
musicwidget.show_album_cover 	= true
musicwidget.album_cover_size 	= 90
musicwidget.mpd_config 		= "/home/serg/.mpdconf"
musicwidget.browser 		= "chromium"
musicwidget.ldecorator 		= " "
musicwidget.rdecorator 		= " "
musicwidget.servers 		= { { server = "localhost", port = 6600 } }
musicwidget:register_buttons({
				{ "", awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
				{ "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
				{ "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
				{ "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
				{ "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
				{ "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() }
			})
musicwidget:run()
--}}}
-- {{{ Создание виджета разделителя
separator 	= wibox.widget.imagebox()--wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep )
-- }}}
-- {{{ Виджет батареи
baticon 	= wibox.widget.imagebox() --wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
batwidget 	= wibox.widget.textbox()--wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,"$2%", 120, "BAT0")
-- }}}

-- {{{ Видежет отображения раскладки для работы требудется kbdd
kbdwidget 		= wibox.widget.textbox()--widget({type = "textbox", name = "kbdwidget"})
kbdwidget.border_width 	= 0
kbdwidget.border_color 	= beautiful.fg_normal
kbdwidget:set_text( " En " )
dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd",
	function(...)
		local data = {...}
		local layout = data[2]
		lts = {[0] = "En", [1] = "Ru"}
		kbdwidget:set_text( " "..lts[layout].." ")
	end)
-- }}}
-- {{{ Виджет управления громкостью
-- TODO запилить свой виджет отображения громкости. 
volicon 	= wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volwidget 	= wibox.widget.textbox()
--volbar = blingbling.progress_graph.new()
--volbar:set_height(12)
--volbar:set_width(6)
--volbar:set_h_margin(0)
--volbar:set_v_margin(0)

-- TODO сделать обновление инфы о громкости не по таймеру.
vicious.cache(vicious.widgets.volume)
-- Регистрация виджета
--vicious.register(volbar,    vicious.widgets.volume,  "$1",  5, "Master")
vicious.register(volwidget, vicious.widgets.volume, "$1%", 5, "Master")
-- }}}

-- {{{ Виджет отображающий время и календарь
datewidget = wibox.widget.textbox()
cal.register(datewidget, markup.bg(beautiful.fg_normal,'<span color="#ff0000"><b>%s</b></span>'))
vicious.register(datewidget, vicious.widgets.date, " %R ", 60)
-- }}}

-- {{{ Загрука и температура процессора
cpuicon 	= wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
tzswidget 	= wibox.widget.textbox()
vicious.register(tzswidget, vicious.widgets.thermal, "$1°C", 19, "thermal_zone0")

cpu_graph = blingbling.line_graph.new()
cpu_graph:set_width(100)
cpu_graph:set_height(12)
cpu_graph:set_h_margin(0)
cpu_graph:set_v_margin(0)
cpu_graph:set_show_text(false)
cpu_graph:set_background_color("#00000044")
--cpu_graph:set_graph_background_color("#000000")
cpu_graph:set_graph_line_color("#FF000000")
vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)
--
--cpu_core_1 = blingbling.progress_graph.new()
--cpu_core_1:set_height(12)
--cpu_core_1:set_width(6)
--cpu_core_1:set_h_margin(1)
--cpu_core_1:set_v_margin(0)
--vicious.register(cpu_core_1, vicious.widgets.cpu, "$2",2)

--cpu_core_2 = blingbling.progress_graph.new()
--cpu_core_2:set_height(12)
--cpu_core_2:set_width(6)
--cpu_core_2:set_h_margin(1)
--cpu_core_2:set_v_margin(0)
--vicious.register(cpu_core_2, vicious.widgets.cpu, "$3",2)

--cpu_core_3 	= blingbling.progress_graph.new()
--cpu_core_3:set_height(12)
--cpu_core_3:set_width(6)
--cpu_core_3:set_h_margin(1)
--cpu_core_3:set_v_margin(0)
--vicious.register(cpu_core_3, vicious.widgets.cpu, "$4",2)

--cpu_core_4 	= blingbling.progress_graph.new()
--cpu_core_4:set_height(12)
--cpu_core_4:set_width(6)
--cpu_core_4:set_h_margin(1)
--cpu_core_4:set_v_margin(0)
--vicious.register(cpu_core_4, vicious.widgets.cpu, "$5",2)
--}}}
-- {{{ Использование памяти
memicon 	= wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget 	= blingbling.line_graph.new()
memwidget:set_height(12)
memwidget:set_width(100)
memwidget:set_v_margin(0)
memwidget:set_h_margin(0)
memwidget:set_graph_line_color("#FF000000")
memwidget:set_show_text(false)
memwidget:set_background_color("#00000044")
vicious.register(memwidget, vicious.widgets.mem, '$1', 5)
-- }}}
-- {{{ Загрука сети
--  TODO запилить несолько интерфейсов
--  FIXME пофиксить отображение если ни один из контролируемых интерфейсов не поднят
dnicon 		= wibox.widget.imagebox()
upicon 		= wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)

network = wibox.widget.textbox()
vicious.register(network, vicious.widgets.net, '<span color="#CC9393">${wlan0 up_kb} Kb/s</span> : <span color="#7F9F7F">${wlan0 down_kb} Kb/s</span>', 3)

-- {{{ Температура HDD
hddtempicon 		= wibox.widget.imagebox()
hddtempicon:set_image(beautiful.widget_temp)
hddtempwidget 		= wibox.widget.textbox()
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda}°C", 30)
--}}}

--{{{ Gmail уведомления о почте
gmailicon = wibox.widget.imagebox()-- widget({type = "imagebox"})
gmailicon:set_image(beautiful.widget_mail)
gmail = wibox.widget.textbox()
gmail:set_text( "?" )
timer = timer{ timeout = 30 }
timer:connect_signal("timeout", function ()
	local f = io.open("/tmp/gmail","rw")
	local l = nil
	if ( f ) then
		l = f:read() -- read output of command
		f:close()
	else
		l = "?"
	end
	gmail:set_markup(l)
	os.execute("~/.config/awesome/gmail.py > /tmp/gmail &")
end)
timer:start()
--}}}

-- {{{ Состояние файловой системы
fs_home = blingbling.progress_graph.new()
fs_home:set_height(12)
fs_home:set_width(65)
fs_home:set_show_text(true)
fs_home:set_text_color("#ffffffff")
fs_home:set_background_text_color("#00000000")
fs_home:set_v_margin(0)
fs_home:set_h_margin(0)
fs_home:set_horizontal(true)
--fs_home:set_filled(true)
fs_home:set_label(" /home")
vicious.register(fs_home, vicious.widgets.fs, "${/home used_p}", 120)
--
fs_root = blingbling.progress_graph.new()
fs_root:set_height(12)
fs_root:set_width(65)
fs_root:set_show_text(true)
fs_root:set_text_color("#ffffffff")
fs_root:set_background_text_color("#00000000")
fs_root:set_horizontal(true)
--fs_root:set_filled(true)
fs_root:set_v_margin(0)
fs_root:set_label(" /root")
vicious.register(fs_root, vicious.widgets.fs, "${/ used_p}", 120)

--fs_root_label = wibox.widget.textbox()
--fs_home_label = wibox.widget.textbox()

-- }}}
-- {{ Wifi
wifi_icon = wibox.widget.imagebox()
wifi_icon:set_image(beautiful.widget_wifi)
wifi_widget = wibox.widget.textbox()

vicious.register(wifi_widget, vicious.widgets.wifi,
	function(widget, args)
		local quality = 0
		if args["{linp}"] > 0 then
			quality = args["{link}"] / args["{linp}"] * 100
		end
		return ("%s: %.1f%%"):format(args["{ssid}"], quality)
	end,
7, "wlan0")

wifi_icon:buttons( wifi_widget:buttons( awful.util.table.join(
	awful.button({}, 1,
	function()
		local networks = iwlist.scan_networks()
		if #networks > 0 then
			local msg = {}
			for i, ap in ipairs(networks) do
				local line = "<b>ESSID:</b> %s <b>MAC:</b> %s <b>Qual.:</b> %.2f%% <b>%s</b>"
				local enc = iwlist.get_encryption(ap)
				msg[i] = line:format(ap.essid, ap.address, ap.quality, enc)
			end
			naughty.notify({text = table.concat(msg, "\n")})
		else
		end
	end),
	awful.button({ }, 3, function ()  vicious.force{wifiwidget} end)
)))

function set_volume(flag)

	if flag then
		exec("amixer set Master 2%+")
	else
		exec("amixer set Master 2%-")
	end

        fd = io.popen("amixer sget Master")
        status = fd:read("*all")
        fd:close()

        volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
	pgbar = ""

	for i = 0, 99, 1 do
		if i < volume then
			pgbar = pgbar .. "|"
		else
			pgbar = pgbar .. "."
		end
	end

	local titl = "Громкость " .. volume .. "%"
	local progress = "[".. pgbar .. "]"

	if vol_info ~= nil then
		vol_info = naughty.notify({ title = progress,
					    text = titl,
					    replaces_id = vol_info.id
				    	})
	else
		vol_info = naughty.notify({  title = progress,
					     text = titl })
	end
end
