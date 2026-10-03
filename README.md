# TIANHUA Reception Display

A native, silent DragonRuby reception-TV presentation for 上海天华建筑设计有限公司. It plays local architectural photography, bilingual project titles, a welcome scene and a three-project collection automatically. No browser, Rails server, database, network connection, guest records or visitor input is needed at runtime.

## Start and stop

Use a separately installed, licensed DragonRuby runtime. Tested with DragonRuby **7.21 Pro** on Linux using the native OpenGL window.

```sh
DRAGONRUBY_HOME=/path/to/licensed/dragonruby ./scripts/run.sh
```

Without `DRAGONRUBY_HOME`, the launcher uses `/workspace/shared/dragonruby/current`. It checks for an executable `dragonruby`, changes into the runtime directory and launches this project by absolute path. The runtime is external and is not redistributed with this repository. Do not commit a runtime, license files or credentials.

The display opens fullscreen and hides the pointer. There are no on-screen buttons, links or visitor controls, and no audio. Operators exit with the OS window-close action or **Alt+F4**. Use the OS display settings to select the TV and its native resolution before starting.

## Display and sequence

- Layout uses a **1280 × 720 logical canvas**. DragonRuby HD mode and linear scaling are enabled in `metadata/game_metadata.txt` for 1080p and 4K displays; photographic source resolution still limits image detail.
- Use a **16:9 TV/output mode** for edge-to-edge presentation. A 4:3 output preserves the composition with letterboxing rather than stretching it.
- The loop is **106 seconds**: welcome 10s; three hero projects at 14s each; collection 12s; three more heroes at 14s each. It repeats automatically.
- Smooth 2-second dissolves occur inside each scene's allotted duration, including the last-to-first transition. Gentle source-image pan/zoom fills each photo viewport without distorting the image.

## Editing

- `app/config.rb`: six bilingual hero titles, local image paths, reference work URLs, scene order/durations, fullscreen flag and dissolve duration. URLs are provenance metadata, not runtime links or network requests.
- `app/timeline.rb`: pure-Ruby scene selection, wraparound and smooth dissolve calculation. Keep scene durations positive and the fade positive and no longer than the shortest scene.
- `app/main.rb`: composition, palette, typography, welcome/service wording, three collection cards, crop handling and the optional QA capture hook. If replacing photos, maintain the expected dimensions or update the crop dimensions as well.
- `metadata/game_metadata.txt`: application identity and display/scaling settings. The layout is intentionally fixed at 16:9; changing only the width/height constants will not redesign the hardcoded compositions.
- `assets/fonts/TianhuaDisplaySans.otf`: a renamed, subsetted Chinese font. **Rebuild the subset whenever introducing new characters**, including punctuation and English symbols, or missing glyphs may appear. Include every string from config and main, retain the renamed family and bundled OFL notice, and check the result in the native runtime.

Keep all imagery and fonts local. Do not add web/database dependencies or runtime fetches merely to change presentation content. See [the asset manifest](docs/ASSETS.md) for sources and licensing boundaries.

To rebuild after editing text: `python3 scripts/build_font.py` (requires fonttools and the source Noto CJK font).

## QA and collaboration

Native QA completed a full unattended 106-second loop and clean restart on the cloud Linux desktop. All eight scenes, Chinese/English glyphs, longest title, photo crops, crossfades and wraparound were checked; no missing non-ASCII glyphs were found. The pure Ruby suite passed 5 tests / 25,508 assertions. Before deployment, still review scaling, color and overscan on the intended physical TV; that hardware was not available for this check.

For a development capture run, create `qa/enabled.txt` before launch. The current QA hook writes one screenshot per scene and `qa/result.txt` after a full loop plus three seconds. This records scene capture count and a maximum wall-clock frame gap after warm-up; it is not a substitute for visual review or a frame-rate benchmark. Remove the marker and restart for normal operation. The `qa/` directory is ignored by Git.

Collaborate in Git using small topic branches and reviewable commits. Review code and source/license changes together; use the same separately licensed runtime version for reproducible native checks. Keep generated logs, QA captures, runtime binaries, credentials and local machine settings out of commits. The user-authorized repository is `https://github.com/thape-cn/web-on-tv`. Do not redistribute its media/runtime beyond the applicable permissions. The MIT code license does not make the photographs and Tianhua branding freely redistributable.

Run the offline timeline tests with `ruby test/timeline_test.rb`. No DragonRuby runtime is needed for this test.
