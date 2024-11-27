-- name: RTA Timer
-- description: Simple tick-based timer for RTA runs\nDo "/rta_timer reset" to reset timer\n(based on Mr. Mary's IL Helper)

local victory = 0
local victoryTime = 0
local startGlobalTime = 0

local function render_time_string(time_string)
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
    local y = (screenHeight / 2) + (height / 2) + 64

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
    if victory == 1 then
        render_time_string(formatTime(victoryTime))
    else
	    render_time_string(formatTime(get_global_timer()-startGlobalTime))
    end
end

local function handle_sequence(player, seqID)
    if (seqID == SEQ_EVENT_CUTSCENE_VICTORY) then
        victory = 1
        victoryTime = get_global_timer()-startGlobalTime
    end
end

function handle_chat(msg)
    if(msg == "reset") then
        victory = 0
        startGlobalTime = get_global_timer()
        return true
    end
end

function handle_connected(m)
    startGlobalTime = get_global_timer()
end

hook_chat_command('rta_timer', "[reset]", handle_chat)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_SEQ_LOAD, handle_sequence)
hook_event(HOOK_ON_PLAYER_CONNECTED, handle_connected)