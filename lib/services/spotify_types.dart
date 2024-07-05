class SpotifyArtist {
  //['external_urls', 'href', 'id', 'name', 'type', 'uri']
  final String id;
  final String name;
  final String type;
  final String uri;
  final String href;
  final Map<String, dynamic> external_urls;

  SpotifyArtist({
    required this.id,
    required this.name,
    required this.type,
    required this.uri,
    required this.href,
    required this.external_urls,
  });

  factory SpotifyArtist.fromMap(Map<String, dynamic> data) {
    return SpotifyArtist(
        id: data["id"],
        name: data["name"],
        type: data["type"],
        uri: data["uri"],
        href: data["href"],
        external_urls: data["external_urls"]
    );
  }
}

class SpotifyImages{
  final int height;
  final int width;
  final String url;

  SpotifyImages({
    required this.height,
    required this.width,
    required this.url
  });

  factory SpotifyImages.fromMap(Map<String,dynamic> data) {
    return SpotifyImages(
        height: data['height'],
        width: data['width'],
        url: data['url']
    );
  }
}

class SpotifyAlbum {
  final String album_type; // albums, single, compilation
  final String type; // album
  final String id;
  final String name;
  final String uri;
  final int count; // total_tracks
  final String href;
  final String releaseDate;
  final String releaseDatePrecision;
  final String external_urls;
  final List<String> availableMarkets;
  final List<SpotifyImages> images;
  final List<SpotifyArtist> artists;

  SpotifyAlbum({
    required Map<String, dynamic> data,
  })  : album_type = data['album_type'],
        type = data['type'],
        id = data['id'],
        name = data['name'],
        uri = data['uri'],
        count = data['total_tracks'],
        href = data['href'],
        releaseDate = data['release_date'],
        releaseDatePrecision = data['release_date_precision'],
        availableMarkets = List<String>.from(data['available_markets']),
        external_urls = data['external_urls']['spotify'], // data['external_urls']['spotify']
        images = List<SpotifyImages>.from(
          data['images'].map( (imgData) => SpotifyImages.fromMap(imgData) ), // List<dynamic>.from(data['images']),
        ),
        artists = List<SpotifyArtist>.from(
          data['artists'].map((artistData) => SpotifyArtist.fromMap(artistData) ),//
        );
}


class SpotifyCategoryItem {
  final String id;
  final String name;
  final String href; // api url
  final List icons;

  SpotifyCategoryItem({required Map<String, dynamic> data}) :
      id = data["id"],
      name = data["name"],
      href = data["href"],
      icons = data["icons"];
}


//----------------------------------------------------------------------------------------


