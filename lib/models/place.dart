class Place {
  final String placeId;
  final String title;
  final String description;
  final String imageUrl;
  final double lat;
  final double lng;

  Place(
    this.placeId,
    this.title,
    this.description,
    this.imageUrl,
    this.lat,
    this.lng,
  );

  factory Place.fromJson(dynamic json) {
    return Place(
      json['placeId'] as String,
      json['title'] as String,
      json['description'] as String,
      json['imageUrl'] as String,
      json['lng'] as double,
      json['lng'] as double,
    );
  }

  @override
  String toString() {
    return '{ ${this.placeId}, ${this.title}, ${this.description} , ${this.imageUrl}, ${this.lat}, ${this.lng} }';
  }
}
