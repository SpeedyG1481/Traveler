class MeterTypes {
  int externalKm;
  int externalMt;

  int point;

  MeterTypes(double totalMeter) {
    double tMeter = totalMeter;

    externalKm = (tMeter / 1000).floor();
    tMeter -= externalKm * 1000;
    externalMt = tMeter.floor();
    double p = 1 / totalMeter;
    point = (p * 1000000000).round();
  }
}
