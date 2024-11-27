-- name: \\#ed6d28\\HL1 \\#ffffff\\HUD
-- description: A recreation of the HUD from \\#ed6d28\\HL1\\#ffffff\\, \nby \\#6269b5\\Birdekek \\#47ded1\\\n[HL1 + HL2 HUD Modpack]\n\n\\#ffffff\\This mod replaces the default SM64 HUD with a recreation of the HUD from\n\\#ed6d28\\Half-Life\\#ffffff\\, a gane from 1998, Valve's first game.

TEX_MEDICAL = get_texture_info("medical")
TEX_LAMBDA = get_texture_info("lambda")
TEX_LINE = get_texture_info("line")
TEX_COIN = get_texture_info("coin")
TEX_STAR = get_texture_info("star")

local healthcolorv = 1
local timer = 0

local function update()
    local m = gMarioStates[0]
    local mathed_health = math.ceil((m.health - 255) * 100 / (2176 - 255))
    
    if mathed_health <= 25 then
        if healthcolorv ~= 0 then healthcolorv = healthcolorv - 0.1 end
        if healthcolorv <= 0 then healthcolorv = 0 end
    else
        if healthcolorv ~= 1 then healthcolorv = healthcolorv + 0.1 end
        if healthcolorv >= 1 then healthcolorv = 1 end
    end

    timer = timer + 0.25

    if timer == 256 then timer = 0 end
end

local function on_hud_render()
    local m = gMarioStates[0]
    local mathed_health = math.ceil((m.health - 255) * 100 / (2176 - 255))
    djui_hud_set_resolution(RESOLUTION_N64)
    local y = djui_hud_get_screen_height() - 8
    local health_width = djui_hud_measure_text(tostring(mathed_health)) * 0.76

    if mathed_health <= 25 then
        djui_hud_set_adjusted_color(204, 67, 67, 255)
    else
        djui_hud_set_adjusted_color(245, 234, 32, 255)
    end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_print_text(tostring(mathed_health), 45, y - 16, 0.76)
    djui_hud_render_texture(TEX_MEDICAL, 16, y - 12, 1, 1)

    djui_hud_set_adjusted_color(245, 234, 32, 255)

    djui_hud_render_texture(TEX_LINE, health_width + 45, y - 12, 0.7, 1)
    djui_hud_render_texture(TEX_LAMBDA, health_width + 55, y - 12, 1, 1)
    djui_hud_print_text(tostring("x" .. tostring(m.numLives)), health_width + 74, y - 16, 0.76)

    -- render the coin, star, and both of their texts as yellow

    djui_hud_set_adjusted_color(245, 234, 32, 255)

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_print_text("x" .. tostring(m.numCoins), 32, 8, 0.76)
    djui_hud_render_texture(TEX_COIN, 12, 12, 1, 1)
    djui_hud_render_texture(TEX_STAR, 12, 36, 1, 1)
    djui_hud_print_text(tostring("x" .. tostring(m.numStars)), 32, 32, 0.76)

    hud_hide()
end

function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = 1
    if is_game_paused() then multiplier = 0.5 end
    djui_hud_set_color(r * multiplier, g * multiplier, b * multiplier, a)
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_UPDATE, update)