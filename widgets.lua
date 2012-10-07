local vicious = require("vicious")
require("blingbling")
require("awesompd/awesompd")
require("iwlist")
require("markup")
require("naughty")
require("cal")
require("awesompd/awesompd")
require("perceptive")
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
-- {{{ Создание виджета разделителя
separator 	= widget({ type = "imagebox" })
separator.image = image( beautiful.widget_sep )
-- }}}
-- {{{ Виджет батареи
baticon 	= widget({ type = "imagebox" })
baticon.image 	= image(beautiful.widget_bat)
batwidget 	= widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat,"$2%", 60, "BAT0")
-- }}}

-- {{{ Видежет отображения раскладки для работы требудется kbdd
kbdwidget 		= widget({type = "textbox", name = "kbdwidget"})
kbdwidget.border_width 	= 0
kbdwidget.border_color 	= beautiful.fg_normal
kbdwidget.text 		= " En "
dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.add_signal("ru.gentoo.kbdd",
	function(...)
		local data = {...}
		local layout = data[2]
		lts = {[0] = "En", [1] = "Ru"}
		kbdwidget.text = " "..lts[layout].." "
	end)
-- }}}
-- {{{ Виджет управления громкостью
volicon 	= widget({ type = "imagebox" })
volicon.image 	= image(beautiful.widget_vol)
volbar 		= awful.widget.progressbar()
volwidget 	= widget({ type = "textbox" })
-- Параметры прогресс бара
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(12):set_width(6):set_ticks_size(1)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget, beautiful.fg_center_widget, beautiful.fg_end_widget })
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Регистрация виджета
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
-- }}}

-- {{{ Виджет отображающий время и календарь
datewidget = widget({ type = "textbox" })
cal.register(datewidget, markup.bg(beautiful.fg_normal,'<span color="#ff0000"><b>%s</b></span>'))
vicious.register(datewidget, vicious.widgets.date, " %R ", 61)
-- }}}

-- {{{ Загрука и температура процессора
cpuicon 	= widget({ type = "imagebox" })
cpuicon.image 	= image(beautiful.widget_cpu)
tzswidget 	= widget({ type = "textbox" })
vicious.register(tzswidget, vicious.widgets.thermal, " $1°C", 19, "thermal_zone0")

cpu_graph = blingbling.classical_graph.new()
cpu_graph:set_height(12)
cpu_graph:set_width(85)
cpu_graph:set_v_margin(0)
cpu_graph:set_tiles_color("#00000022")
cpu_graph:set_show_text(false)
cpu_graph:set_filled(true)
vicious.register(cpu_graph, vicious.widgets.cpu,'$1',2)
--
cpu_core_1 = blingbling.progress_graph.new()
cpu_core_1:set_height(12)
cpu_core_1:set_width(6)
cpu_core_1:set_filled(true)
cpu_core_1:set_h_margin(1)
cpu_core_1:set_v_margin(0)
cpu_core_1:set_filled_color("#00000033")
vicious.register(cpu_core_1, vicious.widgets.cpu, "$2")

cpu_core_2 	= blingbling.progress_graph.new()
cpu_core_2:set_height(12)
cpu_core_2:set_width(6)
cpu_core_2:set_filled(true)
cpu_core_2:set_h_margin(1)
cpu_core_2:set_v_margin(0)
cpu_core_2:set_filled_color("#00000033")
vicious.register(cpu_core_2, vicious.widgets.cpu, "$3")

cpu_core_3 	= blingbling.progress_graph.new()
cpu_core_3:set_height(12)
cpu_core_3:set_width(6)
cpu_core_3:set_filled(true)
cpu_core_3:set_h_margin(1)
cpu_core_3:set_v_margin(0)
cpu_core_3:set_filled_color("#00000033")
vicious.register(cpu_core_3, vicious.widgets.cpu, "$4")

cpu_core_4 	= blingbling.progress_graph.new()
cpu_core_4:set_height(12)
cpu_core_4:set_width(6)
cpu_core_4:set_filled(true)
cpu_core_4:set_h_margin(1)
cpu_core_4:set_v_margin(0)
cpu_core_4:set_filled_color("#00000033")
vicious.register(cpu_core_4, vicious.widgets.cpu, "$5")
--}}}
-- {{{ Использование памяти
memicon 	= widget( { type = "imagebox" })
memicon.image 	= image(beautiful.widget_mem)
memwidget 	= blingbling.classical_graph.new()
memwidget:set_height(12)
memwidget:set_width(85)
memwidget:set_v_margin(0)
memwidget:set_filled(true)
memwidget:set_tiles_color("#00000022")
memwidget:set_show_text(false)
vicious.register(memwidget, vicious.widgets.mem, '$1', 5)
-- }}}
-- {{{ Загрука сети
--  TODO запилить несолько интерфейсов
--  FIXME пофиксить отображение если ни один из контролируемых интерфейсов не поднят
dnicon 		= widget({ type = "imagebox" })
upicon 		= widget({ type = "imagebox" })
dnicon.image 	= image(beautiful.widget_net)
upicon.image 	= image(beautiful.widget_netup)

network = widget({ type = "textbox" })
vicious.register(network, vicious.widgets.net, '<span color="#CC9393">${wlan0 up_kb} Kb/s</span> : <span color="#7F9F7F">${wlan0 down_kb} Kb/s</span>', 3)

-- {{{ Температура HDD
hddtempicon 		= widget({ type = "imagebox" })
hddtempicon.image 	= image(beautiful.widget_temp)
hddtempwidget 		= widget({ type = "textbox" })
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda}°C", 19)
--}}}

--{{{ Gmail уведомления о почте
gmailicon = widget({type = "imagebox"})
gmailicon.image = image (beautiful.widget_mail)
gmail = widget({ type = "textbox" })
gmail.text = "?"
timer = timer{ timeout = 30 }
timer:add_signal("timeout", function ()
	local f = io.open("/tmp/gmail","rw")
	local l = nil
	if ( f ) then
		l = f:read() -- read output of command
		f:close()
	else
		l = "?"
	end
	gmail.text = l
	os.execute("~/.config/awesome/gmail.py > /tmp/gmail &")
end)
timer:start()
--}}}

-- {{{ Состояние файловой системы
fs_home = blingbling.progress_graph.new()
fs_home:set_height(12)
fs_home:set_width(55)
fs_home:set_show_text(true)
fs_home:set_text_color("#ffffffff")
--fs_home:set_font_size(10)
fs_home:set_background_text_color("#00000000")
fs_home:set_v_margin(0)
fs_home:set_h_margin(0)
fs_home:set_horizontal(true)
fs_home:set_filled(true)
fs_home:set_label("/home")
--fs_home:set_graph_line_color('#000000FF') -- цвет лининии бордюра
vicious.register(fs_home, vicious.widgets.fs, "${/home used_p}", 120)
--
fs_root = blingbling.progress_graph.new()
fs_root:set_height(12)
fs_root:set_width(55)
fs_root:set_show_text(true)
fs_root:set_text_color("#ffffffff")
--fs_root:set_font_size(10)
fs_root:set_background_text_color("#00000000")
fs_root:set_horizontal(true)
fs_root:set_filled(true)
fs_root:set_v_margin(0)
fs_root:set_label("/root")
vicious.register(fs_root, vicious.widgets.fs, "${/ used_p}", 120)

fs_root_label = widget({ type = "textbox" })
fs_root_label.text = ""--"/root: "

fs_home_label = widget({ type = "textbox" })
fs_home_label.text = ""--"/home: "
-- }}}
-- {{ Wifi
wifi_icon = widget({type = "imagebox"})
wifi_icon.image = image(beautiful.widget_wifi)
wifi_widget = widget({type = "textbox"})

local wifitooltip= awful.tooltip({})
wifitooltip:add_to_object(wifi_widget)

vicious.register(wifi_widget, vicious.widgets.wifi,
	function(widget, args)
		--local tooltip = ("<b>mode</b> %s <b>chan</b> %s <b>rate</b> %s Mb/s"):format(args["{mode}"], args["{chan}"], args["{rate}"])
		local quality = 0
		if args["{linp}"] > 0 then
			quality = args["{link}"] / args["{linp}"] * 100
		end
		--wifitooltip:set_text(tooltip)

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
	awful.button({ "Shift" }, 1, function ()
		local wpa_cmd = "sudo restart-auto-wireless && notify-send 'wpa_actiond' 'restarted' || notify-send 'wpa_actiond' 'error on restart'"
		sexec(wpa_cmd)
	end), -- left click
awful.button({ }, 3, function ()  vicious.force{wifiwidget} end)
)))
