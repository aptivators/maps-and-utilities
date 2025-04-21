# Maps and Utilities

A collection of GeoJSON and TopoJSON resources and utilities for map-based data visualizations.

## Where to find original maps

- https://geodata.bts.gov/search?q=congressional
- https://geodata.bts.gov/search?q=counties
- https://geodata.bts.gov/search?q=states

## What is GeoJSON?

GeoJSON is an open standard format designed for representing simple geographical features, along with their non-spatial attributes. It is based on JavaScript Object Notation (JSON) and is widely used in web mapping applications.

Key features of GeoJSON:
- Represents points, lines, and polygons
- Supports multiple coordinate reference systems
- Can include properties/metadata for each feature
- Human-readable and machine-parseable format
- Native support in many web mapping libraries

Example of a simple GeoJSON point:
```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [125.6, 10.1]
  },
  "properties": {
    "name": "Dinagat Islands"
  }
}
```

## What is TopoJSON?

TopoJSON is an extension of GeoJSON that encodes topology. Rather than representing geometries discretely, geometries in TopoJSON files are stitched together from shared line segments called arcs.

Key advantages of TopoJSON:
- Smaller file sizes compared to GeoJSON
- Preserves topology between features
- Better for complex boundaries and shared borders
- More efficient for web applications
- Can be converted back to GeoJSON

## Use Cases

This repository contains:
- GeoJSON and TopoJSON files for various geographic regions
- Utilities for processing and converting between formats
- Examples of map visualizations using these formats
- Documentation and best practices

## Resources

### Official Specifications
- [GeoJSON Specification](https://tools.ietf.org/html/rfc7946)
- [TopoJSON Specification](https://github.com/topojson/topojson-specification)

### Tools and Libraries
- [GeoJSON.io](https://geojson.io/) - Online GeoJSON editor
- [Mapshaper](https://mapshaper.org/) - Online tool for simplifying and converting GeoJSON/TopoJSON
- [D3.js](https://d3js.org/) - JavaScript library for data visualization
- [Leaflet](https://leafletjs.com/) - Open-source JavaScript library for interactive maps

### Learning Resources
- [GeoJSON.org](https://geojson.org/)
- [TopoJSON Documentation](https://github.com/topojson/topojson)
- [Mapbox GeoJSON Guide](https://docs.mapbox.com/help/glossary/geojson/)
