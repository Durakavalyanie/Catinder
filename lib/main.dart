import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kototinder/screens/home_screen.dart';
import 'package:kototinder/screens/detail_screen.dart';
import 'package:kototinder/screens/liked_cats_screen.dart';
import 'package:kototinder/services/cat_api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:kototinder/cubits/liked_cats_cubit.dart';

void main() {
  final getIt = GetIt.instance;
  getIt.registerLazySingleton(() => CatApiService());
  getIt.registerSingleton<LikedCatsCubit>(LikedCatsCubit());

  runApp(const KototinderApp());
}

class KototinderApp extends StatelessWidget {
  const KototinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<LikedCatsCubit>()),
      ],
      child: MaterialApp(
        title: 'Кототиндер',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        routes: {
          '/': (context) => const HomeScreen(),
          '/detail': (context) => const DetailScreen(),
          '/liked': (context) => const LikedCatsScreen(),
        },
      ),
    );
  }
}
