# Changelog

## 1.8.5

A hotfix for 1.8's frame rate. Players found 1.5.1 ran better: the main reason was ours, and it is fixed. 60 fps is the default again. This update also brings the 1.9 work that was ready: a save editor, Wide view with the HUD kept in place, better frame generation, and a fix for a crash about 11 minutes in. **This build has been compiled and checked on our Mac, but not yet played on a phone**, so please share your game log (**Extras → Export game log**) if something looks or runs wrong.

### Why 1.8 ran worse than 1.5.1, and what changed

- **A fixed CPU budget made for 60 fps.** Since HookLink 0.1, the iPhone preset told iOS the game's main thread needs at most 12 ms a frame. That suited 60 fps, which 1.5.1 used. 1.8 made 30 fps + frame generation the default, where the thread needs more than 12 ms: iOS stalled it on most frames (in our 1.8 log every frame was late). The engine now measures what the thread needs and tells iOS that (`DM_RT_COMP=auto`). With it, a 1.8 build held a steady 30 fps for 10 minutes where 1.8 kept dropping. This also reaches older HookLink apps: the engine treats the old preset's 12 as measured.
- **60 fps is the default Frame rate mode again**, as in 1.5.1. 30 fps + frame generation is still one tap away and runs cooler.
- **Two rendering settings are back to how 1.5.1 and 1.7 ran.** 1.8 turned on lossy compression of render targets and side-by-side compute work along with the steady 30 fps mode. Both are off again. 60 fps restarted an iPhone 18 Pro Max once on 1.8; we have not found the cause, and these two changes are the main difference at 60 fps between 1.8 and 1.7.

What stays from 1.7 and 1.8 because it is needed: the larger memory layout that gets you past the Master Sword, and real game speed below 60 fps (before 1.7 the game ran 9 to 17% too fast when the frame rate dropped, which could feel snappier but was wrong).

### Fixed: a crash about 11 minutes in

When you enter a new area, the game rebuilds each model's materials on a background thread, with memory from small heaps of the model's own. When one of those was full, the game went on with nothing and crashed (on our iPhone: `BufferInitialize: pool has no storage`, 11 minutes in). Each of those four allocations is now tried again in the heap's parent heaps, which have room, and last in the game's default heap. Hookshot found the same crash on PCs (NotRexed/Hookshot issue 1697); our fix is our own. `DM_HEAP_RETRY=0` turns it off.

### New: Save editor (Extras)

**OOT SW2SE** by Traiver and contributors, built into the launcher. It opens your own saves, no file picker:

- Change rupees, hearts, magic, items, bottles, small keys, bag and quiver sizes, masks and quest flags.
- **Export to folder** writes the changes into your saves after you confirm. Your saves as they were are copied to `save-backups/editor-<time>` first.
- **Export ZIP** saves a patch file in Files (`save-editor`) and leaves your saves as they are.

Edits can break a save: keep the backups.

### Wide view (experimental): the HUD and menus stay in place

With Wide view on, the 3D view fills the screen while the HUD, menus and movies keep their 16:9 shape in the middle, as on a 16:9 screen. The pause menu backgrounds, the item wheel and the fades still cover the whole screen. The sites are Ivan0xFF's (MIT), found through NX2navi. Wide view is still slower than the normal view.

### Frame generation, from cheemu21

- It finds motion between the two real frames itself, so fast camera turns are placed better, and the HUD is taken from the real frame so it stays sharp.
- A single late frame no longer drops you to 30: generation pauses only for that frame. While frames keep dropping it stops, and comes back after 30 frames in time.
- **Frame generation size** (Settings): Lighter makes the in-between frames at 0.75 size, for about half of frame generation's GPU time and a slightly softer picture.

### New setting: Deadline boost (Performance, off)

Tells iOS each frame's deadline, so it keeps the game's frame threads on the fast cores at a higher clock. It uses more power and heat. Try it if the frame rate drops as the phone warms.

### Known issues

- **Busy areas can still dip at 60 fps.** After some area changes the game's own logic needs more CPU than the phone gives it at 60 (on a test build it fell from 30 to 16–20 fps at 30 fps after an area change). We are still testing a change that keeps all of the game's threads at full priority.
- **60 fps restarted the phone once on 1.8.** If it happens on 1.8.5, open the game again and send the log.
- **1.8.5 has not been played on a phone yet** (see the top).
- Movies and subtitles can drift apart below 60 fps.

### To update

Open HookLink and click **Update and rebuild**, then install the new app over the old one. Your saves and game files stay on the phone. **The shaders do not change, so no 2-hour recompile**: the rebuild took about 40 minutes on our Mac. Download the new HookLink app too: it has the updated preset (the engine applies the main fix either way).

### Credits

Traiver and contributors (OOT SW2SE), Ivan0xFF (Wide view HUD sites) and tangerineturtle1 (NX2navi), cheemu21 (frame generation), NotRexed's Hookshot and TomShafford (the full-heap finding), and everyone who reported 1.8 running worse than 1.5.1.

## 1.8

Ocarina of Time now builds as a **native Mac app** as well as an iPhone app. 1.8 also brings:
- a new launcher inside the game (iPhone and Mac)
- frame rate modes with frame generation
- more touch-control options
- a memory safety cutoff
- better frame pacing
- a new look for HookLink
- 64 engine commits from nxnative

Everything on iPhone was played on an iPhone 18 Pro Max (iOS 27.2) in test builds. The Mac app and the iPhone 16 Pro have **not** been played yet. Please share your game log (**Extras → Export game log**) if something looks or runs wrong.

### 🖥️ New: a native Mac app (experimental)

HookLink can build the game as a double-clickable app for your **Apple silicon Mac**, not only for an iPhone.

- **How:** in **Choose device**, pick **This Mac (M…)**, then **Build**. The Install and Copy game files steps are skipped, because the game's files go inside the app. When the build is done, **Play** offers **Open the game** and **Show in Finder**. The app is called *Ocarina of Time (HookLink).app* and sits in HookLink's build folder; you can move it to Applications.
- **How it runs:**
  - Docked mode at a 1440p output, with dynamic resolution on.
  - Real game speed below 60 fps, the same frame-step fix as on the iPhone.
  - The shaders are compiled for your Mac's own GPU.
- **Controls:**
  - Keyboard and controllers both work. The keyboard is player 1 together with the first controller.
  - Shift + arrow keys move the camera (the right stick).
- **Launcher:** the same Settings / Play / Extras launcher as the iPhone. On the Mac, Extras opens the saves folder, the logs and the cheats folder in Finder. It also has cloud saves, **Reset to tested defaults** and the credits.
- **Status: new and untested.** It has been built, but nobody has played it yet. Expect rough edges and please open an issue with your log. iPhone-only settings (touch controls, Wide view) aren't shown on the Mac.

### New: the game's launcher (iPhone and Mac)

When you open the game you now get a menu with three tabs before it starts: **Settings · Play · Extras**. It opens on Play, in the middle. Switch tabs with **L / R** on a controller, or by tapping.

- **Play**
  - **Left side:** the game's icon, its title, the version and a gold **Play** button.
  - **Right side, "How it will run":** your frame rate mode, dynamic resolution, Wide view, touch controls style and free storage. Tap a row to jump to that setting.
  - A warning appears when your phone has less than 25 GB free.
  - Before playing, the launcher checks your cloud save. If both copies changed, it asks which one to keep.
- **Settings:** every option in one list with a description panel. Each one says when it takes effect.
- **Extras**
  - **Export saves:** sends a copy of your save folder to Files, AirDrop or another app. Your save stays on the phone.
  - **Import a save:** pick a save folder, or a folder that holds one. Your current save is backed up to `save-backups` first. Unzip a .zip in Files before importing it.
  - **Export game log:** the log to attach to bug reports.
  - **Cloud saves:** turn iCloud sync on or off.
  - **Cheats:** cheat files you put in the game's `cheats` folder (Files → On My iPhone → the game → `cheats`) are listed and switched on here. HookLink doesn't ship any cheats.
  - **Reset to tested defaults:** see below.
  - **Credits.**

### New: Frame rate mode

One choice in **Settings → Game** replaces the old frame rate settings:

| Mode | What it does |
|---|---|
| **60 fps** | Full 60 fps, the most demanding. Busy areas dip and the phone gets warm (see Known issues). |
| **30 fps steady** | A locked, even 30 with steady frame pacing. Coolest and longest battery life. |
| **30 fps + frame generation** *(default)* | The game draws a steady 30, and Apple's **MetalFX frame interpolation** makes a frame between each two, so the screen shows 60. It's much less work and heat than real 60, with a little more input delay; very fast motion can smear slightly. On our iPhone 18 Pro Max it looked like 60 fps with no visible smearing, and it stayed smooth through Hyrule Field. |
| **60 fps + frame generation** *(experimental)* | The game aims for 60 and frame generation doubles it on a 120 Hz ProMotion screen. In our test it sat at about 35 fps in busy areas, so it isn't recommended yet. |

The game keeps real speed in every mode.

### New: tested defaults

**Reset to tested defaults** (Extras) sets the best settings we found, and new installs start with them:
- **Frame rate mode:** 30 fps + frame generation.
- **Game's upscaler:** MetalFX. Apple's upscaler gives the same picture for far less GPU time than the game's own upscaling network. An iPhone 17 Pro player found the game's own one too heavy (issue #3).
- Everything else goes back to its default.

Settings you changed yourself are kept when you update. Settings you never touched move to the new defaults.

### Touch controls (iPhone)

- **Layouts:** Mobile (a floating stick, camera on the right half of the screen, a D-pad), 3D, 2D and tap. Any controller works too.
- **New: Touch controls opacity.** A slider in **Settings → Controls** from 20% to 100%. Every on-screen button, the stick and the menu button fade together. Takes effect the next time the game starts.
- **Fixed: the Mobile layout under Classic and Forest.** Before, it always looked glassy. Now its keys, stick ring and menu button are flat keys in the theme's own colours and rims. The **Glass** theme keeps the glass look.

### Wide view (still experimental)

Wide view fills the whole iPhone screen, with no black bars, by widening the 3D view (off by default).
- **New in 1.8:** the game now lays out its screen at the wider width, so the **HUD and menus should keep their normal size** instead of stretching sideways. The 3D camera is never widened twice. **This hasn't been confirmed on a phone yet**, so please send a screenshot or log either way.
- It still draws about a fifth more pixels, so it's slower and warmer than the normal view.

### Memory: a safety cutoff

1.7 gave the game an 8 GB address space and turned off its mapping limit to fix the white screen after the Master Sword. 1.8 keeps that and adds a **last-resort cutoff**. The engine refuses new memory when the game already holds 10 GB, or when less than 768 MB is left before iOS's limit for the app. The game then frees its own cached memory instead of iOS closing it.

1.8 uses more memory than 1.7: about 6.4–6.9 GB in our test.

### Frame pacing

On iPhone, the thread that hands each finished frame to the screen now declares its own frame deadline to iOS. In Hyrule Field and the adult world, iOS had been keeping that thread on the slow efficiency cores (1.3–1.7 GHz instead of about 3.7). How much this helps hasn't been measured yet.

### HookLink (the Mac app you build with)

- **A new look, after the game's file-select screen:**
  - Each step is a pill button with its status.
  - The panel sits at 80% opacity over a drawn sky with clouds.
  - The lettering is sharper.
- **"Choose your iPhone" is now "Choose device"**, with:
  - **iPhone 18 Pro / Pro Max:** tested.
  - **iPhone 17 family:** a player runs it on a 17 Pro, with 30 fps + frame generation recommended.
  - **iPhone 16 Pro / 16 Pro Max (A18 Pro):** new, **untested**. These have 8 GB of memory, so the game may close in busy areas.
  - **This Mac:** new, **untested**. See above.
- The README's status table, requirements and credits are updated.

### From nxnative (64 commits)

The ones that matter for Ocarina of Time and for building:

- **Building**
  - .NET is no longer needed: the shader translator and the file extractor come as native executables.
  - Shaders are finished in worker processes, so a cold build uses every core of your Mac.
  - Mac shaders are compiled for the Mac's minimum macOS, so every Mac gets the same result.
- **Graphics**
  - Movies played into linear textures are no longer black.
  - Textures whose width isn't a whole number of tiles keep the game's padding.
  - NaN or infinite colours under a zero blend weight no longer show, matching the console.
  - New multisample textures start cleared.
  - A view keeps its parent texture alive.
  - Unused border corrections are compiled out of pipelines.
- **CPU and stutter**
  - The submissions of one frame share a command allocator.
  - Argument blocks whose only change is a uniform binding are patched instead of encoded again.
  - Uniform reads are bounded once per binding instead of on every read.
  - Pipeline bases the archives lack are remembered for the run.
  - Short sleeps become polls.
  - Vertex-attribute conversions are kept while their source is unchanged.
- **Memory:** textures resized by dynamic resolution take recycled memory instead of new Metal memory each time.
- **Saves:**
  - When both the cloud save and this device's save changed, the launcher asks which to keep.
  - The launcher waits for a cloud save iCloud has only listed.
  - Automated runs never sync with your cloud save.
- **Controllers:**
  - A controller with a second, silent device entry stays one player.
  - Switch 2 controllers can join with a button press.
  - Touch works after leaving the dock.
  - DualSense haptics keep both handles.
- **From cheemu21's kid-with-sword-remake:** the steady 30 fps (V17) and the frame generation work (X2–X9) the frame rate modes are built on.

### Known issues

- **Plain 60 fps restarted an iPhone 18 Pro Max once** in Hyrule Field (the GPU stopped responding and iOS restarted). Use 30 fps + frame generation (the default) until we find the cause. If it happens to you, open the game again afterwards and send the log from **Extras → Export game log**.
- **60 fps + frame generation** reaches only about 35 fps in busy areas.
- **Wide view** is slower, and its HUD fix is unconfirmed (see above).
- **Memory:** 1.8 uses more memory than 1.7.
- **Movies and subtitles** can drift apart below 60 fps.
- **Untested:** the Mac app and the iPhone 16 Pro have not been played yet.
- **Surfaces:** some can still show as flat single-colour shapes.

### To update

- **iPhone:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone.
- **Rebuild time:** this update changes the shaders, so every shader is compiled again, which took about 2 hours on our Mac. Keep the Mac awake and plugged in while it runs, because sleep pauses it.
- **First start:** "Preparing shaders" takes a few minutes. If the first session after that feels slow, close the game fully and reopen it.
- **Mac app:** a separate build. Choose **This Mac** under Choose device and build. The iPhone build and its files aren't touched.

### Credits

- **[seedds](https://github.com/seedds)** and nxnative's contributors for nxnative, which all of this runs on.
- **[cheemu21](https://github.com/cheemu21)** for kid-with-sword-remake: the steady 30 fps, frame generation and the 8 GB memory layout, plus the inspiration for the touch controls.
- **ednofedulo** and the kid-with-sword contributors.
- **oliverames** for the frame-step fixes and iPhone testing.
- **gunvalk** for the frame-step finding.
- **vladbondarenko97** for the wide-view sites.
- **PromethOps** and **LeonardoBai12** for their nxnative pull requests.
- Everyone who tested and sent logs.

## 1.7

Fixes the game stopping when you pull the Master Sword, makes Wide view widen the 3D world, and brings engine fixes from nxnative and from a tester. The fixes were played on an iPhone 18 Pro Max in test builds; the final 1.7 build itself has not been played yet, so please share your game log (**Get game log**) if something looks or runs wrong.

**Fixed: white screen after pulling the Master Sword.** The game stayed on a white screen for good, with no sound, and you could not become adult Link. On an iPhone the engine gave the game 4 GB of address space, and the game had used nearly all of it by then, so the next scene's movie and files had nowhere to go. It now gets 8 GB, and a limit on how much it may map at once is off. Tested on an iPhone 18 Pro Max: the movie plays and the game goes on. The game uses more memory than before (about 4.7 GB in our test, 5.4 GB at most); if it closes by itself on your phone, please send your log.

**Wide view is now experimental.** It is labelled that way in the game's launcher, and it stays off by default.
- **Fixed:** the 3D world is now wider instead of stretched. The 1.6 notes said this was fixed, but that fix did not work on a phone.
- **Not fixed yet:** the HUD and every menu, the title screen included, are stretched sideways.
- **Slower:** it costs clearly more than the "little slower" the launcher said before. In our test Hyrule Field ran at about 40 fps with it on.

**Fixed: the game ran a little fast below 60 fps.** When the frame rate dropped, the game made up the lost time twice and ran 9 to 17% too fast between 30 and 60 fps. Found and fixed by oliverames, who tested HookLink's engine on an iPhone Duo.

**From nxnative (29 commits):**
- **Textures:** streamed scenery such as the cliff beside the Castle Town wall no longer draws with the wrong texture, and terrain no longer turns into crossing stripes after entering or leaving a dungeon.
- **Stutter:** many more pipelines are prepared before play, so there are fewer hitches the first time you see a new place.
- **CPU and heat:** two engine threads no longer fight over a lock, and short waits wake the CPU far less often.
- **Castle Town:** a search of the pipeline archive that repeated on every draw is now remembered, next to HookLink's own fix for the same slowdown.

**Known issues**
- With Wide view on, the HUD and menus are stretched and the frame rate is lower (see above).
- After you become adult Link, busy areas ran at 32 to 46 fps in our test, with Wide view off and the phone warm. We have not found the cause yet.
- Movies and subtitles drift apart below 60 fps. A fix from oliverames is in the engine but not turned on, because it needs a 30 fps cap.
- Some surfaces can show as flat single-colour shapes with hard edges. We don't know yet whether this update changes that.

**To update:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone. This update changes the shaders, so every shader is compiled again: the rebuild took about 2 hours on our Mac. Keep the Mac awake and plugged in while it runs, because sleep pauses it. The first "Preparing shaders" on the phone takes a few minutes. If the first session after that feels slow, close the game fully and reopen it.

## 1.6

Wide view now shows more of the game, plus 14 engine fixes from nxnative. **This update has been built but not played on a phone yet**, so please share your game log (**Get game log**) if something looks or runs wrong.

**Fixed: Wide view stretched the picture.** In 1.5 and 1.5.1 the game rendered a wider picture, but its cameras still used a 16:9 view, so Wide view stretched the picture instead of showing more. The 1.5 notes said nothing was stretched, and the 1.5.1 notes didn't mention it; both were wrong. Now the camera uses your screen's shape: the view keeps its height and shows more at the sides. If things pop in or vanish at the left and right edges, or the HUD or menus look wrong, please send your log.

**From nxnative:**
- **Terrain:** ground tiles no longer vanish or show another tile's surface after you walk a while. This may be the cause of the flat single-colour shapes some players saw, but that isn't confirmed.
- **Death Mountain Trail:** the light-blue dashes over the rock at the cave entrance are gone.
- **GPU:** a faster check in the shaders that mark which memory each pass used (measured on an Apple M6, not an iPhone).
- **Memory and storage:** freed GPU memory is released sooner when the game pauses its drawing, textures are no longer read again when nothing changed them, and the game's files give disk space back (an iPad had stopped the game at 5 GB free).
- Fixes for textures that change size, for presenting frames, and the iOS build fix that 1.5 already carried.

**To update:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone. This update changes the shaders, so every shader is compiled again: the rebuild took about 2 hours of work on our Mac. Keep the Mac awake while it runs, because sleep pauses it. The first "Preparing shaders" on the phone takes a few minutes. If the first session after that feels slow, close the game fully and reopen it.

## 1.5.1

A small fix update for 1.5: the same engine, with its Wide view and Mobile controls corrected. **This update has been built but not played on a phone yet**, so please share your game log (**Get game log**) if something looks or runs wrong.

**Fixed: Wide view still showed black bars.** In 1.5 the game rendered the wider picture, but the display step still laid it out as 16:9, so the bars stayed even though the 1.5 notes said they were gone. The display step now gets the picture's real shape. Wide view works on screens from 1.8:1 to 2.6:1, which covers regular iPhones. The iPhone Duo's unfolded screen stays 16:9, with black bars.

**Fixed: Mobile buttons now show what they do.** The icons didn't match the game's actions. The layout is now Y sword, A action, B back, X jump, R shield and ZL Navi, and there's a new ZR button for the held item. This mapping hasn't been checked against every in-game action yet, so please tell us if a button still looks wrong.

**Fixed: Mobile now follows the colour theme.** Its buttons change with **Touch controls style** (Classic, Forest or Glass), like the other layouts.

**To update:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone. The shaders didn't change, so if you already built 1.5 none of them are compiled again and "Preparing shaders" on the phone stays short. The rebuild still checks them and packs the app, which took about 2 hours on our Mac.

## 1.5

New controls, a wide view for iPhones, and an engine update. **This update has been built but not played on a phone yet**, so please share your game log (**Get game log**) if something looks or runs wrong.

**New: a glass look for the on-screen controls.** All the layouts now use nearly clear buttons with a bright rim and a light-blue press. You can go back to the older look under **Touch controls style** in the game's launcher.

**New: Mobile control layout.** A choice next to 2D, 3D and Tap in the in-game menu: a floating left stick that appears where your thumb lands, the camera on the right half of the screen, round glass buttons with icons and letter chips, and a small D-pad above the stick. (Inspired by cheemu21, creator of kid-with-sword; from the kid-with-sword fork of nxnative.)

**New: Wide view (optional, off by default).** Turn on **Wide view** in the game's launcher and the game renders your screen's real shape: you see more at the sides, with no black bars and nothing stretched. It applies the next time the game starts. It draws about a fifth more pixels, so turn it off if your frame rate suffers. The HUD and movies stay in the middle 16:9 area, and a few cutscenes or effects may look off at the edges. (From nxnative pull request 1460 by vladbondarenko97.)

**New: your own app name and icon.** On the **Choose your iPhone** step, you can name the app and pick any PNG or JPEG as its icon. Leave them empty for the game's own.

**New: small game file updates.** On the **Play** step, HookLink compares the small files on your iPhone (such as the resolution file) with the current ones and sends only what changed. It runs by itself after a build when your iPhone is plugged in, and there's a button for it. Your 24 GB of game files and your saves aren't touched.

**iPhone Duo in the phone list.** It uses the same chip as the iPhone 18 Pro, so it shares that choice. It hasn't been tested on a Duo, and the Duo's unfolded screen still shows black bars.

**Changed: fewer waits on the GPU.** The game can now keep 32 batches of GPU work in flight instead of 8. On some runs in Hyrule Field it kept stopping to wait for a free slot and fell to about 20 fps. This is aimed at that slowdown, but its effect hasn't been measured on a phone yet.

**Also from nxnative:** the title movie's upscaling network takes about half the GPU time (measured on an M4 Pro Mac, not an iPhone), mesh-shader models no longer pick up ambient light from the wrong place, fixes for occlusion and memory reads, and faster handling of the pipeline archive.

**Known issues**
- Hyrule Field and other busy areas can drop into the 40s and 50s once the phone warms up, because iOS slows the CPU.
- Some surfaces can show as flat single-colour shapes with hard edges. We don't know the cause yet, and this update may or may not fix it. If you see it, please send your log.

**To update:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone. This update changes the shaders, so the rebuild is long (about 3 hours on an M-series Mac), and the first "Preparing shaders" on the phone takes a few minutes. If the first session after that feels slow, close the game fully and reopen it.

## 1.4

An engine update for smoother play in the busy areas, from a 31-minute run from Kokiri Forest to Castle Town on an iPhone 18 Pro Max.

**Fixed: freezes of 1–4 seconds the first time you reach new areas** (Hyrule Field, Castle Town).
The game draws its foliage, shadows and enemies with mesh shaders. The engine wasn't counting, saving or preparing those shaders, so each new one was built at the moment it was first drawn, freezing the game. They are now prepared during "Preparing shaders", saved, and loaded from the save on later starts. The built-in list covers Kokiri Forest, Hyrule Field, Castle Town and Hyrule Castle. (From nxnative, by seedds and nanotchec, with rows from several players; one more row from our own test.)

**Improved: Hyrule Field and the road to the castle dropping to 35–55 fps.**
iOS decides which CPU cores each thread runs on from its class. The thread that sends each frame to the GPU was in a lower class, which tells iOS its work can wait, so iOS kept it on the phone's slower efficiency cores, at about 1.6 GHz instead of 3.7. Hyrule Field draws about 4× as much per frame as Kokiri Forest, so it fell behind even though the GPU had time to spare. That thread now always runs in the top class. The cause is confirmed in the logs; how close this brings Hyrule Field to 60 fps hasn't been measured on a phone yet, so please share your log if it still drops.

**Changed: memory for the game's render targets.**
Tested on the phone: about 4 GB to spare in Hyrule Field, more than 1.3. The shared memory layout for render targets (from an nxnative pull request) is replaced by nxnative's own render-target recycling. nxnative found the old layout can corrupt the picture. The new one reuses a freed target's memory for the next one that fits, so dynamic resolution changes no longer pile up memory.

**Also from nxnative:** dynamic resolution climbs back to full size based on the measured load, the bundled pipeline archive is mapped instead of read into memory, and fixes for paused threads and exclusive memory access.

**To update:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone. This update changes the shaders, so the rebuild takes longer than usual (about an hour on an M-series Mac), and the first "Preparing shaders" on the phone takes a few minutes. If the first session after that feels slow, close the game fully and reopen it.

## 1.3

- **Save backups:** **Back up my saves** and **Restore a backup…** on the Play step. Backups go to `Documents/HookLink Save Backups` on your Mac. HookLink backs up your saves by itself before copying game files, and before restoring. A restore copies one file at a time and checks each one.
- **Clearer errors:** a wrong Xcode / Metal compiler, a full disk or a missing tool now says what to do in plain words.
- **Damaged dumps:** the build step lists the damaged textures it found.
- **Tips:** if the first session after installing feels slow, close the game fully and reopen it. Never delete the game to reinstall (that deletes its saves).

## 1.2

- **Engine download that can't get stuck:** the download shows its progress, and if it receives nothing for a minute HookLink stops it and tries again (up to 3 times), instead of waiting forever.
- **Version panel** at the bottom of the sidebar, always visible: your HookLink version and engine version (commit and date), whether each is up to date, when HookLink last checked, and a **Check now** button. An available update shows in orange and is clickable; a check that couldn't reach GitHub says so instead of looking up to date.

## 1.1

**Fixed: the game crashed on its first frame after "Preparing shaders", on every launch.**
The patch that keeps the game at real speed when frames run long has two jumps that skip to the game's own code while the frame pacing isn't decided yet, which is the case on the very first frames. Extra instructions added for the real-speed fix sat between those jumps and their target, so the jumps landed in the middle of the new code and the game crashed (an access at address 0x3c). The jumps are now computed from the code instead of fixed, a check stops the build if they ever don't line up, and a new test runs the patch on an ARM emulator for the first frames, 60 fps, slow frames, the 30 fps step and the pacing turned off.

**To update:** open HookLink and click **Update and rebuild** on the update banner, then install the new app over the old one. Your saves and game files stay on the phone.

## 1.0

The first version of HookLink, tested on one Mac and one iPhone 18 Pro Max (iOS 27.2).

**The app**
- Step-by-step builder: checks the Mac and installs missing tools, takes your own `.nup`, builds the iPhone app, guides the install, and copies the game files and the iPhone resolution file to the phone, then checks them.
- Progress card on every long task: overall and per-step bars, elapsed time, and the latest activity, so quiet steps don't look frozen.
- Copy with Finder instead, for when the cable copy keeps stopping.
- Get game log and Share my pipeline list, for bug reports and for improving everyone's first start.
- Update checks at every launch: engine updates with Update and rebuild, and new HookLink releases.

**The engine** (nxnative, HookLink branch)
- Built on nxnative's latest Ocarina of Time work (GPU, occlusion, mesh shaders, shader math, mist).
- Pipelines: failed archive searches aren't repeated every draw; a faster lookup for waiting builds; every pipeline the game asks for is prepared at the next start.
- A pipeline list for Kokiri Forest, Hyrule Field, Castle Town and Hyrule Castle, built in.
- Memory: render targets in one placement heap; idle textures of old scenes retired under memory pressure (the freeze after Saria).
- Real-time game speed below 60 fps, without a 30 fps hold.

**Known issues**
- Hyrule Field can dip into the 40s–50s fps when the phone is warm.
- The first start after installing prepares shaders for a few minutes.
- iPhone 17 models are untested.
- A damaged dump builds, but its damaged textures may look wrong.
