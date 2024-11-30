-- name: MariomodXT
-- description: On-screen timer for full game runs with splits and reset functionality\nby Mr. Mary
version = "RC1"

mQuake_aa = 12

startTime = get_global_timer()
storedTime = 100
resetPresses = 0
secondWarning = {
    false,
    false
}
runDone = false
finalTime = 0
levels = {
    {9, "BOB"},      --BOB (no bother splitting here)
    {24, "WF"},     --WF
    {12, "JRB"},     --JRB
    {5, "CCM"},      --CCM
    {17, "BitDW"},     --BITDW
    {27, "PSS"},     --PSS
    {20, "SA"},     --SA
    {29, "Wing Cap"},     --Wing Cap
    {4, "BBH"},      --BBH
    {7, "HMC"},      --HMC
    {22, "LLL"},     --LLL
    {8, "SSL"},      --SSL
    {23, "DDD"},     --DDD
    {19, "BitFS"},     --BITFS
    {28, "Metal Cap"},     --Metal Cap
    {18, "Vanish Cap"},     --Vanish Cap
    {10, "SL"},     --SL
    {11, "WDW"},     --WDW
    {36, "TTM"},     --TTM
    {13, "THI"},     --THI
    {14, "TTC"},     --TTC
    {15, "RR"},     --RR
    {21, "BitS"},     --BITS
    {31, "WMOTR"}    --WMOTR
}
splits = {}
for i = 1, #levels do 
    splits[levels[i][1]] = {}
    splits[levels[i][1]][1] = false
end
entered = {}
enteredString = ""
pbStats = {0, {}}
deviatedRoute = false
newBest = false

local function setAA()
    if _G.mQuake_API.version then
        if _G.mQuake_API.server.get.airaccelerate() ~= 12 then
            _G.mQuake_API.server.set.airaccelerate(mQuake_aa)
            djui_popup_create("mQuake detected - setting AA to " .. tostring(mQuake_aa), 1)
        end
    end
end

local function serializeInt(t, n)
    local vars = {0, 0, 0, 0}  -- Initialize 4 variables to store the serialized values

    -- Iterate through the table to pack the values
    for i, v in ipairs(t) do
        local var_index = math.floor((i - 1) / 5) + 1  -- Which variable (1 to 4)
        local shift_amount = ((i - 1) % 5) * 6  -- Bit position in the 32-bit variable

        -- Pack the value into the correct variable using bit shifts
        vars[var_index] = vars[var_index] + ((v - 4) << shift_amount)
    end

    -- Return the specific variable (n-th one)
    return vars[n]
end

local function deserializeInt(var1, var2, var3, var4, num_elements)
    local vars = {var1, var2, var3, var4}  -- Collect the 4 variables into a table
    local t = {}  -- Table to store the deserialized values

    -- Iterate through the elements (based on num_elements)
    for i = 1, num_elements do
        local var_index = math.floor((i - 1) / 5) + 1  -- Which variable (1 to 4)
        local shift_amount = ((i - 1) % 5) * 6  -- Bit position in the 32-bit variable
        local value = (vars[var_index] >> shift_amount) & 0x3F  -- Extract the 6-bit value

        -- Restore the value to the original range (4 to 37)
        table.insert(t, value + 4)
    end

    return t  -- Return the deserialized table
end

local function initSplits()
    if not mod_storage_load_bool("initSetupDone") then
        djui_popup_create("First time setup...", 1)
        for i = 1, #levels do 
            splits[levels[i][1]][3] = 0
            mod_storage_save_number("besttime_" .. tostring(levels[i]), splits[levels[i][1]][3])
            mod_storage_save_number("level_" .. tostring(i), 0)
        end
        mod_storage_save_bool("initSetupDone", true)
    else
        --djui_popup_create("Not first time, loading best times", 1)
        for i = 1, #levels do 
            splits[levels[i][1]][3] = mod_storage_load_number("besttime_" .. tostring(levels[i][1]))
        end
    end
    if mod_storage_load_bool("pbRecorded") then
        pbStats[1] = mod_storage_load_number("bestTime")
        levelOrder = mod_storage_load("levelOrder")
        for i = 1, #levels do
            table.insert(pbStats[2], mod_storage_load_number("level_" .. tostring(i)))
        end
        --pbStats[2] = deserializeInt(mod_storage_load_number("levelOrder_1"), mod_storage_load_number("levelOrder_2"), mod_storage_load_number("levelOrder_3") , mod_storage_load_number("levelOrder_4"), mod_storage_load_number("levelAmount"))
    end
end
initSplits()

local function printTimer(time_string)
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
    local x = 0
    local y = (screenHeight / 2) + (height / 2)

    -- set color and render
    djui_hud_set_color(0, 0, 0, 95)
	djui_hud_render_rect(x, y, width + 10, height / 2)
	djui_hud_set_color(231, 229, 50, 255)
    djui_hud_print_text(text, x, y, scale)
end

local function resetPopupWarnings()
    for i = 1, 2 do
        secondWarning[i] = false
    end
end

local function resetCurrentSplits()
    for i = 1, #levels do 
        splits[levels[i][1]][1] = false
        splits[levels[i][1]][2] = nil
        splits[levels[i][1]][3] = mod_storage_load_number("besttime_" .. tostring(levels[i][1]))
    end
    entered = {}
end

local function formatTime(currentTime, signed)
    local isNegative = currentTime < 0
    currentTime = math.abs(currentTime) -- Work with the absolute value for calculations

    local totalSeconds = currentTime / 30
    local minutes = math.floor(totalSeconds / 60)
    local seconds = math.floor(totalSeconds % 60)
    local milliseconds = math.floor((totalSeconds % 1) * 1000)

    local formattedTime
    if minutes < 10 then
        formattedTime = string.format("%d:%02d.%03d", minutes, seconds, milliseconds)
    else
        formattedTime = string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
    end

    -- Add a sign only if `signed` is true
    if signed then
        if isNegative then
            formattedTime = "-" .. formattedTime
        else
            formattedTime = "+" .. formattedTime
        end
    end

    return formattedTime
end

local function nukeSave()
    local saveSlot = get_current_save_file_num() - 1
    save_file_erase(saveSlot)
    save_file_erase_current_backup_save()
    save_file_reload(saveSlot)
    warp_to_level(LEVEL_CASTLE_GROUNDS,1,0)
    gFirstPersonCamera.pitch = 0
    startTime = get_global_timer()
    --djui_popup_create("I am DarkViperAU and the run is dead", 1)
    resetPresses = 0
    storedTime = 100
    runDone = false
    finalTime = 0
    deviatedRoute = false
    newBest = false
    resetPopupWarnings()
    resetCurrentSplits()
    initSplits()
    setAA()
end

local function nukeTimes()
    for i = 1, #levels do 
        splits[levels[i][1]][3] = 0
    end
end

local function reset(m)
    if (m.controller.buttonPressed & U_JPAD) ~= 0 then
        resetPresses = resetPresses + 1
        if resetPresses == 1 then
            djui_popup_create("Resetting in 3 seconds...", 1)
            storedTime = get_global_timer()
        elseif resetPresses == 2 then 
            djui_popup_create("Reset cancelled!", 1)
            resetPresses = 0
            resetPopupWarnings()
        end
    end
    if resetPresses == 1 then
        if get_global_timer() - storedTime == 30 and not secondWarning[1] then
            djui_popup_create("Resetting in 2 seconds...", 1)
            secondWarning[1] = true
        elseif get_global_timer() - storedTime == 60 and not secondWarning[2] then
           djui_popup_create("Resetting in 1 second...", 1)
           secondWarning[2] = true
        elseif get_global_timer() - storedTime > 90 then
            nukeSave()
            m.health = 0x0880
            m.numLives = 4
        end
    end
end

local function trackSplit()
    currentLevel = gNetworkPlayers[0].currLevelNum
    for i = 1, #levels do
        if levels[i][1] == currentLevel then
            if splits[currentLevel][1] == false then
                splitTime = get_global_timer() - startTime
                splits[currentLevel][2] = splitTime
                bestTime = splits[currentLevel][3]
                deltaTime = splitTime - bestTime
                table.insert(entered, currentLevel)
                splitString = formatTime(splitTime, false)
                expected = entered[#entered] == pbStats[2][#entered]
                print("entered now " .. tostring(entered[#entered]))
                print("entered in PB " .. tostring(pbStats[2][#entered]))

                if bestTime == 0 then
                    if pbStats[1] == 0 then
                        print("No best time on record")
                        splits[currentLevel][3] = splitTime
                        splitString = "Entering " .. levels[i][2] .. " at " .. splitString
                    else
                        splitString = "Entering " .. levels[i][2] .. " at " .. splitString
                        if not deviatedRoute then
                            djui_popup_create("\\#FE0000\\Route deviation - ignoring best times", 1)
                            deviatedRoute = true
                            nukeTimes()
                        end
                        print("Route deviation on split")
                    end
                elseif expected then
                    color = "\\#FFFFFF\\"
                    if deltaTime > 0 then
                        color = "\\#FE0000\\"
                    elseif deltaTime < 0 then
                        color = "\\#21A212\\"
                    end
                    splitString = "Entering " .. levels[i][2] .. " at " .. splitString .. " (" .. color .. formatTime(deltaTime, true) .. "\\#FFFFFF\\)"
                    print("Best time on record")
                else
                    splitString = "Entering " .. levels[i][2] .. " at " .. splitString
                    djui_popup_create("\\#FE0000\\Route deviation - ignoring best times", 1)
                    deviatedRoute = true
                    nukeTimes()
                    print("Route deviation on split")
                end
                splits[currentLevel][1] = true
                djui_popup_create(splitString, 1)
                
                for i, value in ipairs(entered) do
                    print(i, value)
                end
            end
        end
    end
end

local function calcCenter(string, scale)
    string_width = djui_hud_measure_text(string) * scale
    return djui_hud_get_screen_width() / 2 - string_width / 2
end

local function calcRightAlign(string, scale, x)
    string_width = djui_hud_measure_text(string) * scale
    return x - string_width
end

local function showStats()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    local scale = screenWidth * 0.0022

    djui_hud_set_color(0, 0, 0, 191)
    djui_hud_render_rect(screenWidth / 3, screenHeight * 0.07 , screenWidth / 3, screenHeight - screenHeight * 0.14)

    djui_hud_set_color(231, 229, 50, 255)
    if newBest then
        djui_hud_print_text("New record!", calcCenter("New record!", scale), screenHeight * 0.1, scale)
    else
        djui_hud_print_text("Run complete!", calcCenter("Run complete!", scale), screenHeight * 0.1, scale)
    end

    djui_hud_print_text(tostring(formatTime(finalTime, false)), calcCenter(tostring(formatTime(finalTime, false)), scale), screenHeight - (screenHeight * 0.1) * 2, scale)
  
    split_ypos = screenHeight * 0.24
    previousID = nil
    for _, enteredID in ipairs(entered) do
        for _, level in ipairs(levels) do
            if level[1] == enteredID then
                time = formatTime(splits[enteredID][2], false)
                djui_hud_set_color(231, 229, 50, 255)
                djui_hud_print_text(level[2] .. " entry", screenWidth / 3 + screenWidth * 0.01, split_ypos, scale / 4)
                djui_hud_print_text(time, calcRightAlign(time, scale / 4, screenWidth - (screenWidth / 3 + screenWidth * 0.01)), split_ypos, scale / 4)
                if pbStats[1] ~= 0 then
                    time2 = formatTime(splits[enteredID][2] - splits[enteredID][3], true)
                    if previousID == nil then
                        segmentCurrent = splits[enteredID][2]
                        segmentPrevious = splits[enteredID][3]
                    else
                        segmentCurrent = splits[enteredID][2] - splits[previousID][2]
                        segmentPrevious = splits[enteredID][3] - splits[previousID][3]
                    end
                    if segmentCurrent < segmentPrevious then
                        djui_hud_set_color(33, 162, 18, 255)
                    elseif segmentCurrent > segmentPrevious then
                        djui_hud_set_color(254, 0, 0, 255)
                    end
                    djui_hud_print_text(time2, calcRightAlign(time2, scale / 4, screenWidth - (screenWidth / 3 + screenWidth * 0.01)) - screenWidth * 0.08, split_ypos, scale / 4)
                end
                split_ypos = split_ypos + screenHeight * 0.0242
                previousID = enteredID
                break
            end
        end
    end
    time = formatTime(finalTime, false)
    djui_hud_set_color(231, 229, 50, 255)
    djui_hud_print_text("Grand Star", screenWidth / 3 + screenWidth * 0.01, split_ypos, scale / 4)
    djui_hud_print_text(time, calcRightAlign(time, scale / 4, screenWidth - (screenWidth / 3 + screenWidth * 0.01)), split_ypos, scale / 4)
    if pbStats[1] ~= 0 then
        time2 = formatTime(finalTime - pbStats[1], true)
            segmentCurrent = finalTime - splits[previousID][2]
            segmentPrevious = finalTime - splits[previousID][3]
        if segmentCurrent < segmentPrevious then
            djui_hud_set_color(33, 162, 18, 255)
        elseif segmentCurrent > segmentPrevious then
            djui_hud_set_color(254, 0, 0, 255)
        end
        djui_hud_print_text(time2, calcRightAlign(time2, scale / 4, screenWidth - (screenWidth / 3 + screenWidth * 0.01)) - screenWidth * 0.08, split_ypos, scale / 4)
    end

end

local function saveRun(msg)
    callFromChat = msg and (runDone and deviatedRoute)
    if (not msg) or (callFromChat) then
        mod_storage_save_bool("pbRecorded", true)
--[[         for i = 1, 4 do
            mod_storage_save_number("levelOrder_" .. tostring(i), serializeInt(entered, i))
        end ]]
        for i = 1, #entered do
            mod_storage_save_number("level_" .. tostring(i), entered[i])
        end
        mod_storage_save_number("levelAmount", #entered)
        mod_storage_save_number("bestTime", finalTime)
        for i = 1, #levels do 
            if splits[levels[i][1]][2] then
                mod_storage_save_number("besttime_" .. tostring(levels[i][1]), splits[levels[i][1]][2])
            end
        end
        djui_popup_create("Run saved!", 1)
        if msg then
            return true
        end
    end
    if msg and (not callFromChat) then
        djui_chat_message_create("This command works only after a run!")
        return true
    end
end

local function starAction(_, _, i)
	--if i == INTERACT_STAR_OR_KEY and gMarioStates[0].numStars == 2 then
    if i == INTERACT_STAR_OR_KEY and gNetworkPlayers[0].currLevelNum == 34 then
        runDone = true
        finalTime = get_global_timer() - startTime
        enteredString = tostring(entered[1])
        for i = 2, #entered do
            enteredString = enteredString .. " " .. tostring(entered[i])
        end
        play_course_clear()
        if pbStats[1] ~= 0 and pbStats[1] > finalTime then
            newBest = true
            print("set newbest flag")
        end
        if (not deviatedRoute) or (not #entered == #pbStats[2]) then
            if pbStats[1] == 0 or pbStats[1] > finalTime then
                saveRun()
                print("saveable run")
            end
        else
            djui_popup_create("\\#FE0000\\Route deviation - to save, type /mxt_save_run", 1)
        end
	end
end

local function drawTimer()
    if not runDone then
        printTimer(tostring(formatTime(get_global_timer() - startTime, false)))
    else
        printTimer(tostring(formatTime(finalTime), false))
        showStats()
    end
end

local function printTime(msg)
    djui_chat_message_create(formatTime(pbStats[1], false))
    return true
end

hook_event(HOOK_ON_INTERACT, starAction)
hook_event(HOOK_MARIO_UPDATE, reset)
hook_event(HOOK_ON_LEVEL_INIT, trackSplit)
hook_event(HOOK_ON_LEVEL_INIT, setAA)
hook_event(HOOK_ON_HUD_RENDER, drawTimer)
--hook_chat_command("bowser3", " - wipe the current savefile and reset to Castle Grounds", bowser3)
hook_chat_command("mxt_save_run", " - save currently finished run", saveRun)
hook_chat_command("mxt_best_time", " - print best recorded time", printTime)
djui_popup_create("MariomodXT v" .. version .. " loaded!", 1)
