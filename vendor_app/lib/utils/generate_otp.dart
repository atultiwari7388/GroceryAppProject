import 'dart:math';

int generateOTP() {
  var random = Random();
  return random.nextInt(9000) + 1000;
}
