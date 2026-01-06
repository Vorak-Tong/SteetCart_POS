class StoreProfile {
  static const int nameMax = 30;
  static const int phoneMax = 20;
  static const int addressMax = 80;

  const StoreProfile({
    required this.name,
    required this.phone,
    required this.address,
  });

  final String name;
  final String phone;
  final String address;

  StoreProfile copyWith({String? name, String? phone, String? address}) {
    return StoreProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
