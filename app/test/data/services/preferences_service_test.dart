import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/data/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = PreferencesService();
  });

  test('returns null when no house or member has been selected', () async {
    expect(await service.getCurrentHouseId(), isNull);
    expect(await service.getCurrentMemberId(), isNull);
  });

  test('saves and reads the current house ID', () async {
    expect(await service.setCurrentHouseId('house-123'), isTrue);
    expect(await service.getCurrentHouseId(), 'house-123');
  });

  test('saves and reads the current member ID', () async {
    expect(await service.setCurrentMemberId('member-456'), isTrue);
    expect(await service.getCurrentMemberId(), 'member-456');
  });

  test('overwrites an existing selection', () async {
    await service.setCurrentHouseId('house-old');
    await service.setCurrentHouseId('house-new');
    await service.setCurrentMemberId('member-old');
    await service.setCurrentMemberId('member-new');

    expect(await service.getCurrentHouseId(), 'house-new');
    expect(await service.getCurrentMemberId(), 'member-new');
  });

  test('clearing house ID does not clear member ID', () async {
    await service.setCurrentHouseId('house-123');
    await service.setCurrentMemberId('member-456');

    expect(await service.clearCurrentHouseId(), isTrue);
    expect(await service.getCurrentHouseId(), isNull);
    expect(await service.getCurrentMemberId(), 'member-456');
  });

  test('clearing member ID does not clear house ID', () async {
    await service.setCurrentHouseId('house-123');
    await service.setCurrentMemberId('member-456');

    expect(await service.clearCurrentMemberId(), isTrue);
    expect(await service.getCurrentHouseId(), 'house-123');
    expect(await service.getCurrentMemberId(), isNull);
  });

  test('another service instance can read the saved selection', () async {
    await service.setCurrentHouseId('house-123');
    await service.setCurrentMemberId('member-456');

    final otherInstance = PreferencesService();
    expect(await otherInstance.getCurrentHouseId(), 'house-123');
    expect(await otherInstance.getCurrentMemberId(), 'member-456');
  });
}