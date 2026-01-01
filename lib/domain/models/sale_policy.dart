class SalePolicy {
  int vatPercent;
  int usdToKhrRate;

  SalePolicy({
    this.vatPercent = 0,
    this.usdToKhrRate = 4000,
  });

  void updatePolicy(int newVat, int newRate) {
    vatPercent = newVat;
    usdToKhrRate = newRate;
  }
}