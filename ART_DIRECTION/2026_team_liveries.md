# 2026 Team Cars — Shared Base Model Plan

## Scope decision

ELDEN 1 will use the uploaded Ferrari SF-26 GLB as the shared base 3D car for the initial 2026 grid. We will not require eleven separate vehicle meshes.

All teams share the same base geometry. Team identity is created through:
- Team-specific paint and material colours.
- Team logos and sponsor decals placed on the nose, front wing, sidepods, engine cover and rear wing where suitable.
- Team name and driver number.
- Consistent high-resolution materials and decal placement.

This is a livery-based representation, not a claim that every team's aerodynamic bodywork is modelled exactly.

## 2026 grid

Create distinct liveries for:
1. Ferrari
2. McLaren
3. Mercedes
4. Red Bull Racing
5. Aston Martin
6. Williams
7. Alpine
8. Haas
9. Racing Bulls
10. Audi
11. Cadillac

Sponsor and partner marks must be checked against reliable current 2026 team references before being added. Do not invent sponsor names or present unofficial branding as official.

## Camera

The primary driving camera is a T-cam / onboard camera:
- Mounted above the cockpit near the airbox/halo area.
- Forward-facing, aligned with the car centreline.
- Stable horizon and sensible field of view.
- Camera position must be adjustable after testing in-game.
- Keep a separate chase/garage inspection camera for menus and vehicle viewing if useful.

## Quality requirements

- Preserve the SF-26 model's mesh, halo, wheels, wings, suspension and embedded materials.
- Do not replace the model with primitives or a low-poly placeholder.
- Avoid stretching sponsor logos; use decals/material textures mapped to the bodywork.
- Keep team liveries visually distinct and readable at racing distance.
- Test the GLB import and camera in Godot before claiming the car is integrated.

## Asset status

The user supplied a ZIP containing `f1_2026_sf26.glb` and embedded model textures. The binary model has not yet been committed to the GitHub repository or verified in Godot.
