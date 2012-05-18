require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("markup")
require("naughty")
require("cal")
require("vicious")
require("blingbling")
require('freedesktop.menu')
require("awesompd/awesompd")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
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
function run_once(prg, args)
	if not prg then
		do return nil end
	end
	if not args then
		args=""
	end
	awful.util.spawn_with_shell('pgrep -f -u $USER -x ' .. prg .. ' || (' .. prg .. ' ' .. args ..')')
end

-- Путь до файла с темой.
beautiful.init("/home/serg/.config/awesome/zenburn.lua")
local exec   	= awful.util.spawn
local sexec  	= awful.util.spawn_with_shell
terminal	= "urxvt -tr"
editor 	 	= "vim"
editor_cmd 	= terminal .. " -e " .. editor
awesome.font 	= "Snap 8"
modkey 		= "Mod4"
-- автозапуск приложений
run_once("kbdd")
--run_once("mpd")
run_once("parcellite")
run_once("nm-applet")
run_once("kwalletmanager	")
--run_unce("wmname","LG3D")
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
	awful.layout.suit.magnifier
}
-- {{{ Теги
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
	tags[s] = awful.tag({ "1:im", "2:web", "3:dev", "4:doc", "5:term", "6:fm", 7, 8, "9:video" }, s, layouts[2])
end

awful.tag.setncol(2, tags[1][1])
awful.tag.setnmaster (1, tags[1][1])
awful.tag.setmwfact (0.85, tags[1][1])
-- }}}

-- {{{ Menu
--freedesktop.utils.icon_theme = 'gnome' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
--menu_items = freedesktop.menu.new()
--myawesomemenu = {
	--{ "Manual", terminal .. " -e man awesome" },
	--{ "Edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	--{ "Restart", awesome.restart },
	--{ "Quit", awesome.quit }
--}

--table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
--table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

--mymainmenu = awful.menu.new({ items = menu_items, width = 150 })
--mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a systray
mysystray = widget({ type = "systray" })

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
  						if c == client.focus then
                                                	c.minimized = true
                                              	else
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
-- MPD виджет
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
mywibox2 = {}
for s = 1, screen.count() do
	mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
        	                   awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                	           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                        	   awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                    	           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))
	)
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(function(c)
        	                                      return awful.widget.tasklist.label.currenttags(c, s)
                	                          end, mytasklist.buttons
	)
	-- Создание виджета разделителя
	separator 	= widget({ type = "imagebox" })
	separator.image = image( beautiful.widget_sep )
	-- Create the wibox
	mywibox[s] 	= awful.wibox({ position = "top",    screen = s , height=12})
	mywibox2[s] 	= awful.wibox({ position = "bottom", screen = s , height=12})
	-- Add widgets to the wibox - order matters
	baticon = widget({ type = "imagebox" })
	baticon.image = image(beautiful.widget_bat)
	batwidget = widget({ type = "textbox" })
	vicious.register(batwidget, vicious.widgets.bat,"$2%", 60, "BAT0")
	--{{{
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
		end)
	-- {{{ Виджет управления громкостью
	volicon = widget({ type = "imagebox" })
	volicon.image = image(beautiful.widget_vol)
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
	
	-- Виджет отображающий время и календарь
	datewidget = widget({ type = "textbox" })
	cal.register(datewidget, markup.bg(beautiful.fg_normal,'<span color="#ff0000"><b>%s</b></span>'))
	vicious.register(datewidget, vicious.widgets.date, " %R ", 61)

	-- {{{ Загрука профессора и температура
	cpuicon = widget({ type = "imagebox" })
	cpuicon.image = image(beautiful.widget_cpu)
	tzswidget = widget({ type = "textbox" })
	vicious.register(tzswidget, vicious.widgets.thermal, " $1°C", 19, "thermal_zone0")
	--}}}
	-- {{{ Использование памяти
	memicon = widget( { type = "imagebox" })
	memicon.image = image(beautiful.widget_mem)
	netwidget = widget( { type = "textbox" })
 	blingbling.popups.netstat( netwidget,
					{ 
						title_color = beautiful.notify_font_color_1, 
						established_color = beautiful.notify_font_color_3, 
						listen_color=beautiful.notify_font_color_2
					}
				)
	dnicon = widget({ type = "imagebox" })
 	upicon = widget({ type = "imagebox" })
 	dnicon.image = image(beautiful.widget_net)
 	upicon.image = image(beautiful.widget_netup)
	--}}}
	
	-- {{{ Температура HDD
	hddtempicon = widget({ type = "imagebox" })
	hddtempicon.image = image(beautiful.widget_temp)
 	hddtempwidget = widget({ type = "textbox" })
  	vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda}°C", 19)
	--}}}
	
	--{{{ Gmail уведомления о почте
	mygmailicon = widget({type = "imagebox"})
	mygmailicon.image = image (beautiful.widget_mail)
	mygmail = widget({ type = "textbox" })
	vicious.register(mygmail, vicious.widgets.gmail,"${count}",120)
	--}}}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 --
	mycairograph=blingbling.classical_graph.new()
	mycairograph:set_height(12)
	mycairograph:set_width(85)
	mycairograph:set_tiles_color("#00000022")
	mycairograph:set_show_text(false)
	vicious.register(mycairograph, vicious.widgets.cpu,'$1',2)
 --
	mycore1=blingbling.progress_graph.new()
	mycore1:set_height(12)
	mycore1:set_width(6)
	mycore1:set_filled(true)
	mycore1:set_h_margin(1)
	mycore1:set_filled_color("#00000033")
	vicious.register(mycore1, vicious.widgets.cpu, "$2")
	mycore2=blingbling.progress_graph.new()
	mycore2:set_height(12)
	mycore2:set_width(6)
	mycore2:set_filled(true)
	mycore2:set_h_margin(1)
	mycore2:set_filled_color("#00000033")
	vicious.register(mycore2, vicious.widgets.cpu, "$3")

	mycore3=blingbling.progress_graph.new()
	mycore3:set_height(12)
	mycore3:set_width(6)
	mycore3:set_filled(true)
	mycore3:set_h_margin(1)
	mycore3:set_filled_color("#00000033")
	vicious.register(mycore3, vicious.widgets.cpu, "$4")
	
	mycore4=blingbling.progress_graph.new()
	mycore4:set_height(12)
	mycore4:set_width(6)
	mycore4:set_filled(true)
	mycore4:set_h_margin(1)
	mycore4:set_filled_color("#00000033")
	vicious.register(mycore4, vicious.widgets.cpu, "$5")
 --
	memwidget=blingbling.classical_graph.new()
	memwidget:set_height(12)
	memwidget:set_width(85)
	memwidget:set_tiles_color("#00000022")
	memwidget:set_show_text(false)
	vicious.register(memwidget, vicious.widgets.mem, '$1', 5)
 --
	netwidget = widget({ type = "textbox", name = "netwidget" })
	my_net=blingbling.net.new()
	my_net:set_height(12)
	my_net:set_width(70)
	my_net:set_v_margin(3)
	my_net:set_interface("wlan0")
	my_net:set_show_text(true)
	my_net:set_background_text_color("#00000022")
	my_net:set_ippopup()

	my_fs=blingbling.progress_graph.new()
	my_fs:set_height(12)
	my_fs:set_width(55)
	my_fs:set_show_text(false)
	my_fs:set_horizontal(true)
	my_fs:set_filled(true)
	vicious.register(my_fs, vicious.widgets.fs, "${/home used_p}", 120)
 --
	my_fs_root=blingbling.progress_graph.new()
	my_fs_root:set_height(12)
	my_fs_root:set_width(55)
	my_fs_root:set_show_text(false)
	my_fs_root:set_horizontal(true)
	my_fs_root:set_filled(true)
	fs_root = widget({ type = "textbox" })
	fs_root.text="/root: "
	fs_home = widget({ type = "textbox" })
	fs_home.text="/home: "
	vicious.register(my_fs_root, vicious.widgets.fs, "${/ used_p}", 120)
 --
	--}}}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	mywibox[s].widgets = {
        	{
        		mytaglist[s],
        		mypromptbox[s],   	    
        		layout = awful.widget.layout.horizontal.leftright
        	},
        	mylayoutbox[s],datewidget,
	       	separator, s == 1 and mysystray or nil,
		separator, kbdwidget,batwidget,baticon,
        	separator, volwidget,  volbar.widget, volicon,
		--separator, tzswidget,mycore1.widget,mycore2.widget,mycore3.widget,mycore4.widget,mycairograph.widget, cpuicon,
		--separator, memwidget.widget, memicon,
		--separator, hddtempwidget,hddtempicon,
		--separator, my_fs.widget,fs_home,my_fs_root.widget,fs_root,fsicon,
		separator, mygmail,mygmailicon,
		--separator, dnicon,netwidget,my_net.widget,upicon,
		--separator, musicwidget.widget,
        	separator, layout = awful.widget.layout.horizontal.rightleft
	}

	mywibox2[s].widgets = {
		separator, my_fs.widget,fs_home,my_fs_root.widget,fs_root,fsicon,
		separator, tzswidget,mycore1.widget,mycore2.widget,mycore3.widget,mycore4.widget,
		separator, mycairograph.widget, cpuicon,
		separator, hddtempwidget,hddtempicon,
		separator, memwidget.widget, memicon,
    	        separator, dnicon,netwidget,my_net.widget,upicon,
 		separator, musicwidget.widget,
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
   awful.key({ }, "XF86AudioNext",  musicwidget:command_next_track()),
   awful.key({ }, "XF86AudioPrev",  musicwidget:command_prev_track()), 
   awful.key({ }, "XF86AudioStop",  musicwidget:command_stop()), 
   awful.key({ }, "XF86AudioPlay",  musicwidget:command_playpause()),
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
    awful.key({ modkey,           }, "n",      function (c) c.minimized = true    	     end),
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
		maximized_vertical   = false,
		maximized_horizontal = false,
                buttons = clientbuttons }
	},
		     
    { rule = { class = "MPlayer"  		}, properties = { floating = false , tag = tags[1][9]	} },
    { rule = { class = "feh" 			}, properties = { floating = true 			} },
    { rule = { class = "gimp" 	  		}, properties = { floating = false 			} },
    { rule = { class = "Chromium-browser"   	}, properties = { tag = tags[1][2],floating=false 	} },
    { rule = { class = "Sonata"   		}, properties = { floating = true 			} },
    { rule = { class = "Wicd-client.py"		}, properties = { floating = true 			} },
    { rule = { class = "Vacuum"			}, properties = { tag = tags[1][1] 			} },
    { rule = { class = "Dolphin" 		}, properties = { tag = tags[1][6]			} },
    { rule = { class = "Keepassx"		}, properties = { floating = true			} },
    { rule = { class = "Deadbeef"		}, properties = { floating = true 			} },
    { rule = { class = "Rednotebook"		}, properties = { floating = true 			} },
    { rule = { class = "Xarchiver"		}, properties = { floating = true			} },
    { rule = { class = "Znotes"			}, properties = { floating = true 			} },
    { rule = { class = "Qtcreator"		}, properties = { tag = tags[1][3] 			} },
    { rule = { class = "Plugin%-container" 	}, properties = { floating = true 			} },
    { rule = { class = "Kate" 			}, properties = { floating = false 			} },
    { rule = { class = "VCLSalFrame"		}, properties = { floating = false, tag = tags[1][4]	} }

}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- dd a titlebar
    if awful.client.floating.get(c) then
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
