-- name: mQuake TAS run
-- incompatible:
local TOOLS = _G.TAS

hook_event(HOOK_ON_LEVEL_INIT, function()
	-- prevent this from loading inputs multiple times
	if (final ~= nil) then return end
	final = true
	
	-- first param is offset from last frame (if 0 it will run on the same frame as the last input / very start of the run if its the first input)
	-- then, it's the button mask, yaw speed, pitch speed, joystick x and finally joystick y
	TOOLS.AddInputs(0,A_BUTTON,-60,-10,-1,0)
	TOOLS.AddInputs(60,0,0,10,0,0)
	TOOLS.AddInputs(30,Z_TRIG,0,10,0,0)
	TOOLS.AddInputs(30,0,0,0,0,0)
	TOOLS.Play()
end)