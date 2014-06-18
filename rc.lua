-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
local vicious = require("vicious")
require("helpers")
local calendar = require("calendar")
-- awful.widget.gmail = require('awful.widget.gmail')

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

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

awful.util.spawn_with_shell("wmname LG3D")
run_once("urxvtd")
-- run_once("unclutter")
run_once("kbdd")
run_once("skypetab-ng")
run_once("workrave")
-- run_once("compton")
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
config_dir = ("/home/apavlov/.config/awesome/")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/powerarrow/theme.lua")

--{{ Naughty theme
naughty.config.presets.font         = beautiful.notify_font
naughty.config.presets.fg           = beautiful.notify_fg
naughty.config.presets.bg           = beautiful.notify_bg
naughty.config.presets.normal.border_color = beautiful.notify_border
naughty.config.presets.normal.opacity      = 0.7
naughty.config.presets.low.opacity         = 0.7
naughty.config.presets.critical.opacity    = 0.7
--}}

-- This is used later as the default terminal and editor to run.
terminal      = 'urxvtc'
editor        = os.getenv("EDITOR") or "vim"
editor_cmd    = terminal .. " -e " .. editor

-- user defined
browser    = "google-chrome-stable"
browser2   = "firefox"
gui_editor = "subl3"
graphics   = "gimp"

local sys = {}
function sys.lock()
    awful.util.spawn('slimlock')
end

-- {{{ Function definition

function show_window_info(c)
  local geom = c:geometry()

  local t = ""
  if c.class    then t = t .. setFg("green", "<b>Class</b>: ")    .. c.class    .. "\n" end
  if c.instance then t = t .. setFg("green", "<b>Instance</b>: ") .. c.instance .. "\n" end
  if c.role     then t = t .. setFg("green", "<b>Role</b>: ")     .. c.role     .. "\n" end
  if c.name     then t = t .. setFg("green", "<b>Name</b>: ")     .. c.name     .. "\n" end
  if c.type     then t = t .. setFg("green", "<b>Type</b>: ")     .. c.type     .. "\n" end
  if geom.width and geom.height and geom.x and geom.y then
    t = t .. setFg("green", "<b>Dimensions</b>: ") .. "<b>x</b>:" .. geom.x .. "<b> y</b>:" .. geom.y .. "<b> w</b>:" .. geom.width .. "<b> h</b>:" .. geom.height
  end

  naughty.notify({
    text = t,
    timeout = 30
  })
end

-- }}}

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
 tags = {
   names  = { "α", "β", "γ", "δ", "φ", "χ", "ψ", "ω" },
   layout = { layouts[3], layouts[1], layouts[1], layouts[2], layouts[1], layouts[2],
              layouts[4], layouts[2]
 }}
 for s = 1, screen.count() do
     tags[s] = awful.tag(tags.names, s, tags.layout)
 end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
-- myawesomemenu = {
--    { "manual", terminal .. " -e man awesome" },
--    { "edit config", editor_cmd .. " " .. awesome.conffile },
--    { "restart", awesome.restart },
--    { "quit", awesome.quit }
-- }

-- mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--                                     { "open terminal", terminal }
--                                   }
--                         })

-- mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
--                                      menu = mymainmenu })
-- }}}

-- {{{ Wibox
 -- -- {{{ Keyboard widget
--  -- Keyboard map indicator and changer
--     kbdcfg = {}
--     kbdcfg.layout = { { "us", "" }, { "ru", "" } }
--     kbdcfg.current = 1  -- us is our default layout
--     kbdcfg.widget = widget({ type = "textbox", align = "right" })
--     kbdcfg.widget.text = kbdcfg.layout[kbdcfg.current][1]
--     kbdcfg.switch = function ()
--        kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
--        local t = kbdcfg.layout[kbdcfg.current]
--        kbdcfg.widget.text = t[1]
--     end

--     -- Mouse bindings
--     kbdcfg.widget:buttons(awful.util.table.join(
--         awful.button({ }, 1, function () kbdcfg.switch() end)
--     ))
-- -- }}}

-- --{{---| Mail widget |------------------------------------------------------------------------------
-- gmail = widget({ type = "textbox" })
-- mailicon = widget ({type = "imagebox" })
-- mailicon.image = image(beautiful.widget_mail)


-- vicious.register(gmail, vicious.widgets.gmail,
--                 function (widget, args)
--                     return args["{count}"]
--                 end,  120)
--                 --the '120' here means check every 2 minutes.

-- mailicon:buttons(awful.util.table.join(awful.button({ }, 1,
-- function () awful.util.spawn("google-chrome www.gmail.com") end)))

-- gmailwidget = awful.widget.gmail.new()

    --{{---| MEM widget |-------------------------------------------------------------------------------

    memwidget = widget({ type = "textbox" })
    vicious.register(memwidget, vicious.widgets.mem, '<span background="#4B3B51" font="Terminus 12"> <span font="Terminus 9" color="#EEEEEE" background="#4B3B51">$2MB </span></span>', 13)
    memicon = widget ({type = "imagebox" })
    memicon.image = image(beautiful.widget_mem)

    --{{---| CPU / sensors widget |---------------------------------------------------------------------

    cpuwidget = widget({ type = "textbox" })
    vicious.register(cpuwidget, vicious.widgets.cpu,
    '<span background="#4B696D" font="Terminus 12"> <span font="Terminus 9" color="#DDDDDD">$2% <span color="#888888">·</span> $3% </span></span>', 3)
    cpuicon = widget ({type = "imagebox" })
    cpuicon.image = image(beautiful.widget_cpu)

    --{{---| Net widget |-------------------------------------------------------------------------------

    netwidget = widget({ type = "textbox" })
    vicious.register(netwidget,
    vicious.widgets.net,
    '<span background="#D0785D" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF">${enp2s0 down_kb} ↓↑ ${enp2s0 up_kb}</span> </span>', 3)
    neticon = widget ({type = "imagebox" })
    neticon.image = image(beautiful.widget_net)
    netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))

    -- {{{ Date and time
    time_format = "%T"
    -- Initialize widget
    timewidget = widget({ type = "textbox" })
    -- Register widget
    vicious.register(timewidget, vicious.widgets.date, '<span background="#C2C2A4" font="Terminus 12"> <span font="Terminus 10" color="#FFFFFF">' .. time_format .. '</span> </span>', 1)

    date_format = "%a, %d %b %Y"

    datewidget = widget({ type = "textbox" })

    vicious.register(datewidget, vicious.widgets.date, '<span background="#92B0A0" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF">' .. date_format .. '</span> </span>', 1)

    calendar.addCalendarToWidget(datewidget, setFg("green", "<b>%s</b>"))
    -- }}}

    spr = widget({ type = "textbox" })
    spr.text = ' '
    sprd = widget({ type = "textbox" })
    sprd.text = '<span background="#313131" font="Terminus 12"> </span>'
    spr3f = widget({ type = "textbox" })
    spr3f.text = '<span background="#777e76" font="Terminus 12"> </span>'
    arr1 = widget ({type = "imagebox" })
    arr1.image = image(beautiful.arr1)
    arr2 = widget ({type = "imagebox" })
    arr2.image = image(beautiful.arr2)
    arr3 = widget ({type = "imagebox" })
    arr3.image = image(beautiful.arr3)
    arr4 = widget ({type = "imagebox" })
    arr4.image = image(beautiful.arr4)
    arr5 = widget ({type = "imagebox" })
    arr5.image = image(beautiful.arr5)
    arr6 = widget ({type = "imagebox" })
    arr6.image = image(beautiful.arr6)
    arr7 = widget ({type = "imagebox" })
    arr7.image = image(beautiful.arr7)
    arr8 = widget ({type = "imagebox" })
    arr8.image = image(beautiful.arr8)
    arr9 = widget ({type = "imagebox" })
    arr9.image = image(beautiful.arr9)
    arr0 = widget ({type = "imagebox" })
    arr0.image = image(beautiful.arr0)

-- Create a wibox for each screen and add it
systray = widget({ type = "systray" })
wibox = {}
promptbox = {}
layoutbox = {}
taglist = {}
taglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
tasklist = {}
tasklist.buttons = awful.util.table.join(
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
for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
    tasklist[s] = awful.widget.tasklist(function(c)
                                              args = {}
                                              args.font = "Terminus 8"
                                              return awful.widget.tasklist.label.currenttags(c, s, args)
                                          end, tasklist.buttons)

    -- Create the wibox
    wibox[s] = awful.wibox({ position = "top", screen = s, height = "16" })
    -- Add widgets to the wibox - order matters
    wibox[s].widgets = {
   { taglist[s], promptbox[s], layout = awful.widget.layout.horizontal.leftright },
     layoutbox[s],
     arr1,
     spr3f,
     arr2,
     timewidget,
     arr3,
     datewidget,
     arr4,
     netwidget,
     neticon,
     arr5,
     memwidget,
     memicon,
     arr6,
     cpuwidget,
     cpuicon,
     arr7,
    -- arr8,
     s == 1 and systray, spr or nil, tasklist[s],
     layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    -- awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

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
    -- awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

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

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "l", sys.lock ),
    awful.key({ modkey, "Control" }, "p", function() awful.util.spawn("gyazo") end),

        -- User programs
    awful.key({ modkey         }, "b", function () awful.util.spawn(browser) end),
    awful.key({ modkey, altkey }, "i", function () awful.util.spawn(browser2) end),
    awful.key({ modkey         }, "e", function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey         }, "g", function () awful.util.spawn(graphics) end),
    awful.key({ modkey         }, "d", function () awful.util.spawn('intellij-idea-ultimate-edition') end),
    awful.key({ modkey         }, "f", function () awful.util.spawn('doublecmd') end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey, "Control" }, "v", function ()
         wibox[mouse.screen].visible = not wibox[mouse.screen].visible
    end),

    -- Prompt
    awful.key({ modkey },            "r",     function () promptbox[mouse.screen]:run() end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey            }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "i", show_window_info),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
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
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false }
    },
    {
        rule = { class = "Dialog" },
        properties = { floating = true }
    },
    {
        rule = { class = "dialog" },
        properties = { floating = true }
    },
    {
        rule = { type = "dialog" },
        properties = { floating = true }
    },
    {
        rule = { class = "Download" },
        properties = { floating = true }
    },
    {
        rule = { class = "webmenu" },
        properties = { floating = true }
    },
    {
        rule = { class = "thunar", name = "File Operation Progress" },
        properties = { floating = true }
    },
    {
        rule = { class = "Google-chrome" },
        properties = { tag = tags[1][2], switchtotag = true, floating = false}
    },
    {
        rule = { class = "Firefox" },
        properties = { tag = tags[1][2], switchtotag = true, floating = false}
    },
    {
        rule = { class = "Firefox", role = "Preferences" },
        properties = { tag = tags[1][2], floating = true}
    },
    {
        rule = { class = "Firefox", type = "dialog" },
        properties = { tag = tags[1][2], floating = true}
    },
    {
        rule = { class = "Umplayer" },
        properties = { tag = tags[1][7] }
    },
    {
        rule = { class = "Deadbeef" },
        properties = { tag = tags[1][7], floating = false }
    },
    {
        rule = { class = "Gedit" },
        properties = { floating = true }
    },
    {
        rule = { class = "jetbrains-idea" },
        properties = { tag = tags[1][3], switchtotag = true }
    },
    {
        rule = { class = "Doublecmd" },
        properties = { tag = tags[1][5], floating = false },
    },
    {
        rule = { class = "Doublecmd", type = "dialog" },
        properties = { tag = tags[1][5], floating = true },
    },
    {
        rule = { class = "Doublecmd", name = "Options" },
        properties = { tag = tags[1][5], floating = true },
    },
        {
        rule = { class = "Doublecmd", name = "Find files" },
        properties = { tag = tags[1][5], floating = true },
    },
    {
        rule = { class = "Subl3" },
        properties = { tag = tags[1][4], switchtotag = true, switchtotag = true, floating = false}
    },
--    {
--        rule = { class = "Gimp" },
--        properties = { floating = true }
--    },
    {
        rule = { class = "SkypeTab"},
        properties = { tag = tags[1][6], floating = false},
        -- callback = function(c)
        --     local w = screen[c.screen].workarea.width
        --     local h = screen[c.screen].workarea.height
        --     c:geometry({ width = 0.15 * w, height = h })
        --     c.x = 0
        --     c.y = 0
        -- end
    },
    -- {
    --     rule = { class = "Skype", role = "ConversationsWindow" },
    --     properties = { floating = false },
    --     callback = function(c)
    --         local w = screen[c.screen].workarea.width
    --         local h = screen[c.screen].workarea.height
    --         awful.client.setslave(c)
    --         c:struts({ left = 0.15 * w })
    --     end
    -- },
    -- {
    --     rule = { class = "Skype", role = "CallWindow" },
    --     properties = { floating = false },
    --     callback = function(c)
    --         local w = screen[c.screen].workarea.width
    --         local h = screen[c.screen].workarea.height
    --         c:struts({ left = 0.15 * w })
    --     end
    -- },
    {
        rule = { class = "Skype", name = "Options" },
        properties = { floating = true },
        callback = function(c)
            local w = screen[c.screen].workarea.width
            local h = screen[c.screen].workarea.height
            c:geometry({ width = 0.5 * w, height = 0.6 * h })
            c.x = 0
            c.y = 0
        end
    },
    {
        rule = { class = "Pidgin", role = "buddy_list"},
        properties = { tag = tags[1][6] }
    },
    {
        rule = { class = "Pidgin", role = "conversation"},
        properties = { tag = tags[1][6]}, callback = awful.client.setslave
    },
    {
        rule = { class = "URxvt" },
        properties = { opacity = 0.99 }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

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
        awful.client.setslave(c)

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


--{{--| Autostart |---------------------------------------------------------------------------------

-- require_safe('autorun')