local awful = require("awful")
function run_once(prg, args)
	if not prg then
		do return nil end
	end
	if not args then
		args=""
	end
	awful.util.spawn_with_shell('pgrep -f -u $USER -x ' .. prg .. ' || (' .. prg .. ' ' .. args ..'& )')
end
