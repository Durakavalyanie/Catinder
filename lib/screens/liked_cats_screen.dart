import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kototinder/cubits/liked_cats_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Лайкнутые котики")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text("Фильтр по породе"),
              value: context.watch<LikedCatsCubit>().state.breedFilter,
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text("Все")),
                ...context
                    .watch<LikedCatsCubit>()
                    .state
                    .likedCats
                    .map((c) => c.cat.breed)
                    .toSet()
                    .map((breed) =>
                        DropdownMenuItem(value: breed, child: Text(breed)))
              ],
              onChanged: (value) =>
                  context.read<LikedCatsCubit>().setBreedFilter(value),
            ),
          ),
          Expanded(
            child: BlocBuilder<LikedCatsCubit, LikedCatsState>(
              builder: (context, state) {
                final cats = state.filteredCats;
                if (cats.isEmpty)
                  return const Center(child: Text("Нет лайкнутых котиков"));
                return ListView.builder(
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    final likedCat = cats[index];
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: likedCat.cat.imageUrl,
                        width: 60,
                        height: 60,
                        placeholder: (c, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (c, url, error) => const Icon(Icons.error),
                      ),
                      title: Text(likedCat.cat.breed),
                      subtitle: Text(
                          'Дата лайка: ${likedCat.likedAt.toLocal().toString().split('.').first}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            context.read<LikedCatsCubit>().removeCat(likedCat),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
