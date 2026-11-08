# ELDEN 1

A Windows-first Formula racing game project.

## Visual target
ELDEN 1 is being built around a premium motorsport presentation: detailed 3D vehicle assets, realistic circuit environments, physically based materials, cinematic lighting, and a readable T-cam racing view.

**Quality rule:** placeholder cubes, primitive polygon cars, and unfinished greybox tracks are not acceptable as final player-facing content. If a required production asset is not ready, the feature stays clearly marked as work in progress.

## Engine
Godot 4.3, using Forward+ rendering for desktop. The project targets Windows 10/11 64-bit.

## Current status
The premium main-menu foundation is in the project. Race gameplay and the imported Ferrari model are not yet integrated, so this is not yet a playable racing game.

## Windows build
GitHub Actions builds a standalone Windows x64 executable whenever changes are pushed to `main`. It imports and smoke-tests the Godot project before exporting.

Open the repository's **Actions** tab, select **Build ELDEN 1 for Windows**, and download the `ELDEN-1-Windows-x64` artifact from a successful run. The artifact is an executable, not just the source project.

## Planned milestones
1. Complete and verify the premium menu presentation.
2. Integrate the supplied SF-26 model and team livery system, with T-cam camera.
3. Build a detailed test circuit with believable trackside assets and lighting.
4. Implement vehicle physics, tyres, braking, gears, and assists.
5. Add race weekend flow, AI, flags, penalties, damage, and HUD.
6. Add graphics settings and verified Windows builds.

## Running from source
Install Godot 4.3 standard desktop, open this folder's `project.godot`, and run the project.

## Asset policy
Only use assets with clear permission for the intended use or original assets created for this project. Do not bundle commercial F1 game assets or imply official Formula One licensing.
