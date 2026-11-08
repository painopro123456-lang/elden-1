# Circuit geometry sources

ELDEN 1 uses third-party circuit geometry datasets for its prototype circuit meshes.

## TUMFTM racetrack database
The following CSV files are from https://github.com/TUMFTM/racetrack-database:
- Austin.csv
- Melbourne.csv
- MexicoCity.csv
- Monza.csv
- Sakhir.csv
- Silverstone.csv
- Spa.csv
- Suzuka.csv
- YasMarina.csv

The upstream project states that its centre lines were derived from OpenStreetMap GPS points, smoothed, and paired with widths estimated from satellite imagery. Its track data columns are x (metres), y (metres), right track width (metres), and left track width (metres). The upstream repository is licensed under GNU LGPL v3.0; see https://github.com/TUMFTM/racetrack-database/blob/master/LICENSE.

## Sergio Sediq F1 circuits dataset
The following GeoJSON files are from https://github.com/SergioSediq/f1-circuits:
- Jeddah.geojson
- Monaco.geojson
- Singapore.geojson

The upstream project provides GeoJSON circuit paths and identifies its dataset as MIT licensed. See https://github.com/SergioSediq/f1-circuits/blob/main/LICENSE.md.

## Accuracy notes
These are real mapped circuit paths, not hand-drawn placeholder loops. The TUMFTM dataset also supplies estimated track widths. For the three GeoJSON tracks, the game currently uses a default width because the files provide a path rather than left/right width measurements. Elevation profiles, pit lanes, runoff, barriers, grandstands, and venue-specific scenery still need separate modelling and verification. Monaco's supplied GeoJSON is catalogued as the 1929 circuit record, so its match to the modern Grand Prix configuration must be checked before calling it an exact current-layout reproduction.

The datasets are unofficial and are not endorsed by Formula One or the circuit owners.
