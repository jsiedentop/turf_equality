import 'package:turf/explode.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';

typedef EqualityObjectComparator = bool Function(dynamic obj1, dynamic obj2);

class Equality {
  /// Decides the number of digits after . in a double
  final int precision;

  /// Even if the LineStrings are reverse versions of each other but the have similar
  /// [Position]s, they will be considered the same.
  final bool direction;

  /// If true, consider two [Polygon]s with shifted [Position]s as the same.
  final bool shiftedPolygon;
  final EqualityObjectComparator objectComparator;

  Equality({
    this.precision = 17,
    this.direction = false,
    this.shiftedPolygon = false,
    this.objectComparator = _deepEqual,
  });

  bool _compareTypes<T extends GeoJSONObject>(
      GeoJSONObject? g1, GeoJSONObject? g2) {
    return g1 is T && g2 is T;
  }

  bool compare(GeoJSONObject? g1, GeoJSONObject? g2) {
    if (g1 == null && g2 == null) {
      return true;
    } else {
      if (_compareTypes<Point>(g1, g2)) {
        return g1 == g2;
      } else if (_compareTypes<LineString>(g1, g2)) {
        return _compareLine(g1 as LineString, g2 as LineString);
      } else if (_compareTypes<Polygon>(g1, g2)) {
        return _comparePolygon(g1 as Polygon, g2 as Polygon);
      } else if (_compareTypes<Feature>(g1, g2)) {
        return compare((g1 as Feature).geometry, (g2 as Feature).geometry) &&
            g1.id == g2.id;
      } else if (_compareTypes<FeatureCollection>(g1, g2)) {
        for (var i = 0; i < (g1 as FeatureCollection).features.length; i++) {
          if (!compare(g1.features[i], (g2 as FeatureCollection).features[i])) {
            return false;
          }
        }
      } else if (_compareTypes<GeometryCollection>(g1, g2)) {
        return compare(
          FeatureCollection(
            features: (g1 as GeometryCollection)
                .geometries
                .map((e) => Feature(geometry: e))
                .toList(),
          ),
          FeatureCollection(
            features: (g2 as GeometryCollection)
                .geometries
                .map((e) => Feature(geometry: e))
                .toList(),
          ),
        );
      } else if (_compareTypes<MultiPoint>(g1, g2)) {
        return compare(
          FeatureCollection(
            features: (g1 as MultiPoint)
                .coordinates
                .map((e) => Feature(geometry: Point(coordinates: e)))
                .toList(),
          ),
          FeatureCollection(
              features: (g2 as MultiPoint)
                  .coordinates
                  .map((e) => Feature(geometry: Point(coordinates: e)))
                  .toList()),
        );
      } else if (_compareTypes<MultiLineString>(g1, g2)) {
        return compare(
          FeatureCollection(
            features: (g1 as MultiLineString)
                .coordinates
                .map((e) => Feature(geometry: LineString(coordinates: e)))
                .toList(),
          ),
          FeatureCollection(
              features: (g2 as MultiLineString)
                  .coordinates
                  .map((e) => Feature(geometry: LineString(coordinates: e)))
                  .toList()),
        );
      } else if (_compareTypes<MultiPolygon>(g1, g2)) {
        return compare(
          FeatureCollection(
            features: (g1 as MultiPolygon)
                .coordinates
                .map((e) => Feature(geometry: Polygon(coordinates: e)))
                .toList(),
          ),
          FeatureCollection(
              features: (g2 as MultiPolygon)
                  .coordinates
                  .map(
                    (e) => Feature(geometry: Polygon(coordinates: e)),
                  )
                  .toList()),
        );
      }
    }
  }

  _compareLine(LineString line1, LineString line2) {
    return false;
  }

  _comparePolygon(Polygon poly1, Polygon poly2) {
    return false;
  }
}
