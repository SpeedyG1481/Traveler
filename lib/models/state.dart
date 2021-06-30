import 'package:traveler/models/country.dart';

class Province {
  int id;
  String name;
  int countryId;
  Country country;
  String countryCode;
  String fipsCode;
  String iso2;
  double latitude;
  double longitude;
  String wikiDataId;

  Province({
    this.country,
    this.id,
    this.countryId,
    this.countryCode,
    this.name,
    this.latitude,
    this.longitude,
    this.fipsCode,
    this.iso2,
    this.wikiDataId,
  });

  Province.fromMap(Map map, {Country country})
      : this(
          country: country,
          id: int.parse(map["id"]),
          countryId: int.parse(map["country_id"]),
          countryCode: map["country_code"],
          name: map["name"],
          latitude: double.parse(map["latitude"]),
          longitude: double.parse(map["longitude"]),
          fipsCode: map["fips_code"],
          iso2: map["iso2"],
          wikiDataId: map["wikiDataId"],
        );
}
