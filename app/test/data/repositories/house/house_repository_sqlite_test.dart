import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_evim/data/repositories/house/house_repository.dart';
import 'package:ogrenci_evim/data/repositories/house/house_repository_sqlite.dart';
import 'package:ogrenci_evim/data/services/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Same setup as app_database_test.dart: desktop sqflite with a fresh
  // in-memory database for each test.
  setUpAll(() => databaseFactory = databaseFactoryFfiNoIsolate);

  late AppDatabase appDatabase;
  late HouseRepository repository;

  setUp(() {
    appDatabase = AppDatabase(path: inMemoryDatabasePath);
    repository = HouseRepositorySqlite(appDatabase);
  });

  tearDown(() async => (await appDatabase.database).close());

  group('createHouse', () {
    test('saves the house and its first member', () async {
      final (house, member) = await repository.createHouse(
        'Avcılar Evi',
        'Ayşe',
      );

      expect(house.name, 'Avcılar Evi');
      expect(house.inviteCode.length, 6);
      expect(member.houseId, house.id);
      expect(member.name, 'Ayşe');

      final saved = await repository.getHouse(house.id);
      expect(saved?.inviteCode, house.inviteCode);
      expect((await repository.getMembers(house.id)).single.id, member.id);
    });

    test('trims spaces around names', () async {
      final (house, member) = await repository.createHouse(' Ev ', ' Ayşe ');

      expect(house.name, 'Ev');
      expect(member.name, 'Ayşe');
    });

    test('makes a new invite code if the first one is taken', () async {
      final codes = ['AAAAAA', 'AAAAAA', 'BBBBBB'].iterator;
      repository = HouseRepositorySqlite(
        appDatabase,
        newCode: () => (codes..moveNext()).current,
      );

      final (first, _) = await repository.createHouse('Ev 1', 'Ayşe');
      final (second, _) = await repository.createHouse('Ev 2', 'Mehmet');

      expect(first.inviteCode, 'AAAAAA');
      expect(second.inviteCode, 'BBBBBB');
    });
  });

  group('joinHouse', () {
    test('adds a member to the house with the invite code', () async {
      final (house, _) = await repository.createHouse('Ev', 'Ayşe');

      final member = await repository.joinHouse(house.inviteCode, 'Mehmet');

      expect(member.houseId, house.id);
      final names = (await repository.getMembers(house.id)).map((m) => m.name);
      expect(names, ['Ayşe', 'Mehmet']);
    });

    test('accepts a lowercase code with spaces', () async {
      final (house, _) = await repository.createHouse('Ev', 'Ayşe');
      final typed = ' ${house.inviteCode.toLowerCase()} ';

      final member = await repository.joinHouse(typed, 'Mehmet');

      expect(member.houseId, house.id);
    });

    test('throws for a wrong code', () async {
      await repository.createHouse('Ev', 'Ayşe');

      await expectLater(
        repository.joinHouse('ZZZZZZ', 'Mehmet'),
        throwsA(isA<InviteCodeNotFoundException>()),
      );
    });
  });

  group('getHouse and getMembers', () {
    test('return nothing for an unknown house', () async {
      expect(await repository.getHouse('no-such-house'), isNull);
      expect(await repository.getMembers('no-such-house'), isEmpty);
    });

    test('only return members of the given house', () async {
      final (house1, _) = await repository.createHouse('Ev 1', 'Ayşe');
      final (house2, _) = await repository.createHouse('Ev 2', 'Mehmet');
      await repository.joinHouse(house2.inviteCode, 'Samet');

      expect((await repository.getMembers(house1.id)).length, 1);
      expect((await repository.getMembers(house2.id)).length, 2);
    });
  });
}
