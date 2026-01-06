import 'enums.dart';
import 'model_ids.dart';

class Payment {
  final String id;
  final PaymentMethod type;

  final int recieveAmountKHR;
  final double recieveAmountUSD;
  final int changeKhr;
  final double changeUSD;

  Payment({
    String? id,
    required this.type,
    required this.recieveAmountKHR,
    required this.recieveAmountUSD,
    required this.changeKhr,
    required this.changeUSD,
  }) : id = id ?? uuid.v4();
}
