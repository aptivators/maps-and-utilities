#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Get the parent directory of the script directory (workspace root)
WORKSPACE_ROOT=$(dirname "$SCRIPT_DIR")

# Paths relative to the workspace root
MAPS_DIR="$WORKSPACE_ROOT/maps"
US_STATES="$MAPS_DIR/US_States.geojson"

INPUT_STATES="$MAPS_DIR/NTAD_States.geojson"
INPUT_DISTRICTS="$MAPS_DIR/NTAD_Congressional_Districts.geojson"
INPUT_COUNTIES="$MAPS_DIR/NTAD_Counties.geojson"

TOPO_STATES="$MAPS_DIR/NTAD_States-simplified.topojson"
TOPO_DISTRICTS="$MAPS_DIR/NTAD_Congressional_Districts-simplified.topojson"
TOPO_COUNTIES="$MAPS_DIR/NTAD_Counties-simplified.topojson"

# Temporary files
TEMP_CLIPPED_STATES=$(mktemp)
TEMP_CLIPPED_DISTRICTS=$(mktemp)
TEMP_CLIPPED_COUNTIES=$(mktemp)
TEMP_TOPO_STATES=$(mktemp)
TEMP_TOPO_DISTRICTS=$(mktemp)
TEMP_TOPO_COUNTIES=$(mktemp)

# Verify input files
if [ ! -f "$US_STATES" ]; then
    echo "Error: $US_STATES does not exist."
    exit 1
fi

if [ ! -f "$INPUT_STATES" ]; then
    echo "Error: $INPUT_STATES does not exist."
    exit 1
fi

if [ ! -f "$INPUT_DISTRICTS" ]; then
    echo "Error: $INPUT_DISTRICTS does not exist."
    exit 1
fi

if [ ! -f "$INPUT_COUNTIES" ]; then
    echo "Error: $INPUT_COUNTIES does not exist."
    exit 1
fi

# Step 1: Clip districts and states using Python script
echo "Clipping states, districts, and counties to US boundary..."
python3 - <<EOF
import geopandas as gpd

try:
    # Load files
    us_states = gpd.read_file("$US_STATES")
    states = gpd.read_file("$INPUT_STATES")
    districts = gpd.read_file("$INPUT_DISTRICTS")
    counties = gpd.read_file("$INPUT_COUNTIES")

    # Ensure CRS match
    if states.crs != us_states.crs:
        states = states.to_crs(us_states.crs)
    if districts.crs != us_states.crs:
        districts = districts.to_crs(us_states.crs)
    if counties.crs != us_states.crs:
        counties = counties.to_crs(us_states.crs)

    # Clip states, districts, and counties to US boundary
    clipped_states = gpd.clip(states, us_states)
    clipped_districts = gpd.clip(districts, us_states)
    clipped_counties = gpd.clip(counties, us_states)

    # Save clipped outputs to temp files
    clipped_states.to_file("$TEMP_CLIPPED_STATES", driver="GeoJSON")
    clipped_districts.to_file("$TEMP_CLIPPED_DISTRICTS", driver="GeoJSON")
    clipped_counties.to_file("$TEMP_CLIPPED_COUNTIES", driver="GeoJSON")

except Exception as e:
    print(f"Error in Python script: {e}")
    exit(1)
EOF

# Verify intermediate outputs
if [ ! -f "$TEMP_CLIPPED_STATES" ] || [ ! -f "$TEMP_CLIPPED_DISTRICTS" ] || [ ! -f "$TEMP_CLIPPED_COUNTIES" ]; then
    echo "Error: Clipping failed. Check the input files and Python script."
    exit 1
fi

# Step 2: Convert clipped GeoJSON to TopoJSON
echo "Converting clipped GeoJSON to TopoJSON..."
geo2topo states="$TEMP_CLIPPED_STATES" > "$TEMP_TOPO_STATES" || exit 1
geo2topo congressional-districts="$TEMP_CLIPPED_DISTRICTS" > "$TEMP_TOPO_DISTRICTS" || exit 1
geo2topo counties="$TEMP_CLIPPED_COUNTIES" > "$TEMP_TOPO_COUNTIES" || exit 1

# Verify TopoJSON outputs
if [ ! -f "$TEMP_TOPO_STATES" ] || [ ! -f "$TEMP_TOPO_DISTRICTS" ] || [ ! -f "$TEMP_TOPO_COUNTIES" ]; then
    echo "Error: TopoJSON conversion failed."
    exit 1
fi

# Step 3: Simplify TopoJSON
echo "Simplifying TopoJSON files..."
toposimplify -P 0.1 -f < "$TEMP_TOPO_STATES" > "$TOPO_STATES" || exit 1
toposimplify -P 0.1 -f < "$TEMP_TOPO_DISTRICTS" > "$TOPO_DISTRICTS" || exit 1
toposimplify -P 0.1 -f < "$TEMP_TOPO_COUNTIES" > "$TOPO_COUNTIES" || exit 1

# Cleanup temporary files
rm -f "$TEMP_CLIPPED_STATES" "$TEMP_CLIPPED_DISTRICTS" "$TEMP_CLIPPED_COUNTIES" "$TEMP_TOPO_STATES" "$TEMP_TOPO_DISTRICTS" "$TEMP_TOPO_COUNTIES"

# Completion message
echo "Process complete."
echo "Simplified TopoJSON files created:"
echo " - $TOPO_STATES"
echo " - $TOPO_DISTRICTS"
echo " - $TOPO_COUNTIES"
