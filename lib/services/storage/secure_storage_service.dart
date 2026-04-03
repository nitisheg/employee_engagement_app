import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String accessTokenKey = 'access_token';
  static const String onboardingCompletedKey = 'onboarding_completed';

  static SecureStorageService? _instance;
  static SecureStorageService get instance =>
      _instance ??= const SecureStorageService._();

  final FlutterSecureStorage _storage;

  const SecureStorageService._({FlutterSecureStorage storage = const FlutterSecureStorage()})
      : _storage = storage;

  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  Future<String?> read({required String key}) => _storage.read(key: key);

  Future<void> delete({required String key}) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
