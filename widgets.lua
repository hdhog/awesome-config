local v_contrib = require("vicious.contrib")
local vicious = require("vicious")
local gears = require("gears")
require("blingbling")
line_graph = require("blingbling.linegraph")
progress_graph= require("blingbling.progress_graph")
local awesompd = require("awesompd/awesompd")
require("iwlist")
require("markup")
local naughty = require("naughty")
local cal = require("cal")
require("awesompd/awesompd")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local asyncshell = require("asyncshell")
awful.util = require("awful.util")
local exec   	= awful.util.spawn
local sexec  	= awful.util.spawn_with_shell

--{{{ MPD виджет
musicwidget 			= awesompd:create()
musicwidget.font 		= "Snap 8"
musicwidget.scrolling 		= true
musicwidget.output_size 	= 90
musicwidget.update_interval 	= 5
musicwidget.path_to_icons 	= "/home/serg/.config/awesome/icons"
musicwidget.jamendo_format 	= awesompd.FORMAT_MP3
musicwidget.show_album_cover 	= true
musicwidget.album_cover_size 	= 45
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
separator = wibox.widget.textbox()
separator:set_markup("<span color='#31ff31'font='Terminus 10'> ⁝ </span>")
-- }}}
-- {{{ Виджет батареи
baticon 	= wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
batwidget 	= wibox.widget.textbox()

vicious.register(batwidget, vicious.widgets.bat,
	function (widget,args)
		return args[2] .. "%"
	end,
120, "BAT0")
-- }}}

-- {{{ Видежет отображения раскладки, для работы требудется kbdd
kbdwidget 		= wibox.widget.textbox()
kbdwidget.border_width 	= 0
kbdwidget.fit = function(widget, width, height)
    local _, h = wibox.widget.textbox.fit(widget, width, height)
    return 24, h
end

kbdwidget.border_color 	= beautiful.fg_normal
kbdwidget:set_text( " En" )
dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd",
	function(...)
		local data = {...}
		local layout = data[2]
		lts = {[0] = " En", [1] = " Ru"}
		kbdwidget:set_text(lts[layout])
	end)
-- }}}
-- {{{ Виджет управления громкостью
-- TODO запилить свой виджет отображения громкости. который будет работаеть без таймера
volicon 	= wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.volume)
-- Регистрация виджета
vicious.register(volwidget,    vicious.widgets.volume,
	function (widget,args)
        	local label = { ["♫"] = "on", ["♩"] = "off" }
		if label[args[2]] == "off" then
			return "m"
		end
		return args[1] .. "%"
	end,
10, "Master")
-- }}}

-- {{{ Виджет отображающий время и календарь
datewidget = wibox.widget.textbox()
cal.register(datewidget, markup.bg(beautiful.fg_normal,'<span color="#ff0000"><b>%s</b></span>'))
vicious.register(datewidget, vicious.widgets.date, " %R ", 60)
-- }}}

-- {{{ Загрузка и температура процессора
cpuicon 	= wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
tzswidget 	= wibox.widget.textbox()
vicious.register(tzswidget, vicious.widgets.thermal, "$1°C", 19, "thermal_zone0")

cpu_graph = line_graph({
			height = 12,
			width = 100,
			show_text = false,
			background_color = "#00000044",
			h_margin = 0,
			v_margin = 0,
			graph_line_color="#FF000000"
		      })
vicious.register(cpu_graph, vicious.widgets.cpu,'$1',5)
-- }}}
--
-- {{{ Использование памяти
memicon 	= wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget = line_graph({
		height = 12,
		width = 100,
		v_margin = 0,
		h_margin = 0,
		graph_line_color = "#FF000000",
		show_text = false,
		background_color = "#00000044"
})
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
vicious.register(network, vicious.widgets.net,
	'<span color="#CC9393">${wlan0 up_kb} Kb/s</span> : <span color="#7F9F7F">${wlan0 down_kb} Kb/s</span>', 5)

network:buttons( awful.util.table.join(
	awful.button({}, 1,
	function()
			naughty.notify({text = 'test'})
	end),
	awful.button({ }, 3, function ()  vicious.force{wifiwidget} end)
))
-- }}}
-- {{{ Температура HDD
hddtempicon 		= wibox.widget.imagebox()
hddtempicon:set_image(beautiful.widget_temp)
hddtempwidget 		= wibox.widget.textbox()
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda}°C", 30)
--}}}

--{{{ Gmail уведомления о почте
gmailicon = wibox.widget.imagebox()
gmailicon:set_image(beautiful.widget_mail)
gmail = wibox.widget.textbox()
gmail:set_text( "?" )

local function gmail_callback(f)
	text = f:read()
	if text ~= "0" and text ~= "?" then
		gmail:set_markup( "<span color='red'><b>".. text .."</b></span>")
	else
		gmail:set_text(text)
	end
end

gmail.timer = timer{timeout=120}
gmail.timer:connect_signal("timeout", function ()
	asyncshell.request('/home/serg/.config/awesome/gmail.py', function(f) gmail_callback(f) end)
end)
gmail.timer:start()
--}}}

-- {{{ Состояние файловой системы
fs_home = progress_graph({
	height=12,
	graph_line_color = "#00000000",
	width=65,
	show_text=true,
	text_color="#ffffffff",
	background_text_color="#00000000",
	v_margin=0,
	h_margin=0,
	horizontal=true,
	label=" /home",
	font = "Snap",
	font_size=10

})
vicious.register(fs_home, vicious.widgets.fs, "${/home used_p}", 120)
--
fs_root = progress_graph({
	height=12,
	width=65,
	show_text=true,
	graph_line_color = "#00000000",
	text_color="#ffffffff",
	background_text_color="#00000000",
	horizontal=true,
	v_margin=0,
	label=" /root",
	font = "Snap",
	font_size= 10
})
vicious.register(fs_root, vicious.widgets.fs, "${/ used_p}", 120)
-- }}}
-- {{ Wifi
wifi_icon = wibox.widget.imagebox()
wifi_icon:set_image(beautiful.widget_wifi)
wifi_widget = wibox.widget.textbox()

vicious.register(wifi_widget, vicious.widgets.wifi,
	function(widget, args)
		local quality = 0
		local result = ""
		if args["{ssid}"] ~= 'N/A' then
			if args["{linp}"] > 0 then
				quality = args["{link}"] / args["{linp}"] * 100
			end
			result =  ("%s: %.1f%%"):format(args["{ssid}"], quality)
		else
			result =  "n/a"
		end
		return result
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
-- }}
local vol_info = nil
function set_volume(flag)

	if flag then
		exec("amixer set Master 2%+")
	else
		exec("amixer set Master 2%-")
	end

        fd = io.popen("amixer sget Master")
        status = fd:read("*all")
        fd:close()

        local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
	local pgbar = "["

	for i = 0, 99, 1 do
		if i < volume then
			pgbar = pgbar .. "|"
		else
			pgbar = pgbar .. "."
		end
	end
	pgbar = pgbar .. "]"
	volume = 'Volume ' .. volume .. '%'

	if vol_info ~= nil then
		vol_info = naughty.notify({
				 	    text = pgbar,
					    title = volume ,
					    replaces_id = vol_info.id
				    	})
	else
		vol_info = naughty.notify({  text = pgbar,
					     title = volume
				     })
	end
end
