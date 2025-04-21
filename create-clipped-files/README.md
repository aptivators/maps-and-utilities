# Map Processing Script (`process-maps.sh`)

This script automates the processing of geographical map data for US states, congressional districts, and counties.

## Functionality

1.  **Input:** Takes GeoJSON files for US states, congressional districts, and counties as input, along with a GeoJSON file defining the US boundary.
2.  **Clipping:** Clips the input state, district, and county maps to the boundaries of the US using a Python script with `geopandas`. It essentially uses the `US_States.geojson` file as a mask or cookie-cutter to remove any parts of the other maps that fall outside the US borders.
3.  **Conversion:** Converts the clipped GeoJSON files into TopoJSON format using `geo2topo`.
4.  **Simplification:** Simplifies the geometry of the TopoJSON files using `toposimplify` to reduce file size while preserving essential shapes.
5.  **Output:** Saves the final simplified TopoJSON files to the `maps` directory.

## Dependencies

*   `geopandas` (Python library)
*   `geo2topo` (part of `topojson`)
*   `toposimplify` (part of `topojson`)

## Usage

Navigate to the `create-clipped-files` directory and run the script:

```bash
cd create-clipped-files
bash process-maps.sh
```

The script will:
- Check for the existence of necessary input files in the `maps` directory.
- Perform the clipping, conversion, and simplification steps.
- Output the simplified TopoJSON files (`NTAD_States-simplified.topojson`, `NTAD_Congressional_Districts-simplified.topojson`, `NTAD_Counties-simplified.topojson`) into the `maps` directory.
- Clean up temporary files.
