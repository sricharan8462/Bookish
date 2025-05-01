import 'package:flutter/material.dart';
import 'firestore_service.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  bool isLoading = true;
  List<String> favoriteTitles = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await FirestoreService.getBooksFromList('favorites');
    setState(() {
      favoriteTitles = favorites.map((book) => book['title'] ?? '').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Recommendations 📚'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : favoriteTitles.isEmpty
              ? Center(
                  child: Text(
                    'Please add some favorite books to get recommendations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteTitles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.favorite, color: Colors.deepPurple),
                      title: Text(favoriteTitles[index]),
                    );
                  },
                ),
    );
  }
}