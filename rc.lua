local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
naughty = require("naughty")
require("runonce")

-- Установка локализации
os.setlocale(os.getenv("LANG"))


-- {{{ Обработка ошибок
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, были ошибки при запуске!",
			text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- }}}
-- {{{ Variable definitions
-- Путь до файла с темой.
-- TODO переделать на получение папки конфигов автоматом
confdir="/home/serg/.config"
--beautiful.init(confdir .. "/awesome/zenburn.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

terminal	= "urxvt -tr"
--terminal 	= "xterm"
editor 	 	= "vim"
editor_cmd 	= terminal .. " -e " .. editor
awesome.font 	= "Snap 8"
modkey 		= "Mod4"
-- лайоты
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

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- {{{ Теги
tags = {}
for s = 1, screen.count() do
	tags[s] = awful.tag({ "1:im", "2:web", "3:dev", "4:doc", "5:term", "6:fm", 7, "8:vm", "9:video" }, s, layouts[2])
end

awful.tag.setncol(2, tags[1][1])
awful.tag.setnmaster (1, tags[1][1])
awful.tag.setmwfact (0.85, tags[1][1])
-- }}}

--{{{ Меню
require("mymenu")
-- }}}
-- {{{ Wibox
-- Трей
mysystray = wibox.widget.systray()
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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
require("widgets")
-- {{{
for s = 1, screen.count() do
	-- запуск внешних команд
	mypromptbox[s] = awful.widget.prompt()--{ layout = awful.widget.layout.horizontal.leftright })
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
				awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
				awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
				awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
				awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
	-- Список тегов
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Создание панелей
	top_panel[s] 	= awful.wibox({ position = "top",    screen = s , height=12})
	bottom_panel[s] = awful.wibox({ position = "bottom", screen = s , height=12})
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mytaglist[s])

	left_layout:add(mypromptbox[s])

	local right_layout = wibox.layout.fixed.horizontal()
	--right_layout:add(separator)
	right_layout:add(spr)
    right_layout:add(arrl)
    right_layout:add(arrl_ld)
	right_layout:add(wifi_iconbg)
	right_layout:add(wifi_widgetbg)
	--right_layout:add(separator)
	right_layout:add(arrl_dl)
	right_layout:add(gmailicon)
	right_layout:add(gmail)
	--right_layout:add(separator)
	right_layout:add(arrl_ld)
	right_layout:add(baticonbg)
	right_layout:add(batwidgetbg)
	--right_layout:add(separator)
    right_layout:add(arrl_dl)
	right_layout:add(volicon)
	right_layout:add(volwidget)
	--right_layout:add(separator)
	right_layout:add(arrl_ld)
	right_layout:add(kbdwidgetbg)
	--right_layout:add(separator)
	right_layout:add(arrl_dl)
	if s == 1 then right_layout:add(mysystray) end
	right_layout:add(arrl_ld)
	right_layout:add(datewidgetbg)
	--right_layout:add(separator)
	right_layout:add(mylayoutbox[s])

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

 	top_panel[s]:set_widget(layout)

	local bottom_right_layout = wibox.layout.fixed.horizontal()
	bottom_right_layout:add(spr)
	bottom_right_layout:add(arrl)
	bottom_right_layout:add(dnicon)
	bottom_right_layout:add(network)
	bottom_right_layout:add(upicon)
	bottom_right_layout:add(arrl_dl)
	bottom_right_layout:add(memicon)
	bottom_right_layout:add(memwidget)
--	bottom_right_layout:add(separator)
	bottom_right_layout:add(arrl_ld)

	bottom_right_layout:add(cpuiconbg)
	bottom_right_layout:add(tzswidgetbg)
	bottom_right_layout:add(cpu_graph)

	--bottom_right_layout:add(separator)
	bottom_right_layout:add(arrl_dl)

	bottom_right_layout:add(fs_home)
--	bottom_right_layout:add(separator)
	bottom_right_layout:add(arrl_ld)
	bottom_right_layout:add(fs_root)

	local bottom_layout = wibox.layout.align.horizontal()
        bottom_layout:set_right(bottom_right_layout)

	bottom_panel[s]:set_widget(bottom_layout)
end
-- }}}
-- {{{ Назначение кнопок мыши
root.buttons(
	awful.util.table.join(
		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev) ) )
-- }}}

-- {{{ Назначение кнопкам клавиатуры
globalkeys = awful.util.table.join(
	-- {{ Перемещение по тегам
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
	-- Блокировка экрана
	awful.key({ modkey, "Control" }, "l", function () exec("slimlock") end),
	-- {{Управление громкостью
	awful.key({ }, "XF86AudioRaiseVolume", function ()
			set_volume(true)
	end),
	awful.key({ }, "XF86AudioLowerVolume", function ()
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
		end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
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
			"Exe" } }, properties = { floating=true }},
	{ rule = { class = "Gimp" 	  	}, properties = { floating = false 			} },
	{ rule = { class = "Chromium-browser"   }, properties = { tag = tags[1][2],floating=false 	} },
	{ rule = { class = "Vacuum"		}, properties = { tag = tags[1][1] 			} },
	{ rule = { class = "Dolphin" 		}, properties = { tag = tags[1][6]			} },
	{ rule_any = { class = {
			"Qtcreator" ,
			"Kdevelop" } }, properties = { tag = tags[1][3] } },
	{ rule = { class = "Kate" 		}, properties = { floating = false 			} },
	{ rule = { class = "Krusader" 		}, properties = { tag = tags[1][6] },callback = awful.placement.centered },
	{ rule_any = { class = {"Virt-manager", "VirtualBox" } }, properties = { tag = tags[1][8] } },
	-- добавить маску
	{ rule_any = { name = {
				"Перемещение",
				"Удаление",
				"Процесс выполнения",
				"Копирование",
				"Распаковка файла*",
				"Проверка архива",
				"Профиль*",
				"Профиль"
				}
			},
		properties = {floating=true },callback = awful.placement.centered }
}

-- }}}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
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
