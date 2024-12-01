-- name: mQuake - TAS Tools
-- incompatible:

local gRecordedInputs = {}
local gLocalData = {
	vel = {x=0,y=0,z=0},
	action = 0,
	actionState = 0,
	actionTimer = 0,
	actionArg = 0,
	wallkickLimiter = 0
}

local gFrameAdvanceEnabled = false
local gFrameAdvanceCount = 0
local gFrameNum = 0
local gActiveFrameNum = 0
local gLastFrameInputs = 0
local gCurrentFrameInputs = 0
local gPlaybackActive = false
local gJoystickX = 0
local gJoystickY = 0
local gJoystickMag = 0
local gYawSpeed = 0
local gPitchSpeed = 0
local TYPE_INPUTS = 0
local TYPE_RNG = 1
local TYPE_POSITION = 2
local TYPE_VEL = 3
local TYPE_WARP = 4

local floor = math.floor
local sqrt = math.sqrt

local function ClearTable(tbl)
	for i, v in ipairs(tbl) do tbl[i] = nil end
end

local function ClearTasInputs()
	for i, v in ipairs(tbl) do 
		for i2, v2 in ipairs(gRecordedInputs[i]) do 
			ClearTable(gRecordedInputs[i][i2])
			gRecordedInputs[i][i2] = nil
		end
		ClearTable(gRecordedInputs[i])
		gRecordedInputs[i] = nil
	end
end

local function AddTasInput(timeoffset,buttonflags,yawspeed,pitchspeed,joyX,joyY)
	gActiveFrameNum = gActiveFrameNum + timeoffset
	if (gRecordedInputs[gActiveFrameNum] == nil) then gRecordedInputs[gActiveFrameNum] = {} end
	local inpIdx = #(gRecordedInputs[gActiveFrameNum])
	
	gRecordedInputs[gActiveFrameNum][inpIdx] = {
		t = TYPE_INPUTS,
		buttons = buttonflags,
		yawspd = yawspeed,
		pitchspd = pitchspeed,
		x = joyX,
		y = joyY
	}
end

local function AddTasWarp(timeoffset,level,act,area)
	gActiveFrameNum = gActiveFrameNum + timeoffset
	if (gRecordedInputs[gActiveFrameNum] == nil) then gRecordedInputs[gActiveFrameNum] = {} end
	local inpIdx = #(gRecordedInputs[gActiveFrameNum])
	
	gRecordedInputs[gActiveFrameNum][inpIdx] = {
		t = TYPE_WARP,
		l = level, ac = act, ar = area
	}
end

local function AddTasRNG(timeoffset,ramt)
	gActiveFrameNum = gActiveFrameNum + timeoffset
	if (gRecordedInputs[gActiveFrameNum] == nil) then gRecordedInputs[gActiveFrameNum] = {} end
	local inpIdx = #(gRecordedInputs[gActiveFrameNum])
	
	gRecordedInputs[gActiveFrameNum][inpIdx] = {
		t = TYPE_RNG,
		a = ramt
	}
end
local function ProcessTASFrame()
	local m = gMarioStates[0]
	gLastFrameInputs = gCurrentFrameInputs

	if (gRecordedInputs[gFrameNum] ~= nil) then
		local i = 0
		while (gRecordedInputs[gFrameNum][i] ~= nil) do
			local frameData = gRecordedInputs[gFrameNum][i]
			if (frameData.t == TYPE_WARP) then
				warp_to_level(frameData.l,frameData.ar,frameData.ac)
				
			elseif (frameData.t == TYPE_RNG) then
				while (random_u16() ~= 0) do end
				if (frameData.a > 0) then 
					for i=0, frameData.a do random_u16() end
				end
			elseif (frameData.t == TYPE_INPUTS) then
				gCurrentFrameInputs = frameData.buttons
				gJoystickX = clampf(floor(frameData.x*127),-127,127)
				gJoystickY = clampf(floor(frameData.y*127),-127,127)
				gJoystickMag = floor(sqrt(gJoystickX ^ 2 + gJoystickY ^ 2))
				if (gJoystickMag > 127) then 
					gJoystickX = (gJoystickX / gJoystickMag) * 127
					gJoystickY = (gJoystickY / gJoystickMag) * 127
					gJoystickMag = 127
				end
				gYawSpeed = -frameData.yawspd
				gPitchSpeed = -frameData.pitchspd
			elseif (frameData.t == TYPE_POSITION) then
				m.pos.x = frameData.x
				m.pos.y = frameData.y
				m.pos.z = frameData.z
			elseif (frameData.t == TYPE_VEL) then
				m.vel.x = frameData.x
				m.vel.y = frameData.y
				m.vel.z = frameData.z
			end
			i = i + 1
		end
	end
	gFrameNum = gFrameNum + 1
end

local function AddTasInputPosition(timeoffset,x,y,z)
	gActiveFrameNum = gActiveFrameNum + timeoffset
	if (gRecordedInputs[gActiveFrameNum] == nil) then gRecordedInputs[gActiveFrameNum] = {} end
	local inpIdx = #gRecordedInputs[gActiveFrameNum]
	
	gRecordedInputs[gActiveFrameNum][inpIdx] = {
		t = TYPE_POSITION,
		x = x,
		y = y,
		z = z
	}
end
local function AddTasInputVelocity(timeoffset,x,y,z)
	gActiveFrameNum = gActiveFrameNum + timeoffset
	if (gRecordedInputs[gActiveFrameNum] == nil) then gRecordedInputs[gActiveFrameNum] = {} end
	local inpIdx = #gRecordedInputs[gActiveFrameNum]
	
	gRecordedInputs[gActiveFrameNum][inpIdx] = {
		t = TYPE_VEL,
		x = x,
		y = y,
		z = z
	}
end

local function PlaybackTas() 
	gFrameNum = 0
	gFrameAdvanceCount = gActiveFrameNum+1
	gPlaybackActive = true
	gFirstPersonCamera.forcePitch = true
	gFirstPersonCamera.forceYaw = true
end

hook_chat_command("frame", "Frame Advance", function(msg)
	if (msg == "on") then
		djui_chat_message_create("Frame Advance Enabled")
		gFrameAdvanceEnabled = true
		gFrameAdvanceCount = 0
	elseif (msg == "off") then
		djui_chat_message_create("Frame Advance Disabled")
		gFrameAdvanceEnabled = false
		gFrameAdvanceCount = 0
	else
		gFrameAdvanceCount = tonumber(msg)
	end

	return true
end)

hook_event(HOOK_BEFORE_PHYS_STEP, function(m,i)
	if (gFrameAdvanceCount < 1 and gFrameAdvanceCount > -1 and gFrameAdvanceEnabled) then return -1 end
	return nil
end)

hook_event(HOOK_ALLOW_INTERACT, function(m,o,i)
	if (gFrameAdvanceCount < 1 and gFrameAdvanceCount > -1 and gFrameAdvanceEnabled) then return false end
	return nil
end)

hook_event(HOOK_BEFORE_MARIO_UPDATE, function(m)
	if (gFrameAdvanceCount < 1 or not gPlaybackActive) then 
		return nil
	end
	
	gControllers[0].buttonDown = gCurrentFrameInputs
	gControllers[0].buttonPressed = gCurrentFrameInputs & ~gLastFrameInputs
	gControllers[0].buttonReleased = ~gCurrentFrameInputs & gLastFrameInputs
	gControllers[0].rawStickX = gJoystickX
	gControllers[0].rawStickY = gJoystickY
	gControllers[0].stickMag = gJoystickMag
	gFirstPersonCamera.yaw = gFirstPersonCamera.yaw + gYawSpeed
	gFirstPersonCamera.pitch = gFirstPersonCamera.pitch + gPitchSpeed
end)

hook_event(HOOK_UPDATE, function()
	local m = gMarioStates[0]
	if (gFrameAdvanceCount > 0 or not gFrameAdvanceEnabled) then 
		ProcessTASFrame()
		gFrameAdvanceCount = gFrameAdvanceCount - 1
		vec3f_copy(gLocalData.vel,m.vel)
		gLocalData.action = m.action
		gLocalData.actionState = m.actionState
		gLocalData.actionArg = m.actionArg
		gLocalData.actionTimer = m.actionTimer
		gLocalData.wallkickLimiter = _G.mQuake_API.cl.get.wallkick()
		
		if (gFrameAdvanceCount < 1 and gPlaybackActive) then
			djui_chat_message_create("PLAYBACK ENDED.")
			gFirstPersonCamera.forcePitch = false
			gFirstPersonCamera.forceYaw = false
			gPlaybackActive = false
		end
	elseif (gFrameAdvanceEnabled) then 
		vec3f_copy(m.vel,gLocalData.vel)
		m.action = gLocalData.action
		m.actionState = gLocalData.actionState
		m.actionArg = gLocalData.actionArg
		m.actionTimer = gLocalData.actionTimer
		_G.mQuake_API.cl.set.wallkick(gLocalData.wallkickLimiter)
	end
end)

local tasData = {
	Clear = ClearTasInputs,
	AddInputs = AddTasInput,
	AddRNG = AddTasRNG,
	AddWarp = AddTasWarp,
	AddPos = AddTasInputPosition,
	AddVel = AddTasInputVelocity,
	Play = PlaybackTas
}

_G.TAS = tasData