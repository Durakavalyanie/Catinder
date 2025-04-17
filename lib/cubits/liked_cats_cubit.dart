import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kototinder/models/cat.dart';

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
  LikedCatsCubit() : super(LikedCatsState(likedCats: []));

  void likeCat(Cat cat) {
    emit(LikedCatsState(
      likedCats: List.from(state.likedCats)
        ..add(LikedCat(cat: cat, likedAt: DateTime.now())),
      breedFilter: state.breedFilter,
    ));
  }

  void removeCat(LikedCat likedCat) {
    emit(LikedCatsState(
      likedCats: List.from(state.likedCats)..remove(likedCat),
      breedFilter: state.breedFilter,
    ));
  }

  void setBreedFilter(String? breed) {
    emit(LikedCatsState(
      likedCats: state.likedCats,
      breedFilter: breed,
    ));
  }
}
