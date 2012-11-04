require("awful")
require("awful.autofocus")
require("awful.rules")

-- Установка локализации
os.setlocale(os.getenv("LANG"))

-- {{{ Обработка ошибок
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, были ошибки при запуске!",
			text = awesome.startup_errors
	})
end

-- Отображение ошибок
do
	local in_error = false
	awesome.add_signal("debug::error", function (err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, произошла ошибка!", text = err
		})
		in_error = false
	end)
end

-- }}}
-- Функция для запуска внешних приложений
function run_once(prg, args)
	if not prg then
		do return nil end
	end
	if not args then
		args=""
	end
	awful.util.spawn_with_shell('pgrep -f -u $USER -x ' .. prg .. ' || (' .. prg .. ' ' .. args ..')')
end

-- {{{ Variable definitions
-- Путь до файла с темой.
beautiful.init("/home/serg/.config/awesome/zenburn.lua")
confdir="/home/serg/.config"
local exec   	= awful.util.spawn
local sexec  	= awful.util.spawn_with_shell
terminal	= "urxvt -tr"
editor 	 	= "vim"
editor_cmd 	= terminal .. " -e " .. editor
awesome.font 	= "Snap 8"
modkey 		= "Mod4"


layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.magnifier
}
-- {{{ Теги
tags = {}
for s = 1, screen.count() do
	tags[s] = awful.tag({ "1:im", "2:web", "3:dev", "4:doc", "5:term", "6:fm", 7, 8, "9:video" }, s, layouts[2])
end

awful.tag.setncol(2, tags[1][1])
awful.tag.setnmaster (1, tags[1][1])
awful.tag.setmwfact (0.85, tags[1][1])
-- }}}

--{{{ Меню приложений
require("mymenu")
-- }}}

-- {{{ Wibox
-- Трей
mysystray = widget({ type = "systray" })
-- верхняя панель
top_panel = {}
-- нижняя панель
bottom_panel = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}

mytaglist.buttons = awful.util.table.join(
			awful.button({ }, 1, awful.tag.viewonly),
			awful.button({ modkey }, 1, awful.client.movetotag),
			awful.button({ }, 3, awful.tag.viewtoggle),
			awful.button({ modkey }, 3, awful.client.toggletag),
			awful.button({ }, 4, awful.tag.viewnext),
			awful.button({ }, 5, awful.tag.viewprev) )
mytasklist = {}

require("widgets")
-- {{{
for s = 1, screen.count() do
	-- запуск внешних команд
	mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
				awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
				awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
				awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
				awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
	-- Список тегов
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Создание панелей
	top_panel[s] 	= awful.wibox({ position = "top",    screen = s , height=12})
	bottom_panel[s] = awful.wibox({ position = "bottom", screen = s , height=12})

	top_panel[s].widgets = {
		{
			mytaglist[s],
			mypromptbox[s],
			layout = awful.widget.layout.horizontal.leftright
		},
		mylayoutbox[s], datewidget,
		separator, s == 1 and mysystray or nil,
		separator, kbdwidget, batwidget, baticon,
		separator, volwidget, volbar.widget, volicon,
		separator, gmail, gmailicon,
		separator, wifi_widget,wifi_icon,
		separator, layout = awful.widget.layout.horizontal.rightleft
	}

	bottom_panel[s].widgets = {
		separator, hddtempwidget,hddtempicon,
		separator, fs_home.widget,separator,fs_root.widget,fsicon,
		separator, tzswidget,cpu_core_1.widget,cpu_core_2.widget,cpu_core_3.widget,cpu_core_4.widget,
		separator, cpu_graph.widget, cpuicon,
		separator, memwidget.widget, memicon,
		separator, upicon,network,dnicon,
		separator, musicwidget.widget,
		layout = awful.widget.layout.horizontal.rightleft
	}
end
-- }}}
-- {{{ Назначение кнопок мыши
root.buttons(
	awful.util.table.join(
		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev) ) )
-- }}}

-- {{{ Назаначние кноком клавиатуры
globalkeys = awful.util.table.join(
	-- {{ Перемещение по тегам
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
	-- Блокировка экрана
	awful.key({ modkey, "Control" }, "l", function () exec("slimlock") end),
	-- {{ Медиа кнопки управления плеером
	awful.key({ }, "XF86AudioNext",  musicwidget:command_next_track()),
	awful.key({ }, "XF86AudioPrev",  musicwidget:command_prev_track()),
	awful.key({ }, "XF86AudioStop",  musicwidget:command_stop()),
	awful.key({ }, "XF86AudioPlay",  musicwidget:command_playpause()),
	-- }}
	-- {{Управление громкостью
	awful.key({ }, "XF86AudioRaiseVolume", function ()
			-- exec("amixer set Master 2%+")
			set_volume(true)
	end),
	awful.key({ }, "XF86AudioLowerVolume", function ()
		--exec("amixer set Master 2%-")
		set_volume(false)
	end),
	awful.key({ }, "XF86AudioMute", function () exec("amixer sset Master toggle") end),
	-- }}
	-- {{ Переключение фокуса окна
	awful.key({ modkey,           }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then
				client.focus:raise()
			end
		end),
	awful.key({ modkey,           }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then
				client.focus:raise()
			end
		end),
	-- }}
	-- Отображение меню приложений
	awful.key({ modkey,""}, "w", function () mymainmenu:show({keygrabber=true}) end),

	-- {{ Управление лайотами
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),
	-- }}
	-- Standard program
	awful.key({ modkey,           }, "Return", function () exec(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),
	awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
	awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
	awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
	awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
	awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
	awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
	awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	-- Запуск внешного приложения
	awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
	-- выполнение луа кода
	awful.key({ modkey }, "x",
		function ()
			awful.prompt.run({ prompt = "Run Lua code: " },
			mypromptbox[mouse.screen].widget,
			awful.util.eval, nil,
			awful.util.getdir("cache") .. "/history_eval")
		end) )

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
	awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
	awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
	awful.key({ modkey,           }, "n",      function (c) c.minimized = true    	     end),
	awful.key({ modkey,           }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end) )
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 9,
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
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.toggletag(tags[client.focus.screen][i])
				end
			end))
end

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize) )

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Правила для отображения окон
awful.rules.rules = {
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			maximized_vertical   = false,
			maximized_horizontal = false,
			buttons = clientbuttons
		}
	},

	{ rule = { class = "MPlayer"  		}, properties = { floating = false , tag = tags[1][9]	} },
	{ rule_any = { class = {
			"feh",
			"Keepassx",
			"Deadbeef",
			"Znotes",
			"Exe"
			}
		}, properties = { floating=true }},
	{ rule = { class = "Gimp" 	  	}, properties = { floating = false 			} },
	{ rule = { class = "Chromium-browser"   }, properties = { tag = tags[1][2],floating=false 	} },
	{ rule = { class = "Vacuum"		}, properties = { tag = tags[1][1] 			} },
	{ rule = { class = "Dolphin" 		}, properties = { tag = tags[1][6]			} },
	{ rule = { class = "Qtcreator"		}, properties = { tag = tags[1][3] 			} },
	{ rule = { class = "Kate" 		}, properties = { floating = false 			} },
	{ rule = { class = "Krusader" 		}, properties = { tag = tags[1][6] },callback = awful.placement.centered },
	{ rule_any = { name = {
				"Перемещение",
				"Удаление",
				"Процесс выполнения",
				"Копирование",
				"Распаковка файла*",
				"Проверка архива"
				}
			},
		properties = { tag = tags[1][6],floating=true },callback = awful.placement.centered }
}

-- }}}
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
		client.focus = c
		end
	end)

	if not startup then
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- {{{ автозапуск приложений
run_once("kbdd")
run_once("klipper")
run_once("wmname","LG3D")
-- }}}
