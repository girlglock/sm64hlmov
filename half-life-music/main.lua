-- name: \\#ed6d28\\Half-Life \\#ffffff\\Music
-- description: Overrides SM64 MIDIs with Half-Life music
-- incompatible:

audioStream = nil;
audioSample = nil;

function stream_control(msg)
    if(msg == "play") then
        audio_stream_play(audioStream, true, 1);
        djui_chat_message_create("playing audio");
    end

    if(msg == "resume") then
        audio_stream_play(audioStream, false, 1);
        djui_chat_message_create("resuming audio");
    end

    if(msg == "pause") then
        audio_stream_pause(audioStream);
        djui_chat_message_create("pausing audio");
    end

    if(msg == "stop") then
        audio_stream_stop(audioStream);
        djui_chat_message_create("stopping audio");
    end

    if(msg == "getpos") then
        djui_chat_message_create("pos: " .. tostring(audio_stream_get_position(audioStream)));
    end

    return true;
end

hook_chat_command('mp3', "[play|resume|pause|stop|getpos]", stream_control)


function override_music(player, seqID)
	if (seqID == SEQ_EVENT_CUTSCENE_STAR_SPAWN or seqID == SEQ_EVENT_SOLVE_PUZZLE or seqID == SEQ_EVENT_PIRANHA_PLANT or seqID == SEQ_EVENT_RACE) then
		return seqID
	end
	
	if (audioStream ~= nil) then
		audio_stream_stop(audioStream);
	end
	if (seqID == SEQ_EVENT_CUTSCENE_INTRO or seqID == SEQ_EVENT_CUTSCENE_ENDING) then
		return SEQ_COUNT;
	end
    
    if (seqID == SEQ_LEVEL_GRASS) then
        audioStream = audio_stream_load("SEQ_LEVEL_GRASS.mp3");
    elseif (seqID == SEQ_LEVEL_INSIDE_CASTLE) then
        audioStream = audio_stream_load("SEQ_LEVEL_INSIDE_CASTLE.mp3");
    elseif (seqID == SEQ_LEVEL_WATER) then
        audioStream = audio_stream_load("SEQ_LEVEL_WATER.mp3");
    elseif (seqID == SEQ_LEVEL_HOT) then
        audioStream = audio_stream_load("SEQ_LEVEL_HOT.mp3");
    elseif (seqID == SEQ_LEVEL_BOSS_KOOPA) then
        audioStream = audio_stream_load("SEQ_LEVEL_BOSS_KOOPA.mp3");
    elseif (seqID == SEQ_LEVEL_SNOW) then
        audioStream = audio_stream_load("SEQ_LEVEL_SNOW.mp3");
    elseif (seqID == SEQ_LEVEL_SLIDE) then
        audioStream = audio_stream_load("SEQ_LEVEL_SLIDE.mp3");
    elseif (seqID == SEQ_LEVEL_SPOOKY) then
        audioStream = audio_stream_load("SEQ_LEVEL_SPOOKY.mp3");
    elseif (seqID == SEQ_LEVEL_UNDERGROUND) then
        audioStream = audio_stream_load("SEQ_LEVEL_UNDERGROUND.mp3");
    elseif (seqID == SEQ_EVENT_POWERUP) then
        audioStream = audio_stream_load("SEQ_EVENT_POWERUP.mp3");
    elseif (seqID == SEQ_EVENT_METAL_CAP) then
        audioStream = audio_stream_load("SEQ_EVENT_METAL_CAP.mp3");
    elseif (seqID == SEQ_LEVEL_KOOPA_ROAD) then
        audioStream = audio_stream_load("SEQ_LEVEL_KOOPA_ROAD.mp3");
    elseif (seqID == SEQ_EVENT_BOSS) then
        audioStream = audio_stream_load("SEQ_EVENT_BOSS.mp3");
    elseif (seqID == SEQ_LEVEL_BOSS_KOOPA_FINAL) then
        audioStream = audio_stream_load("SEQ_LEVEL_BOSS_KOOPA_FINAL.mp3");
		audio_stream_set_looping(audioStream, false);
        audio_stream_play(audioStream, true, 1);
		return SEQ_COUNT;
    elseif (seqID == SEQ_EVENT_CUTSCENE_CREDITS) then
        audioStream = audio_stream_load("SEQ_EVENT_CUTSCENE_CREDITS.mp3");
    elseif (seqID == SEQ_EVENT_PEACH_MESSAGE) then
        audioStream = audio_stream_load("SEQ_EVENT_PEACH_MESSAGE.mp3");
    elseif (seqID == SEQ_EVENT_CUTSCENE_VICTORY) then
        audioStream = audio_stream_load("SEQ_EVENT_CUTSCENE_VICTORY.mp3");
    else
		return seqID;
	end

    if (audioStream) then
        audio_stream_set_looping(audioStream, true);
        audio_stream_play(audioStream, true, 1);
    else
        -- No override available. Play the SM64 music.
        return seqID;
    end

    return SEQ_COUNT;
end

hook_event(HOOK_ON_SEQ_LOAD, override_music)