--local home   = os.getenv("HOME")
--local bin    = home .. "/.config/awesome/bin/"

run_once("udisks-glue")
os.execute("setxkbmap -layout 'us,ru' -variant 'winkeys' -option 'grp:caps_toggle,grp_led:caps,compose:ralt' &")
run_once("kbdd")
run_once(os.getenv("HOME") .. "/.dropbox-dist/dropboxd")
run_once("xscreensaver", "-no-splash")
run_once("nm-applet")
run_once("skype")
--run_once("xautolock -time 10 -locker 'sh " .. bin .. "lock.sh' &")
run_once("wmname LG3D")
run_once("xcompmgr -cF &")
