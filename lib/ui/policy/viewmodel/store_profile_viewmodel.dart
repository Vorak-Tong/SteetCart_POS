import 'package:flutter/foundation.dart';
import 'package:street_cart_pos/data/repositories/store_profile_repository.dart';
import 'package:street_cart_pos/domain/models/store_profile.dart';
import 'package:street_cart_pos/utils/command.dart';

class StoreProfileViewModel extends ChangeNotifier {
  StoreProfileViewModel({StoreProfileRepository? repository})
    : _repository = repository ?? StoreProfileRepositoryImpl() {
    loadProfileCommand = CommandWithParam((_) => _load());
    updateProfileCommand = CommandWithParam(_update);

    loadProfileCommand.addListener(notifyListeners);
    updateProfileCommand.addListener(notifyListeners);

    loadProfileCommand.execute(null);
  }

  final StoreProfileRepository _repository;

  StoreProfile _profile = const StoreProfile(
    name: 'My Store',
    phone: '0123456789',
    address: 'st1, Mod District, Mod City',
  );

  late final CommandWithParam<void, void> loadProfileCommand;
  late final CommandWithParam<StoreProfile, void> updateProfileCommand;

  StoreProfile get profile => _profile;

  Future<void> refresh() => loadProfileCommand.execute(null);

  Future<void> _load() async {
    _profile = await _repository.getStoreProfile();
    notifyListeners();
  }

  Future<void> save(StoreProfile profile) =>
      updateProfileCommand.execute(profile);

  Future<void> _update(StoreProfile profile) async {
    await _repository.updateStoreProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  @override
  void dispose() {
    loadProfileCommand.removeListener(notifyListeners);
    updateProfileCommand.removeListener(notifyListeners);
    super.dispose();
  }
}
