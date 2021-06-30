class Country {
  String name;
  String iso3;
  String iso2;
  String phoneCode;
  String capital;
  String currency;
  String currencySymbol;
  String tld;
  String native;
  String region;
  String subRegion;
  String timeZones;
  String translations;
  double latitude;
  double longitude;
  String emoji;
  String emojiU;
  String wikiDataId;

  Country({
    this.iso2,
    this.longitude,
    this.latitude,
    this.name,
    this.capital,
    this.currency,
    this.currencySymbol,
    this.emoji,
    this.emojiU,
    this.iso3,
    this.native,
    this.phoneCode,
    this.region,
    this.subRegion,
    this.timeZones,
    this.tld,
    this.translations,
    this.wikiDataId,
  });

  Country.fromMap(Map map)
      : this(
          iso2: map["iso2"],
          longitude: double.parse(map["longitude"]),
          latitude: double.parse(map["latitude"]),
          name: map["name"],
          capital: map["capital"],
          currency: map["currency"],
          currencySymbol: map["currency_symbol"],
          emoji: map["emoji"],
          emojiU: map["emojiU"],
          iso3: map["iso3"],
          native: map["native"],
          phoneCode: map["phonecode"],
          region: map["region"],
          subRegion: map["subregion"],
          timeZones: map["timezones"],
          tld: map["tld"],
          translations: map["translations"],
          wikiDataId: map["wikiDataId"],
        );
}
