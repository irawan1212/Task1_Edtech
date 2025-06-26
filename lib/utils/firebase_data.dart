enum RoomType {
  coWorking('Co Working'),
  meetingRoom('Meeting Room'),
  roomEvent('Room Event');

  const RoomType(this.displayName);
  final String displayName;

  static RoomType fromString(String value) {
    switch (value) {
      case 'Co Working':
        return RoomType.coWorking;
      case 'Meeting Room':
        return RoomType.meetingRoom;
      case 'Room Event':
        return RoomType.roomEvent;
      default:
        return RoomType.coWorking;
    }
  }
}

class Country {
  String id;
  String name;

  Country({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameCountry': name,
      };

  static Country fromJson(String id, Map<dynamic, dynamic> json) {
    return Country(
      id: id,
      name: json['nameCountry'] ?? '',
    );
  }
}

class Location {
  String id;
  String idCountry;
  String nameCity;
  String? urlimageCity;
  double? latitude;
  double? longitude;

  Location({
    required this.id,
    required this.idCountry,
    required this.nameCity,
    this.urlimageCity,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'idCountry': idCountry,
        'nameCity': nameCity,
        'urlimageLocations': urlimageCity,
        'latitude': latitude,
        'longitude': longitude,
      };

  static Location fromJson(String id, Map<dynamic, dynamic> json) {
    return Location(
      id: id,
      idCountry: json['idCountry'] ?? '',
      nameCity: json['nameCity'] ?? '',
      urlimageCity: json['urlimageLocations'] ?? '',
      latitude: (json['latitude'] is String
              ? double.tryParse(json['latitude'])
              : json['latitude']?.toDouble()) ??
          0.0,
      longitude: (json['longitude'] is String
              ? double.tryParse(json['longitude'])
              : json['longitude']?.toDouble()) ??
          0.0,
    );
  }
}

class Promo {
  String id;
  String namePromo;
  double discount;
  String? urlimagePromo;

  Promo({
    required this.id,
    required this.namePromo,
    required this.discount,
    this.urlimagePromo,
  });

  Map<String, dynamic> toJson() => {
        'namePromo': namePromo,
        'discount': discount,
        'urlimagePromos': urlimagePromo,
      };

  static Promo fromJson(String id, Map<dynamic, dynamic> json) {
    double discountValue = 0.0;
    if (json['discount'] != null) {
      if (json['discount'] is String) {
        discountValue = double.tryParse(json['discount']) ?? 0.0;
        if (discountValue > 1) {
          discountValue = discountValue / 100;
        }
      } else if (json['discount'] is num) {
        discountValue = json['discount'].toDouble();
      }
    }

    return Promo(
      id: id,
      namePromo: json['namePromo'] ?? '',
      discount: discountValue,
      urlimagePromo: json['urlimagePromos'] ?? '',
    );
  }
}

class Room {
  String id;
  RoomType typeRoom;
  List<String>? imageRoom;

  Room({required this.id, required this.typeRoom, this.imageRoom});

  Map<String, dynamic> toJson() => {
        'typeRoom': typeRoom.displayName,
        'imageRoom': imageRoom,
      };

  static Room fromJson(String id, Map<dynamic, dynamic> json) {
    return Room(
      id: id,
      typeRoom: RoomType.fromString(json['typeRoom'] ?? 'Co Working'),
      imageRoom: json['imageRoom'] != null
          ? List<String>.from(json['imageRoom'])
          : null,
    );
  }
}

class Property {
  String id;
  String nameProperty;
  String? urlimageProperty;
  String? addressProperty;
  String? description;
  String? idLocation;
  String? idRoom;
  String? idPromo;
  double? price;
  double? rating;

  Property({
    required this.id,
    required this.nameProperty,
    this.urlimageProperty,
    this.addressProperty,
    this.description,
    this.idLocation,
    this.idRoom,
    this.idPromo,
    this.price,
    this.rating,
  });

  Map<String, dynamic> toJson() => {
        'nameProperty': nameProperty,
        'urlimageProperties': urlimageProperty,
        'addressProperty': addressProperty,
        'description': description,
        'idLocation': idLocation,
        'idRoom': idRoom,
        'idPromo': idPromo,
        'price': price,
        'rating': rating,
      };

  static Property fromJson(String id, Map<dynamic, dynamic> json) {
    return Property(
      id: id,
      nameProperty: json['nameProperty'] ?? '',
      urlimageProperty: json['urlimageProperties'] ?? '',
      addressProperty: json['addressProperty'] ?? '',
      description: json['description'] ?? '',
      idLocation: json['idLocation'],
      idRoom: json['idRoom'],
      idPromo: json['idPromo'],
      price: json['price'] is String
          ? double.tryParse(json['price'])
          : json['price']?.toDouble(),
      rating: json['rating'] is String
          ? double.tryParse(json['rating'])
          : json['rating']?.toDouble(),
    );
  }
}

class Facility {
  String id;
  String idProperty;
  bool? freeWifi;
  bool? elevator;
  String? parkingArea;

  Facility({
    required this.id,
    required this.idProperty,
    this.freeWifi,
    this.elevator,
    this.parkingArea,
  });

  Map<String, dynamic> toJson() => {
        'idProperty': idProperty,
        'freeWifi': freeWifi,
        'bvel': elevator,
        'parkingArea': parkingArea,
      };

  static Facility fromJson(String id, Map<dynamic, dynamic> json) {
    return Facility(
      id: id,
      idProperty: json['idProperty'] ?? '',
      freeWifi: json['freeWifi'] ?? false,
      elevator: json['bvel'] ?? false,
      parkingArea: json['parkingArea'],
    );
  }
}

class Article {
  String id;
  String title;
  String description;
  String image;
  String date;
  String center;
  String content;
  String? author;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.center,
    required this.content,
    this.author,
  });

  Map<String, dynamic> toJson() => {
        'finalStringTitle': title,
        'finalStringDescription': description,
        'finalStringImage': image,
        'finalStringDate': date,
        'finalStringCenter': center,
        'finalStringContent': content,
        'author': author,
      };

  static Article fromJson(String id, Map<dynamic, dynamic> json) {
    return Article(
      id: id,
      title: json['finalStringTitle'] ?? '',
      description: json['finalStringDescription'] ?? '',
      image: json['finalStringImage'] ?? '',
      date: json['finalStringDate'] ?? '',
      center: json['finalStringCenter'] ?? '',
      content: json['finalStringContent'] ?? '',
      author: json['author'],
    );
  }
}
