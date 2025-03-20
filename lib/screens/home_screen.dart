import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kototinder/models/cat.dart';
import 'package:kototinder/services/cat_api_service.dart';
import 'package:kototinder/widgets/like_dislike_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatApiService _apiService = CatApiService();
  Cat? _currentCat;
  Cat? _nextCat;
  int _likeCount = 0;
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadInit();
  }

  void _loadInit() async {
    final cat = await _apiService.fetchRandomCat();
    final nextCat = await _apiService.fetchRandomCat();

    setState(() {
      _currentCat = cat;
      _nextCat = nextCat;
    });
  }

  void _loadNewCat() async {
    if (_nextCat != null) {
      setState(() {
        _currentCat = _nextCat;
      });
    }
    _nextCat = await _apiService.fetchRandomCat();
  }

  void _handleAction({required bool liked}) {
    if (liked) {
      _swiperController.swipe(CardSwiperDirection.right);
    } else {
      _swiperController.swipe(CardSwiperDirection.left);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кототиндер'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/design/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: _currentCat == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 400,
                    child: CardSwiper(
                      controller: _swiperController,
                      cardsCount: _currentCat != null ? 1 : 0,
                      numberOfCardsDisplayed: 1,
                      onSwipe: (index, previousIndex, direction) {
                        _loadNewCat();
                        if (direction == CardSwiperDirection.right) {
                          setState(() {
                            _likeCount++;
                          });
                        }
                        return true;
                      },
                      cardBuilder:
                          (context, index, horizontalIndex, verticalIndex) {
                        if (_currentCat == null) return const SizedBox();
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/detail',
                                arguments: _currentCat);
                          },
                          child: Card(
                            color: Color.fromARGB(255, 238, 201, 187),
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
                                      imageUrl: _currentCat!.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _currentCat!.breed,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Лайки: $_likeCount',
                    style: const TextStyle(fontSize: 18),
                  ),
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
