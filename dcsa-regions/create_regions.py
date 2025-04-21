import json
import geopandas as gpd
from shapely.geometry import MultiPolygon, Polygon
from shapely.ops import unary_union
from shapely.validation import make_valid
from pathlib import Path

def clean_geometry(geom):
    """Clean and validate a geometry."""
    try:
        if geom is None:
            return None
        # Make the geometry valid
        valid_geom = make_valid(geom)
        # Buffer by 0 to fix self-intersections
        cleaned = valid_geom.buffer(0)
        return cleaned
    except Exception as e:
        print(f"Error cleaning geometry: {e}")
        return None

def create_regions():
    # Read the counties data which defines the regions and their constituent counties
    counties_input_path = 'dcsa-regions/counties-in-regions.json'
    with open(counties_input_path, 'r') as f:
        regions_data = json.load(f)
    print(f"Read county data for {len(regions_data)} regions from {counties_input_path}")

    # Read the districts data
    districts_input_path = 'dcsa-regions/congressional-districts-in-regions.json'
    with open(districts_input_path, 'r') as f:
        districts_data = json.load(f)
    print(f"Read district data for {len(districts_data)} regions from {districts_input_path}")

    # Create a mapping of region id to their districts
    # Use the 'id' field as it seems consistent between the two files
    region_districts = {region['id']: region['DISTRICTS'] for region in districts_data}

    # Read the base counties GeoJSON
    counties_geojson_path = 'maps/NTAD_Counties-simplified.topojson'
    counties_gdf = gpd.read_file(counties_geojson_path)
    print(f"Read base county shapes from {counties_geojson_path}")

    # Create a list to store the combined region features
    combined_features = []

    # Process each region defined in the counties data
    for region in regions_data:
        region_id = region['id']
        region_name = region['REGION']
        county_geoids = region['COUNTIES_GEOIDS']
        print(f"Processing region: {region_name} (ID: {region_id})")

        # Filter base counties that belong to this region using GEOIDs
        region_counties_gdf = counties_gdf[counties_gdf['GEOID'].isin(county_geoids)]

        if len(region_counties_gdf) == 0:
            print(f"Warning: No counties found for region {region_name} using {len(county_geoids)} GEOIDs.")
            continue
        else:
            print(f"Found {len(region_counties_gdf)} matching counties for region {region_name}.")

        # Clean each county geometry
        cleaned_geometries = []
        for geom in region_counties_gdf.geometry:
            cleaned = clean_geometry(geom)
            if cleaned is not None:
                cleaned_geometries.append(cleaned)

        if not cleaned_geometries:
            print(f"Warning: No valid geometries after cleaning for region {region_name}")
            continue

        try:
            # Dissolve all valid geometries into a single geometry using unary_union
            unified_geometry = unary_union(cleaned_geometries)

            # Ensure the unified geometry is valid before proceeding
            if not unified_geometry.is_valid:
                print(f"Warning: Unified geometry for {region_name} is invalid, attempting to fix.")
                unified_geometry = make_valid(unified_geometry)
                # Buffer by 0 again as make_valid might introduce issues buffer(0) can fix
                unified_geometry = unified_geometry.buffer(0) 
                if not unified_geometry.is_valid:
                   print(f"Error: Could not fix invalid unified geometry for region {region_name}.")
                   continue # Skip this region if it cannot be fixed

            # Simplify the geometry to an outline (exterior ring)
            # If the result is a MultiPolygon, process each polygon
            if isinstance(unified_geometry, MultiPolygon):
                # For each polygon in the MultiPolygon, keep only its exterior ring
                exterior_rings = [Polygon(poly.exterior) for poly in unified_geometry.geoms]
                # Create a new MultiPolygon from the exterior rings if there are multiple, otherwise a single Polygon
                outline_geometry = MultiPolygon(exterior_rings) if len(exterior_rings) > 1 else exterior_rings[0]
            elif isinstance(unified_geometry, Polygon):
                 # If it's a single polygon, just keep its exterior ring
                outline_geometry = Polygon(unified_geometry.exterior)
            else:
                print(f"Warning: Unexpected geometry type ({type(unified_geometry)}) for region {region_name} after union. Skipping outline creation.")
                outline_geometry = unified_geometry # Use the unified geometry as is if type is unexpected

            # Get the districts for this region using the region ID
            districts = region_districts.get(region_id, [])
            if not districts:
                 print(f"Warning: No districts found for region {region_name} (ID: {region_id})")

            # Create a new feature for this region
            feature = {
                'type': 'Feature',
                'properties': {
                    'id': region_id,
                    'REGION': region_name,
                    'DISTRICTS': districts
                },
                'geometry': outline_geometry.__geo_interface__
            }

            combined_features.append(feature)
            print(f"Successfully processed region: {region_name}")

        except Exception as e:
            print(f"Error processing region {region_name} (ID: {region_id}): {e}")
            continue

    # Create the final GeoJSON
    geojson = {
        'type': 'FeatureCollection',
        'features': combined_features
    }

    # Save the GeoJSON result
    output_path = Path('maps/DCSA_Regions-simplified.geojson')
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w') as f:
        json.dump(geojson, f)

    print(f"\nCreated GeoJSON with {len(combined_features)} regions")
    print(f"Saved to {output_path}")

if __name__ == '__main__':
    create_regions()