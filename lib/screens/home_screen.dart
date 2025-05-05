import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kototinder/models/cat.dart';
import 'package:kototinder/services/cat_api_service.dart';
import 'package:kototinder/services/cat_storage.dart';
import 'package:kototinder/widgets/like_dislike_button.dart';
import 'package:kototinder/cubits/liked_cats_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatApiService _apiService = CatApiService();
  final CatStorage _storage = GetIt.instance<CatStorage>();
  Cat? _currentCat;
  Cat? _nextCat;
  int _likeCount = 0;
  final CardSwiperController _swiperController = CardSwiperController();

  bool _isOnline = true;
  late final Connectivity _connectivity;

  bool _ignoreNextSwipe = false;
  List<Cat> _cache = [];
  int _cacheIndex = 0;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    _checkInitialConnectivity();

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _connectivity.checkConnectivity().then((result) {
      final online = result != ConnectivityResult.none;
      setState(() {
        _isOnline = online;
      });

      _storage.getCachedCats().then((cats) {
        setState(() {
          _cache = cats;
          _cacheIndex = 0;
        });

        if (_isOnline) {
          _loadOnlineCats();
        } else {
          _currentCat = _cache.isNotEmpty ? _cache[0] : null;
        }
      });
    });

    final cubit = context.read<LikedCatsCubit>();
    cubit.stream.listen((state) {
      setState(() => _likeCount = state.likedCats.length);
    });
    _likeCount = cubit.state.likedCats.length;
  }

  void _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    final nowOnline = result != ConnectivityResult.none;

    if (wasOnline != nowOnline) {
      setState(() => _isOnline = nowOnline);

      final messenger = ScaffoldMessenger.of(context);

      if (!nowOnline) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Нет подключения к сети'),
            duration: Duration(days: 1),
          ),
        );
      } else {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Соединение восстановлено'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadOnlineCats() async {
    try {
      final cat = await _apiService.fetchRandomCat();
      final nextCat = await _apiService.fetchRandomCat();
      if (cat != null) {
        _cache.add(cat);
        await _storage.saveCachedCat(cat);
        precacheImage(CachedNetworkImageProvider(cat.imageUrl), context);
      }
      if (nextCat != null) {
        _cache.add(nextCat);
        await _storage.saveCachedCat(nextCat);
        precacheImage(CachedNetworkImageProvider(nextCat.imageUrl), context);
      }
      setState(() {
        _currentCat = cat;
        _nextCat = nextCat;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при загрузке котиков')),
      );
    }
  }

  void _loadNewCat() {
    if (_isOnline) {
      if (_nextCat != null) setState(() => _currentCat = _nextCat);
      _apiService.fetchRandomCat().then((newCat) async {
        if (newCat != null) {
          _cache.add(newCat);
          await _storage.saveCachedCat(newCat);
          precacheImage(CachedNetworkImageProvider(newCat.imageUrl), context);
        }
        setState(() => _nextCat = newCat);
      }).catchError((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при загрузке котиков')),
        );
      });
    } else {
      if (_cache.isNotEmpty) {
        _cacheIndex = (_cacheIndex + 1) % _cache.length;
        setState(() => _currentCat = _cache[_cacheIndex]);
      }
    }
  }

  void _handleAction({required bool liked, bool fromSwipe = false}) {
    if (_currentCat == null) return;
    final cat = _currentCat!;
    final cubit = context.read<LikedCatsCubit>();

    if (_isOnline) {
      if (liked)
        cubit.likeCat(cat);
      else
        cubit.dislikeCat(cat);

      if (!fromSwipe) {
        _ignoreNextSwipe = true;
        _swiperController.swipe(
          liked ? CardSwiperDirection.right : CardSwiperDirection.left,
        );
      }

      _loadNewCat();
    } else {
      if (liked) {
        cubit.likeCat(cat);
      } else {
        cubit.dislikeCat(cat);
      }

      if (_cache.isNotEmpty) {
        _cacheIndex = (_cacheIndex + 1) % _cache.length;
        setState(() => _currentCat = _cache[_cacheIndex]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCat = _currentCat;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кототиндер'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/liked'),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/design/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: displayCat == null
            ? Center(
                child:
                    Text(_isOnline ? 'Загрузка...' : 'Нет сохранённых котиков'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 400,
                    child: CardSwiper(
                      controller: _swiperController,
                      cardsCount: 1,
                      numberOfCardsDisplayed: 1,
                      onSwipe: (_, __, direction) {
                        if (_ignoreNextSwipe) {
                          _ignoreNextSwipe = false;
                          return false;
                        }
                        _handleAction(
                          liked: direction == CardSwiperDirection.right,
                          fromSwipe: true,
                        );
                        return true;
                      },
                      cardBuilder: (_, __, ___, ____) => GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: displayCat,
                        ),
                        child: Card(
                          color: const Color.fromARGB(255, 238, 201, 187),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    imageUrl: displayCat.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (c, u) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (c, u, e) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    displayCat.breed,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Лайки: $_likeCount',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LikeDislikeButton(
                        icon: Icons.thumb_down,
                        color: Colors.red,
                        onPressed: () => _handleAction(liked: false),
                      ),
                      LikeDislikeButton(
                        icon: Icons.thumb_up,
                        color: Colors.green,
                        onPressed: () => _handleAction(liked: true),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
