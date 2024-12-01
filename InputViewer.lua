-- name: mQuake input viewer
-- description: Input viewer for mQuake

djui_hud_set_resolution(RESOLUTION_DJUI)

local buttonStates = {
    u = {false, 1, 0, ""},
    d = {false, 1, 1, ""},
    l = {false, 0, 1, ""},
    r = {false, 2, 1, ""},
    a = {false, -0.5, 2.5, "A"},
    b = {false, 0.5, 2.5, "B"},
    z = {false, 1.5, 2.5, "Z"},
    dpad_d = {false, 2.5, 2.5, "E"}
}

local screenWidth = djui_hud_get_screen_width()
local screenHeight = djui_hud_get_screen_height()
local scale = screenWidth * 0.0022

local function updateButtons()
    buttonStates.r[1] = gMarioStates[0].controller.stickX > 0
    buttonStates.l[1] = gMarioStates[0].controller.stickX < 0
    buttonStates.u[1] = gMarioStates[0].controller.stickY > 0
    buttonStates.d[1] = gMarioStates[0].controller.stickY < 0
    buttonStates.a[1] = (gMarioStates[0].controller.buttonDown & A_BUTTON) ~= 0
    buttonStates.b[1] = (gMarioStates[0].controller.buttonDown & B_BUTTON) ~= 0
    buttonStates.z[1] = (gMarioStates[0].controller.buttonDown & Z_TRIG) ~= 0
    buttonStates.dpad_d[1] = (gMarioStates[0].controller.buttonDown & D_JPAD) ~= 0
end


local function drawRectOutline(x, y, w, h, outline)
    updateButtons()
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_rect(x, y, w, outline) 
    djui_hud_render_rect(x, y + h - outline, w, outline)
    djui_hud_render_rect(x, y + outline, outline, h - outline * 2)
    djui_hud_render_rect(x + w - outline, y + outline, outline, h - outline * 2)
end


local function drawState(m)
    squareSide = 10 * scale
    outline = 2
    origin = {
        x = screenWidth * 0.1,
        y = (screenHeight - screenHeight * 0.3)
    }
    

    for key, value in pairs(buttonStates) do
        if value[1] then
            djui_hud_set_color(231, 229, 50, 255)
            djui_hud_render_rect(origin.x + (squareSide + outline) * value[2], origin.y + (squareSide + outline) * value[3], squareSide, squareSide)
        end
        djui_hud_set_font(FONT_HUD)
        djui_hud_print_text(value[4], origin.x + (squareSide + outline) * value[2], origin.y + (squareSide + outline) * value[3], scale / 3)
        drawRectOutline(origin.x + (squareSide + outline) * value[2], origin.y + (squareSide + outline) * value[3], squareSide, squareSide, outline)
    end
end

--    m.controller.buttonDown & U_JPAD

hook_event(HOOK_ON_HUD_RENDER, drawState)