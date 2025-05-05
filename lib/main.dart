import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kototinder/screens/home_screen.dart';
import 'package:kototinder/screens/detail_screen.dart';
import 'package:kototinder/screens/liked_cats_screen.dart';
import 'package:kototinder/services/cat_api_service.dart';
import 'package:kototinder/services/cat_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:kototinder/cubits/liked_cats_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final getIt = GetIt.instance;
  getIt.registerLazySingleton(() => CatApiService());
  final catStorage = CatStorage();
  await catStorage.init();
  getIt.registerSingleton<CatStorage>(catStorage);
  getIt.registerSingleton<LikedCatsCubit>(LikedCatsCubit(catStorage));

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
