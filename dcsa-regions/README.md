# DCSA Region GeoJSON Creation

This directory contains scripts and data to generate a simplified GeoJSON file representing DCSA regions.

## `create_regions.py`

This script combines county boundaries to create outlines for DCSA regions and associates congressional district data with each region.

### Inputs

1.  **`dcsa-regions/counties-in-regions.json`**: Defines the regions and lists the FIPS GEOIDs of the counties belonging to each region.
    *   Format: `[{"id": "region-id", "REGION": "Region Name", "COUNTIES_GEOIDS": ["fips1", "fips2", ...]}, ...]`
2.  **`dcsa-regions/congressional-districts-in-regions.json`**: Lists the congressional districts associated with each region.
    *   Format: `[{"id": "region-id", "REGION": "Region Name", "DISTRICTS": ["DISTRICT-1", "DISTRICT-2", ...]}, ...]`
    *   The `id` field should match the `id` field in `counties-in-regions.json`.
3.  **`maps/NTAD_Counties-simplified.topojson`**: A TopoJSON file containing the base geometries for all US counties. The script filters this based on the GEOIDs provided in `counties-in-regions.json`.

### Output

*   **`maps/DCSA_Regions-simplified.geojson`**: A GeoJSON FeatureCollection where each feature represents a DCSA region. The geometry is the dissolved outline of the constituent counties, and the properties include the region ID, region name, and the list of associated congressional districts.

### Setup

It is recommended to use a Python virtual environment.

1.  **Create virtual environment (if needed):**
    ```bash
    python -m venv .venv
    ```
    *(Replace `python` with your Python 3 executable, e.g., `/opt/homebrew/bin/python3` if necessary)*

2.  **Activate virtual environment:**
    ```bash
    source .venv/bin/activate
    ```
    *(On Windows, use `.venv\Scripts\activate`)*

3.  **Install dependencies:**
    ```bash
    pip install -r dcsa-regions/requirements.txt
    ```
    *(Or use `./.venv/bin/python -m pip install ...` if `pip` doesn't point to the venv)*

### Running the Script

Make sure your virtual environment is activated and you are in the project's root directory (`maps-and-utilities`).

```bash
python dcsa-regions/create_regions.py
```
*(Or use `./.venv/bin/python dcsa-regions/create_regions.py` if `python` doesn't point to the venv)* 