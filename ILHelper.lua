-- name: IL Run Helper
-- description: On-screen timer for Individual Level attempts\nby Mr. Mary\n\nType "/stars" in chat to set on how many stars collected do we split\n\nPress DPad Down to restart level

local starCount = 0
local starThreshold = 1
local currentTime = 0

local function test_text(time_string)
    -- set text and scale
    local text = time_string
    local scale = 1.5

    -- render to native screen space, with the MENU font
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text) * scale

    -- get height of screen and text
    local screenHeight = djui_hud_get_screen_height()
    local height = 64 * scale

    -- set location
    local x = 5
    local y = (screenHeight / 2) + (height / 2)

    -- set color and render
    djui_hud_set_color(0, 0, 0, 95)
	djui_hud_render_rect(x, y, width + 10, height / 2)
	djui_hud_set_color(231, 229, 50, 255)
    djui_hud_print_text(text, x, y, scale)
end

function formatTime(currentTime)
    local totalSeconds = currentTime / 30
    local minutes = math.floor(totalSeconds / 60)
    local seconds = math.floor(totalSeconds % 60)
    local milliseconds = math.floor((totalSeconds % 1) * 1000)
    if minutes < 10 then
        return string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
    else
        return string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
    end
end


local function hud_render()
	if get_network_area_timer() == 0 then
		starCount = 0
	end
	if starCount ~= starThreshold then
		currentTime = get_network_area_timer()
		test_text(formatTime(currentTime))
	else
		test_text(formatTime(currentTime) .. " (" .. tostring(currentTime) .. " ticks)")
	end
	
end

local function starAction(m, o, i, b)
	if i == INTERACT_STAR_OR_KEY then
		starCount = starCount + 1
		if starCount == starThreshold then
			currentTime = get_network_area_timer()
		end
	end
end

local function updateStarThreshold(msg)
	if msg == "" then
		djui_chat_message_create("Star threshold is set to " .. tostring(starThreshold))
	elseif (type(tonumber(msg))) == nil then
		djui_chat_message_create("Invalid parameter")
	elseif msg ~= nil then
		if tonumber(msg) == nil then
			djui_chat_message_create("Invalid parameter")
		elseif tonumber(msg) <= 0 then
			djui_chat_message_create("Invalid parameter")
		else
			starThreshold = tonumber(msg)
			djui_chat_message_create("Split threshold changed to " .. tostring(starThreshold))
		end
	end
	--print(starThreshold)
	return true
end


hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_INTERACT, starAction)
hook_chat_command("stars", "[number] of stars collected in level to split on (default: 1)", updateStarThreshold)