import 'package:flutter_test/flutter_test.dart';
import 'package:kototinder/cubits/liked_cats_cubit.dart';
import 'package:kototinder/models/cat.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

void main() {
  group('LikedCatsCubit', () {
    late MockCatStorage mockStorage;
    late LikedCatsCubit cubit;

    final testCat = Cat(
      imageUrl: 'https://example.com/cat.jpg',
      breed: 'Breed',
      description: 'Description',
    );

    setUp(() {
      mockStorage = MockCatStorage();

      when(mockStorage.getLikedCatsWithTimestamp()).thenAnswer((_) async => []);

      cubit = LikedCatsCubit(mockStorage);
    });

    test('likeCat adds a cat to likedCats and calls setCatAction', () async {
      await cubit.likeCat(testCat);

      expect(cubit.state.likedCats.length, 1);
      expect(cubit.state.likedCats.first.cat, testCat);

      verify(mockStorage.setCatAction(
        testCat.imageUrl,
        'liked',
        any,
      )).called(1);
    });

    test('removeOfflineCat removes a cat and calls setCatAction', () async {
      await cubit.likeCat(testCat);
      cubit.removeOfflineCat(cubit.state.likedCats.first);

      expect(cubit.state.likedCats.length, 0);
      verify(mockStorage.setCatAction(
        testCat.imageUrl,
        'disliked',
        null,
      )).called(1);
    });
  });
}
