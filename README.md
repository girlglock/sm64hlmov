# sm64hlmov
## Super Mario 64 with Half-Life/Quake Movement Speedrun Modpack

### Credits
- mquake - 0x2480 https://mods.sm64coopdx.com/mods/mquake.234/
- Half-Life HUD - birdekek https://mods.sm64coopdx.com/mods/hl1-hl2-hud-mod-pack.224/
- Half-Life Music - Aeomech (myself)
- Crowbar - Aeomech (myself)

### HOW TO DOWNLOAD
- Click the green "CODE" button
- Click "Download as Zip"

### HOW TO RUN
- Download and install sm64coopdx
  - https://sm64coopdx.com/
  - https://github.com/coop-deluxe/sm64coopdx/releases/download/v1.0.4/sm64coopdx_v1.0.4_Windows_x86_64_OpenGL.zip
- Obtain a Super Mario 64 z64 ROM
  - WE CANNOT DISTRIBUTE THIS ROM FILE
  - The only legal way to do this is to back it up from your actual SM64 cart OR extract it from a legally purchased copy of SM64 on the Wii, Wii U, or Switch eShops.
- Extract this zip into your sm64coopdx/mods/ folder
  - You should see sm64coopdx/mods/mQuake, sm64coopdx/mods/crowbar, etc.
- Start sm64coopdx
  - Drag your sm64 z64 ROM file into the window
  - Click Host
  - Click Settings
  - Check "Skip Intro Cutscene"
  - Leave all other settings at default
  - Click Back
  - Click "Mods and Gamemodes"
  - Enable mQuake
  - Optionally enable HL1 HUD, Half-Life Crowbar, and Half-Life Music
  - Disable all other mods
  - Click Back
  - Under Save Slot you may pick and and erase save slots; all runs must start with an empty save slot.
  - Click Host, then click Host again. The game should start.
  - The settings should persist, so after this you just need to erase your save and click Host -> Host for new runs.
  - You will likely also want to set up your key binds to be more like Half-Life. This can be done under Options -> N64 Binds.

### Misc Notes
- No scripts or autohotkeys are allowed in the run. Auto hopping is allowed and enabled by default in mQuake.
- Use `\mq_server DeleteConfig default` to restore the default run-legal configuration.
- The Discord authorize thing is annoying and there's no launch flag (yet) to turn it off. However, the perms it asks for are relatively innocuous, and it'll stop asking after you authorize it.
  - https://github.com/coop-deluxe/sm64coopdx/issues/514
- It is possible to launch the game like so: `sm64coopdx.exe --skip-intro --skip-update-check --hide-loading-screen --server 6677` (the 6677 is arbitrary)
  - This gets you immediately into the game right on launch, but I'm not sure if it uses a default save slot. Investigation needed if this can be run-legal.
- Shout out to Jeepy (twitch.tv/jeepy) who found mQuake and silently routed it for months to turn it into a real speedrun!