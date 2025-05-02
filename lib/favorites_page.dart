import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'book_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final books = await FirestoreService.getBooksFromList('favorites');
    setState(() {
      favoriteBooks = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          favoriteBooks.isEmpty
              ? Center(child: Text('No favorites yet!'))
              : ListView.builder(
                itemCount: favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = favoriteBooks[index];
                  return ListTile(
                    leading:
                        book['thumbnail'] != null
                            ? Image.network(book['thumbnail'])
                            : null,
                    title: Text(book['title'] ?? 'No Title'),
                    subtitle: Text(book['authors'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookDetailsPage(
                                bookData: {
                                  'volumeInfo': {
                                    'title': book['title'],
                                    'authors': book['authors'].split(', '),
                                    'imageLinks': {
                                      'thumbnail': book['thumbnail'],
                                    },
                                    'categories': [book['categories']],
                                    'averageRating': book['averageRating'],
                                    'ratingsCount': book['ratingsCount'],
                                    'previewLink': book['previewLink'],
                                    'description': 'No description available.',
                                  },
                                },
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}