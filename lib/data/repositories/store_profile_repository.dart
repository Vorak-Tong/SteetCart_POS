import 'package:street_cart_pos/data/local/dao/store_profile_dao.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';

abstract class StoreProfileRepository {
  Future<StoreProfile> getStoreProfile();
  Future<void> updateStoreProfile(StoreProfile profile);
}

class StoreProfileRepositoryImpl implements StoreProfileRepository {
  final StoreProfileDao _dao = StoreProfileDao();

  @override
  Future<StoreProfile> getStoreProfile() async {
    final row = await _dao.get();
    if (row != null) {
      return StoreProfile(
        name: row[StoreProfileDao.colName] as String? ?? 'My Store',
        phone: row[StoreProfileDao.colPhone] as String? ?? '0123456789',
        address:
            row[StoreProfileDao.colAddress] as String? ??
            'st1, Mod District, Mod City',
      );
    }

    const fallback = StoreProfile(
      name: 'My Store',
      phone: '0123456789',
      address: 'st1, Mod District, Mod City',
    );
    await _dao.insertOrUpdate({
      StoreProfileDao.colName: fallback.name,
      StoreProfileDao.colPhone: fallback.phone,
      StoreProfileDao.colAddress: fallback.address,
    });
    return fallback;
  }

  @override
  Future<void> updateStoreProfile(StoreProfile profile) async {
    final name = profile.name.trim();
    final phone = profile.phone.trim();
    final address = profile.address.trim();

    if (name.isEmpty) throw ArgumentError('Store name is required.');
    if (phone.isEmpty) throw ArgumentError('Contact number is required.');
    if (address.isEmpty) throw ArgumentError('Address is required.');

    if (name.length > StoreProfile.nameMax) {
      throw ArgumentError(
        'Store name must be at most ${StoreProfile.nameMax} characters.',
      );
    }
    if (phone.length > StoreProfile.phoneMax) {
      throw ArgumentError(
        'Contact number must be at most ${StoreProfile.phoneMax} characters.',
      );
    }
    if (address.length > StoreProfile.addressMax) {
      throw ArgumentError(
        'Address must be at most ${StoreProfile.addressMax} characters.',
      );
    }

    await _dao.insertOrUpdate({
      StoreProfileDao.colName: name,
      StoreProfileDao.colPhone: phone,
      StoreProfileDao.colAddress: address,
    });
  }
}
