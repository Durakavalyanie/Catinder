import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kototinder/models/cat.dart';
import 'package:kototinder/services/cat_storage.dart';

class LikedCat {
  final Cat cat;
  final DateTime likedAt;

  LikedCat({required this.cat, required this.likedAt});
}

class LikedCatsState {
  final List<LikedCat> likedCats;
  final String? breedFilter;

  List<LikedCat> get filteredCats => breedFilter == null || breedFilter!.isEmpty
      ? likedCats
      : likedCats.where((c) => c.cat.breed == breedFilter).toList();

  LikedCatsState({required this.likedCats, this.breedFilter});
}

class LikedCatsCubit extends Cubit<LikedCatsState> {
  final CatStorage _storage;

  LikedCatsCubit(this._storage) : super(LikedCatsState(likedCats: [])) {
    loadLikedCats();
  }

  Future<void> likeCat(Cat cat) async {
    final likedAt = DateTime.now();
    final updated = List<LikedCat>.from(state.likedCats)
      ..removeWhere((lc) => lc.cat.imageUrl == cat.imageUrl)
      ..add(LikedCat(cat: cat, likedAt: likedAt));
    emit(LikedCatsState(likedCats: updated, breedFilter: state.breedFilter));
    await _storage.saveCachedCat(cat);
    await _storage.setCatAction(cat.imageUrl, 'liked', likedAt);
  }

  Future<void> removeCat(LikedCat likedCat) async {
    final updated = List<LikedCat>.from(state.likedCats)
      ..removeWhere((lc) => lc.cat.imageUrl == likedCat.cat.imageUrl);
    emit(LikedCatsState(likedCats: updated, breedFilter: state.breedFilter));
    await _storage.setCatAction(likedCat.cat.imageUrl, 'disliked');
  }

  void removeOfflineCat(LikedCat likedCat) {
    final updated = List<LikedCat>.from(state.likedCats)
      ..removeWhere((lc) => lc.cat.imageUrl == likedCat.cat.imageUrl);
    emit(LikedCatsState(likedCats: updated, breedFilter: state.breedFilter));
    _storage.setCatAction(likedCat.cat.imageUrl, 'disliked');
  }

  Future<void> loadLikedCats() async {
    final liked = await _storage.getLikedCatsWithTimestamp();
    emit(LikedCatsState(likedCats: liked, breedFilter: state.breedFilter));
  }

  Future<void> dislikeCat(Cat cat) async {
    await _storage.saveCatAction(cat, 'disliked');
    final updated = List<LikedCat>.from(state.likedCats)
      ..removeWhere((lc) => lc.cat.imageUrl == cat.imageUrl);
    emit(LikedCatsState(likedCats: updated, breedFilter: state.breedFilter));
  }

  void setBreedFilter(String? breed) {
    emit(LikedCatsState(likedCats: state.likedCats, breedFilter: breed));
  }
}
