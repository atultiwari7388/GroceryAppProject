double calculateDiscountPercentage(double oldPrice, double newPrice) {
  if (oldPrice == 0) return 0.0;
  return ((oldPrice - newPrice) / oldPrice) * 100;
}
