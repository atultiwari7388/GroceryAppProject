//====================== round fare==============
double roundFare(double fare) {
  if (fare - fare.floor() >= 0.5) {
    return fare.ceilToDouble();
  } else {
    return fare.floorToDouble();
  }
}
