import 'package:traveler/models/country.dart';
import 'package:traveler/models/state.dart';

class City {
  int id;
  String name;
  int stateId;
  Province state;
  int countryId;
  Country country;
  String countryCode;
  double latitude;
  double longitude;
  String wikiDataId;

  City({
    this.longitude,
    this.id,
    this.latitude,
    this.name,
    this.country,
    this.countryCode,
    this.countryId,
    this.state,
    this.stateId,
    this.wikiDataId,
  });

  City.fromMap(Map map, {Country country, Province state})
      : this(
          id: int.parse(map["id"]),
          longitude: double.parse(map["longitude"]),
          latitude: double.parse(map["latitude"]),
          name: map["name"],
          country: country,
          countryCode: map["country_code"],
          countryId: int.parse(map["country_id"]),
          state: state,
          stateId: int.parse(map["state_id"]),
          wikiDataId: map["wikiDataId"],
        );
}
