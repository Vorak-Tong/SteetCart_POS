import 'model_ids.dart';

class Category {
  static const int nameMax = 15;

  final String id;
  final String name;

  Category({String? id, required this.name}) : id = id ?? uuid.v4();
}
