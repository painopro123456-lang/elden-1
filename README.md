# ELDEN 1

A Windows-first Formula racing game project.

## Visual target
ELDEN 1 is being built around a premium motorsport presentation: detailed 3D vehicle assets, realistic circuit environments, physically based materials, cinematic lighting, and a readable T-cam racing view.

**Quality rule:** temporary prototype geometry is not final player-facing content. The Ferrari SF-26 model still needs to be imported before the final car presentation can be considered complete.

## Engine
Godot 4.3, using Forward+ rendering for desktop. The project targets Windows 10/11 64-bit.

## Current implementation
- Premium main-menu foundation and Grand Prix circuit picker.
- Twelve circuit selections now load mapped circuit centre-line data rather than the earlier hand-drawn placeholder loops.
- Nine circuits use GPS-derived centre-lines and estimated left/right widths from the TUMFTM racetrack database: Bahrain, Melbourne, Suzuka, Silverstone, Spa, Monza, Austin, Mexico City, and Abu Dhabi.
- Jeddah, Monaco, and Singapore use mapped GeoJSON circuit paths; the game currently applies a default road width to these three.
- Road meshes and collision surfaces are generated from the source geometry, with kerbs, barriers, start/finish line, grass environment, lighting, and sky.
- A basic keyboard-driven test car, T-cam camera, and speed readout are connected to the race scene.
- These are real mapped circuit paths, but not laser-scanned production tracks. Elevation, pit lanes, detailed runoff, venue buildings, grandstands, and exact modern configuration checks are still outstanding. See [track data sources and licenses](data/tracks/SOURCES.md).
- The test car is temporary geometry. The supplied Ferrari SF-26 model has not yet been integrated.
- AI opponents, race weekend rules, tyre simulation, damage, pit lane, and finished production-quality trackside scenery are not implemented yet.

## Controls
- W / Up Arrow: accelerate
- S / Down Arrow: brake / reverse
- A / Left Arrow: steer left
- D / Right Arrow: steer right
- Escape: return to menu

## Windows build
GitHub Actions builds a standalone Windows x64 executable whenever changes are pushed to `main`. It imports and smoke-tests the Godot project before exporting.

Open the repository's **Actions** tab, select **Build ELDEN 1 for Windows**, and download the `ELDEN-1-Windows-x64` artifact from a successful run. The artifact is an executable, not just the source project.

## Next milestones
1. Import and verify the supplied SF-26 model, then build the team livery system.
2. Replace temporary trackside geometry with venue-specific grandstands, buildings, scenery, and track markings.
3. Improve vehicle physics, tyres, braking, gears, and assists.
4. Add AI, race weekend flow, flags, penalties, damage, and HUD.
5. Add graphics settings and continue testing Windows builds.

## Running from source
Install Godot 4.3 standard desktop, open this folder's `project.godot`, and run the project.

## Asset policy
Only use assets with clear permission for the intended use or original assets created for this project. Do not bundle commercial F1 game assets or imply official Formula One licensing.
