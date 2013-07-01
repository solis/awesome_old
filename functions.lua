---- Functions

-- {{{ Markup functions
function setBg(color, text)
    return '<bg color="'..color..'" />'..text
end

function setFg(color, text)
    return '<span color="'..color..'">'..text..'</span>'
end

function setBgFg(bgcolor, fgcolor, text)
    return '<bg color="'..bgcolor..'" /><span color="'..fgcolor..'">'..text..'</span>'
end

function setFont(font, text)
    return '<span font_desc="'..font..'">'..text..'</span>'
end
-- }}}

---- Widget functions
-- {{{ Clock
function clockInfo(dateformat, timeformat)
    local date = os.date(dateformat)
    local time = os.date(timeformat)
    
    clockwidget.text = " "..date.." "..setFg(beautiful.fg_focus, time).." "
end
-- }}}

-- {{{ Calendar
local calendar = nil
local offset = 0

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end

function add_calendar(inc_offset)
    local save_offset = offset
    remove_calendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text     = string.format('<span font_desc="%s">%s</span>', "terminus", setFg(beautiful.fg_focus, os.date("%a, %d %B %Y")) .. "\n" .. setFg(beautiful.fg_widg, cal)),
        timeout  = 0, hover_timeout = 0.5,
        width    = 150,
        position = "bottom_right",
        bg       = beautiful.bg_focus
    })
end
-- }}}


-- {{{ Wifi signal strength
function wifiInfo(adapter)

	local status = setFg("#ff6565",'off')
	local wifiStrength = ''

	-- check if wireless is turned on
    local sysfile = io.open("/sys/class/net/"..adapter.."/operstate")
    if sysfile == nil then
		status = 'error'
    end

    local operstate = 'down'
    -- check if wireless is up
    if status ~= 'error' then
	-- local operstate = sysfile:read()
	operstate = sysfile:read()
	sysfile:close()
    end
    
    
    if operstate == 'up' then
		status = 'on'
    end

	local essid = ' '
	if status == 'on' then
    	-- determine ESSID by calling /sbin/iwconfig
	local iwconfig = io.popen('/sbin/iwconfig '..adapter)
    	local line = iwconfig:read()
    	local essid_start = line:find("ESSID:")
    	local essid_end   = -1
    	essid = " "..line:sub(essid_start + 6, essid_end)
    	--essid = " "
	
		local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
		wifiStrength = f:read()
		f:close()

		if wifiStrength == "1" then
			wifiStrength = "("..setFg("#ff6565", wifiStrength.."/100) ")
			naughty.notify({ title      = "Wifi Warning"
                       , text       = "Wireless Network is Down! ("..wifiStrength.." connectivity)"
                       , timeout    = 5
                       , position   = "top_right"
                       , fg         = beautiful.fg_focus
                       , bg         = beautiful.bg_focus
                       })
		else
			wifiStrength = " ("..wifiStrength.."/100) "
		end
	end
    
    wifiwidget.text = setFg(beautiful.fg_focus, "WiFi: ")..status..essid..wifiStrength
end
-- }}}


-- {{{ Battery (BAT0)
function batteryInfo(adapter)

    local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")    
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local cur = fcur:read()
    fcur:close()
    local cap = fcap:read()
    fcap:close()
    local sta = fsta:read()
    fsta:close()
    
    local battery = math.floor(cur * 100 / cap)
    
    if sta:match("Charging") then
        dir = "^"
        battery = "A/C ("..battery..")"
    elseif sta:match("Discharging") then
        dir = "v"
        if tonumber(battery) >= 25 and tonumber(battery) <= 50 then
            battery = setFg("#e6d51d", battery)
        elseif tonumber(battery) < 25 then
            if tonumber(battery) <= 10 then
                naughty.notify({ title      = "Battery Warning"
                               , text       = "Battery low! "..battery.."% left!"
                               , timeout    = 5
                               , position   = "top_right"
                               , fg         = beautiful.fg_focus
                               , bg         = beautiful.bg_focus
                               })
            end
            battery = setFg("#ff6565", battery)
        else
            battery = battery.."% "
        end
    else
        dir = "="
        battery = "A/C "
    end
    
    --batterywidget.text = setFg(beautiful.fg_focus, "Battery: ")..dir..battery.."% "
    batterywidget.text = setFg(beautiful.fg_focus, "Battery: ")..dir..battery
end
-- }}}



-- {{{ Memory
function memInfo()
    local f = io.open("/proc/meminfo")

    for line in f:lines() do
        if line:match("^MemTotal.*") then
            memTotal = math.floor(tonumber(line:match("(%d+)")) / 1024)
        elseif line:match("^MemFree.*") then
            memFree = math.floor(tonumber(line:match("(%d+)")) / 1024)
        elseif line:match("^Buffers.*") then
            memBuffers = math.floor(tonumber(line:match("(%d+)")) / 1024)
        elseif line:match("^Cached.*") then
            memCached = math.floor(tonumber(line:match("(%d+)")) / 1024)
        end
    end
    f:close()

    memFree = memFree + memBuffers + memCached
    ---memInUse = memTotal - memFree
    memUsePct = math.floor(memInUse / memTotal * 100)

    memwidget.text = setFg(beautiful.fg_focus, "Memory: ")..memUsePct.."% ("..memInUse.."M) "
end
-- }}}



-- {{{ CPU Usage, CPU & GPU Temps
function cputemp(core)
	local command = 'acpi -t | grep Thermal\\ 1: | awk \'{print $4}\''
	local cpu = io.popen(command):read("*all")

	if (cpu == nil) then
		return ''
	end
   
	return tonumber(cpu)
end


function sysInfo(widget, args)
    --local core1 = setFg(beautiful.fg_focus, "CPU1: ")..args[2] .."% ("..cputemp(0).."c)"
    --local core2 = setFg(beautiful.fg_focus, "CPU2: ")..args[3] .."% ("..cputemp(1).."c)"
    local core1 = setFg(beautiful.fg_focus, "CPU: ")..args[2] .."%"
    --local core2 = setFg(beautiful.fg_focus, "CPU2: ")..args[3] .."%"
    local sysinfo = core1 --.."  "..core2.." "
    return sysinfo
end
-- }}}

-- {{{ Volume

function volume (mode, widget)
 	if mode == "up" then
 		awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 10%+")
		wicked.update(widget)
 	elseif mode == "down" then
 		awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 10%-")
		wicked.update(widget)
	else 

        local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")
         
     	local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
 
        status = string.match(status, "%[(o[^%]]*)%]")
 
        local color = "#FF0000"
        if string.find(status, "on", 1, true) then
              color = "#00FF00"
        end
        status = ""
        for i = 1, math.floor(volume / 20) do
             status = status .. "|"
        end
        for i = math.floor(volume / 20) + 1, 5 do
             status = status .. "-"
        end
        status = "-[" ..status .. "]+"

        return setFg(beautiful.fg_focus, "Volume: ")..status.." "
	end
end
-- }}}

-- {{{ Bluetooth
function btCheck ()
	local status = ""
	local fd = io.open("/sys/class/bluetooth/hci0")
	if fd == nil then
		status = setFg("#ff6565", "off")
	else
		status = "on"
		fd:close()
	end
	return setFg(beautiful.fg_focus, "Bluetooth: ")..status.." "
end
-- }}}

-- {{{ WebCam
function camCheck ()
	local status = ""
	local fd = io.open("/sys/class/video4linux/video0/name")
	if fd == nil then
		status = setFg("#ff6565", "off")
	else
		status = "on"
		fd:close()
	end
	return setFg(beautiful.fg_focus, "Camera: ")..status.." "
end
-- }}}

