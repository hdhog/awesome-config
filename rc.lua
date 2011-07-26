-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
require("markup")
-- Notification library
require("naughty")
-- Виджет календаря
require("cal")
require("vicious")
-- виджет меню приложений
require('freedesktop.menu')
-- {{{ Variable definitions
-- Путь до файла с темой.
beautiful.init("/home/serg/.config/awesome/zenburn.lua")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell
-- This is used later as the default terminal and editor to run.
terminal	= "urxvt -tr"
editor 	 	= "vim"
editor_cmd 	= terminal .. " -e " .. editor
awesome.font 	= "Snap 8"
modkey = "Mod4"

layouts =
{
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
--  awful.layout.suit.max.fullscreen,
--  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1:im", "2:web", "3:dev", "4:doc", "5:term", "6:fm", 7, 8, "9:video" }, s, layouts[2])
end
	awful.tag.setncol(2, tags[1][1])
	awful.tag.setnmaster (1, tags[1][1])
	awful.tag.setmwfact (0.85, tags[1][1])
-- }}}

-- {{{ Menu
-- Создание меню 
freedesktop.utils.icon_theme = 'gnome' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
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
mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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
-- вынести создание виджетов из цикла
for s = 1, screen.count() do
    	-- Create a promptbox for each screen
    	mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
    	-- We need one layoutbox per screen.
    	mylayoutbox[s] = awful.widget.layoutbox(s)
    	mylayoutbox[s]:buttons(awful.util.table.join(
        	                   awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                	           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                        	   awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                    	           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
    	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    	-- Create a tasklist widget
    	mytasklist[s] = awful.widget.tasklist(function(c)
        	                                      return awful.widget.tasklist.label.currenttags(c, s)
                	                          end, mytasklist.buttons)
	-- Создание виджета разделителя
	separator = widget({ type = "imagebox" })
	separator.image = image( beautiful.widget_sep )
    	-- Create the wibox
    	mywibox[s] = awful.wibox({ position = "top", screen = s , height=12})
    	-- Add widgets to the wibox - order matters
    	baticon = widget({ type = "imagebox" })
    	baticon.image = image(beautiful.widget_bat)
    	batwidget = widget({ type = "textbox" })
    	vicious.register(batwidget, vicious.widgets.bat,"$2%", 60, "BAT0")
	--{{{
	-- Keyboard layout widget
	-- для работы этого виджета нужно установить kbdd
	kbdwidget = widget({type = "textbox", name = "kbdwidget"})
	kbdwidget.border_width = 0
	kbdwidget.border_color = beautiful.fg_normal
	kbdwidget.text = " En "
	dbus.request_name("session", "ru.gentoo.kbdd")
	dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
	dbus.add_signal("ru.gentoo.kbdd", 
		function(...)
			local data = {...}
			local layout = data[2]
			lts = {[0] = "En", [1] = "Ru"}
			kbdwidget.text = " "..lts[layout].." "
		end
	)

	-- {{{ Volume level
	volicon = widget({ type = "imagebox" })
	volicon.image = image(beautiful.widget_vol)
	-- Initialize widgets
	volbar    = awful.widget.progressbar()
	volwidget = widget({ type = "textbox" })
	-- Progressbar properties
	volbar:set_vertical(true):set_ticks(true)
	volbar:set_height(12):set_width(6):set_ticks_size(1)
	volbar:set_background_color(beautiful.fg_off_widget)
	volbar:set_gradient_colors({ beautiful.fg_widget, beautiful.fg_center_widget, beautiful.fg_end_widget }) 
	 -- Enable caching
	vicious.cache(vicious.widgets.volume)
	-- Register widgets
	vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
	vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
	-- }}}
	-- {{{ Date and time
--	dateicon = widget({ type = "imagebox" })
--	dateicon.image = image(beautiful.widget_date)
	-- Initialize widget
	datewidget = widget({ type = "textbox" })
	cal.register(datewidget, markup.fg(beautiful.fg_focus,"<b>%s</b>"))
	-- Register widget
	vicious.register(datewidget, vicious.widgets.date, " %R ", 61)

	-- {{{ CPU usage and temperature
	cpuicon = widget({ type = "imagebox" })
	cpuicon.image = image(beautiful.widget_cpu)
	-- Initialize widgets
	cpugraph  = awful.widget.graph()
	tzswidget = widget({ type = "textbox" })
	-- Graph properties
	cpugraph:set_width(40):set_height(12)
	cpugraph:set_background_color(beautiful.fg_off_widget)
	cpugraph:set_gradient_angle(0):set_gradient_colors({
   		beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
    	}) -- Register widgets
	vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
	vicious.register(tzswidget, vicious.widgets.thermal, " $1°C", 19, "thermal_zone0")
	-- }}}
	--
	--
	-- {{{ Memory usage
	memicon = widget({ type = "imagebox" })
	memicon.image = image(beautiful.widget_mem)
	-- Initialize widget
	membar = awful.widget.progressbar()
	-- Pogressbar properties
	membar:set_vertical(true):set_ticks(true)
	membar:set_height(12):set_width(6):set_ticks_size(1)
	membar:set_background_color(beautiful.fg_off_widget)
	membar:set_gradient_colors({ beautiful.fg_widget, beautiful.fg_center_widget, beautiful.fg_end_widget }) -- Register widget
	vicious.register(membar, vicious.widgets.mem, "$1", 12)
	-- }}}
	-- {{{ File system usage
	fsicon = widget({ type = "imagebox" })
	fsicon.image = image(beautiful.widget_fs)
	local coverart_nf

	-- Initialize widgets
	fs = {
		r = awful.widget.progressbar(),
     		h = awful.widget.progressbar(), 
	}
	-- Progressbar properties
	for _, w in pairs(fs) do
		w:set_vertical(true):set_ticks(true)
	        w:set_height(12):set_width(6):set_ticks_size(1)
        	w:set_border_color( beautiful.border_widget)
	        w:set_background_color( beautiful.fg_off_widget)
	        w:set_gradient_colors({ beautiful.fg_widget,
        		beautiful.fg_center_widget, beautiful.fg_end_widget
   		}) 
		-- Register buttons
    		w.widget:buttons(awful.util.table.join(
			     awful.button({ }, 1, function () exec("pcmanfm", false) end)
	     	))
	end 
	-- Enable caching
	vicious.cache(vicious.widgets.fs)
	-- Register widgets
	vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",     599)
	vicious.register(fs.h, vicious.widgets.fs, "${/home used_p}", 599)

	--  Network usage widget
	-- Initialize widget
	netwidget = widget({ type = "textbox" })
	-- Register widget
	vicious.register(netwidget, vicious.widgets.net,
	function (widget, args)
   		local down, up, text = args["{ppp0 down_kb}"], args["{ppp0 up_kb}"]
   		if down ~= "0.0" or up ~= "0.0" then
      			text = ('<span color="#CC9393">%s</span> <span color="#7F9F7F">%s</span>'):format(args["{ppp0 down_kb}"], args["{ppp0 up_kb}"])
   		end
		if text == nil then
			text = '<span color="#CC9393">0.0</span> <span color="#7F9F7F">0.0</span>'
		end
   		return text
	end, 5)

	dnicon = widget({ type = "imagebox" })
 	upicon = widget({ type = "imagebox" })
 	dnicon.image = image(beautiful.widget_net)
 	upicon.image = image(beautiful.widget_netup)
	
	hddtempicon = widget({ type = "imagebox" })
	hddtempicon.image = image(beautiful.widget_temp)
	-- темпаратура жесткого диска
 	hddtempwidget = widget({ type = "textbox" })
  	vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda}°C", 19)

	mygmailicon = widget({type = "imagebox"})
	mygmailicon.image = image (beautiful.widget_mail)
	mygmail = widget({ type = "textbox" })
	mygmail_t = awful.tooltip(mygmail)
	vicious.register(mygmail, vicious.widgets.gmail,
		function (widget, args)
			mygmail_t:set_text(args["{subject}"])
			return '<span>'..args["{count}"]..'</span>'
		end, 127)

--	--}}}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    	mywibox[s].widgets = {
        	{
        		mylauncher,
        		mytaglist[s],
        		mypromptbox[s],   	    
        		layout = awful.widget.layout.horizontal.leftright
        	},
        	mylayoutbox[s],datewidget,
		separator, kbdwidget,batwidget,baticon,
        	separator, volwidget,  volbar.widget, volicon,
		separator, tzswidget,cpugraph.widget, cpuicon,
		separator, membar.widget, memicon,
		separator, hddtempwidget,hddtempicon,
		separator, fs.h.widget, fs.r.widget, fsicon,
		separator, mygmail,mygmailicon,
		separator, upicon,netwidget,dnicon,
	       	separator, s == 1 and mysystray or nil,
		mytasklist[s],
        	layout = awful.widget.layout.horizontal.rightleft
    	}
end
-- }}}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- {{{ Mouse bindings
root.buttons(
	awful.util.table.join(
    		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
    		awful.button({ }, 5, awful.tag.viewprev)
	)
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
--{{{
awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("slock") end),
--}}}
--{{{{
   awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 2%+") end),
   awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 2%-") end),
   awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer sset Master toggle") end),
--}}}}
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
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

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
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

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

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
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
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
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { 
	      	border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = true,
                keys = clientkeys,
                buttons = clientbuttons }},
		     
    { rule = { class = "MPlayer"  		}, properties = { floating = false , tag = tags[1][9]	} },
    { rule = { class = "feh" 			}, properties = { floating = true 			} },
    { rule = { class = "gimp" 	  		}, properties = { floating = true 			} },
    { rule = { class = "Chromium-browser"   	}, properties = { tag = tags[1][2], floating = false 	} },
    { rule = { class = "Sonata"   		}, properties = { floating = true 			} },
    { rule = { class = "Wicd-client.py"		}, properties = { floating = true 			} },
    { rule = { class = "Vacuum"			}, properties = { tag = tags[1][1] 			} },
    { rule = { class = "Pcmanfm" 		}, properties = { tag = tags[1][6]			} },
    { rule = { class = "Keepassx"		}, properties = { floating = true			} },
    { rule = { class = "Deadbeef"		}, properties = { floating = true 			} },
    { rule = { class = "Rednotebook"		}, properties = { floating = true 			} },
    { rule = { class = "Xarchiver"		}, properties = { floating = true			} },
    { rule = { class = "Gnote"			}, properties = { floating = true 			} },
}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
	client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    if awful.client.floating.get(c) 
	    -- or awful.layout.get(c.screen) == awful.layout.suit.floating 
then
	if   c.titlebar then 
		awful.titlebar.remove(c)
	else 
		awful.titlebar.add(c, {modkey = modkey, height = "16"}) end
	end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
