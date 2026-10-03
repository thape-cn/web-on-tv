# TIANHUA Reception Display

A native, silent DragonRuby reception-TV presentation for 上海天华建筑设计有限公司. It plays local architectural photography, bilingual project titles, a welcome scene and a three-project collection automatically. No browser, Rails server, database, network connection, guest records or visitor input is needed at runtime.

## Start and stop

Use a separately installed, licensed DragonRuby runtime. Tested with DragonRuby **7.21 Pro** on Linux using the native OpenGL window.

```sh
DRAGONRUBY_HOME=/path/to/licensed/dragonruby ./scripts/run.sh
```

Or start from the licensed runtime directory after cloning this repository:

- macOS / Linux: `./dragonruby /absolute/path/to/web-on-tv`
- Windows PowerShell: `.\dragonruby.exe "C:\path\to\web-on-tv"`

Use the **7.21 Pro** download for the target OS. Only Linux was tested here; macOS and Windows commands are the equivalent runtime launch forms, not claims of platform QA.

Without `DRAGONRUBY_HOME`, the launcher uses `/workspace/shared/dragonruby/current`. It checks for an executable `dragonruby`, changes into the runtime directory and launches this project by absolute path. The runtime is external and is not redistributed with this repository. Do not commit a runtime, license files or credentials.

The display opens fullscreen and hides the pointer. There are no on-screen buttons, links or visitor controls, and no audio. Operators exit with the OS window-close action or **Alt+F4**. Use the OS display settings to select the TV and its native resolution before starting.

## Display and sequence

- Layout uses a **1280 × 720 logical canvas**. DragonRuby HD mode and linear scaling are enabled in `metadata/game_metadata.txt` for 1080p and 4K displays; photographic source resolution still limits image detail.
- Use a **16:9 TV/output mode** for edge-to-edge presentation. A 4:3 output preserves the composition with letterboxing rather than stretching it.
- The loop is **117 seconds**: opening 21s; three hero projects at 14s each; collection 12s; three more heroes at 14s each. It repeats automatically.
- Smooth 2-second dissolves occur inside each scene's allotted duration, including the last-to-first transition. Gentle source-image pan/zoom fills each photo viewport without distorting the image.

## Opening choreography

The 21-second opening begins on an entirely white canvas. Meaningful architectural lines build rapidly, while photographic development is deliberately slower. Every contour is drawn with native DragonRuby line primitives, not a still sketch uncovered by a mask.

- 0–0.65s: blank white sheet
- 0.65–8.5s: accelerated waterfront, roofs, eaves, façade bays, glazing, parapets and courtyard detail; introduction appears gently during the drawing
- 8–18s: ten-second photographic development, with a subtle early tint while the last small details finish
- 12–18.5s: the complete pencil drawing recedes gradually over the photograph
- 18–21s: full photographic composition; outgoing dissolve remains in the last 2s

Smooth, editable contour curves follow the waterfront and planted banks. Tree crowns use continuous curved outlines; straight building geometry stays straight. Roof seams, selected tile courses and glazing rhythms are architectural interpretations constrained to visible photographic planes, not claims of tracing each individual tile.

The photograph and vector paths share the same source coordinate transform. The camera remains fixed until 18.5s, after all pencil has disappeared. A dedicated 2× render target clips and smooths native linework. Compiled segment geometry and the completed native drawing are cached during the long reveal to keep playback responsive. The remaining seven scenes retain their original timing and design.

## Editing

- `app/config.rb`: six bilingual hero titles, local image paths, reference work URLs, scene order/durations, fullscreen flag and dissolve duration. URLs are provenance metadata, not runtime links or network requests.
- `app/nanhu_strokes.rb`: hand-authored architectural contours in source-photo coordinates (1920 × 968, top-left origin). Edit meaningful roofs, eaves and façade paths here; no raster sketch is used.
- `app/nanhu_architecture_detail.rb`: editable source-photo roof quadrilaterals, façade planes, parapets and architectural detail generators.
- `app/nanhu_curves.rb`: smooth waterfront and planting control points, sampled into progressively drawn native lines.
- `app/nanhu_sketch.rb`: distance-based stroke drawing, supersampled native line primitives, shared crop transform, and the drawing-to-photo choreography.
- `app/timeline.rb`: pure-Ruby scene selection, wraparound and smooth dissolve calculation. Keep scene durations positive and the fade positive and no longer than the shortest scene.
- `app/main.rb`: composition, palette, typography, welcome/service wording, three collection cards, crop handling and the optional QA capture hook. If replacing photos, maintain the expected dimensions or update the crop dimensions as well.
- `metadata/game_metadata.txt`: application identity and display/scaling settings. The layout is intentionally fixed at 16:9; changing only the width/height constants will not redesign the hardcoded compositions.
- `assets/fonts/TianhuaDisplaySans.otf`: a renamed, subsetted Chinese font. **Rebuild the subset whenever introducing new characters**, including punctuation and English symbols, or missing glyphs may appear. Include every string from config and main, retain the renamed family and bundled OFL notice, and check the result in the native runtime.

Keep all imagery and fonts local. Do not add web/database dependencies or runtime fetches merely to change presentation content. See [the asset manifest](docs/ASSETS.md) for sources and licensing boundaries.

To rebuild after editing text: `python3 scripts/build_font.py` (requires fonttools and the source Noto CJK font).

## QA and collaboration

The first 21-second revision (741 paths) completed its 117-second unattended native loop on Linux, including eight opening-stage captures, with no missing assets or systematic sketch/photo misregistration. After adding rear-building detail (917 paths total) and precompiled native-line caching, the pure Ruby suite passed 12 tests / 44,660 assertions in that environment.

**Final native revalidation is pending.** The cloud workspace was replaced before the last native run, removing the local runtime and uncommitted work. This source revision was reconstructed from the recorded source edits and the verified remote base. After reconstruction, Ruby 3.3.12 re-ran all 12 tests / 44,660 assertions successfully, and an additional six-stage comparison verified that cached line coordinates match the reference stroke geometry. The licensed DragonRuby runtime has not been restored or redistributed. The final 917-path/cached-render variant has not yet been visually validated end-to-end; do not treat the earlier 741-path run as final-render certification. Review on the intended TV is also still required for color, scaling, overscan and viewing-distance readability.

For a development capture run, create `qa/enabled.txt` before launch. The current QA hook writes eight opening-stage screenshots, one screenshot per scene, and `qa/result.txt` after a full loop plus three seconds. This records scene capture count and a maximum and 95th-percentile wall-clock frame gaps after warm-up, excluding the one-second windows following screenshot I/O; it is not a substitute for visual review or a frame-rate benchmark. Remove the marker and restart for normal operation. The `qa/` directory is ignored by Git.

Collaborate in Git using small topic branches and reviewable commits. Review code and source/license changes together; use the same separately licensed runtime version for reproducible native checks. Keep generated logs, QA captures, runtime binaries, credentials and local machine settings out of commits. The user-authorized repository is `https://github.com/thape-cn/web-on-tv`. Do not redistribute its media/runtime beyond the applicable permissions. The MIT code license does not make the photographs and Tianhua branding freely redistributable.

Run the offline timeline tests with `ruby -Itest -e 'Dir["test/*_test.rb"].each { |file| require_relative file }'`. No DragonRuby runtime is needed for this test.
