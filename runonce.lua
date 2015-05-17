local awful = require("awful")
exec   	= awful.util.spawn
sexec  	= awful.util.spawn_with_shell
function run_once(prg, args)
	if not prg then
		do return nil end
	end
	if not args then
		args=""
	end
	awful.util.spawn_with_shell('/bin/sh -c "pgrep -f -u $USER -x ' .. prg .. ' || (' .. prg .. ' ' .. args ..'& )"')
end
