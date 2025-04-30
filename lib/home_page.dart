import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_details_page.dart';
import 'favorites_page.dart';
import 'my_books_page.dart';
import 'login_page.dart';
import 'recommendation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool isSearching = false;

  Map<String, List> genreBooks = {
    'Fiction': [],
    'Science': [],
    'History': [],
    'Horror': [],
    'Romance': [],
    'Non-Fiction': [],
    'Historical Fiction': [],
    'Autobiographies': [],
    'Science Fiction': [],
    'Fantasy': [],
  };

  List searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchAllGenres();
  }

  Future<void> fetchAllGenres() async {
    for (var genre in genreBooks.keys) {
      await fetchBooksByCategory(genre, genreBooks[genre]!);
    }
  }

  Future<void> fetchBooksByCategory(String genre, List storeList) async {
    String searchTerm = genre;
    if (genre == 'Autobiographies') searchTerm = 'biography';
    if (genre == 'Non-Fiction') searchTerm = 'nonfiction';
    if (genre == 'Historical Fiction') searchTerm = 'historical fiction';
    if (genre == 'Science Fiction') searchTerm = 'science fiction';

    final url =
        'https://www.googleapis.com/books/v1/volumes?q=subject:$searchTerm&maxResults=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        storeList.addAll(data['items']);
      });
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      isLoading = true;
    });

    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=20';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        searchResults = data['items'];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildBookCard(item) {
    final volumeInfo = item['volumeInfo'];
    final title = volumeInfo['title'] ?? 'No Title';
    final authors =
        volumeInfo['authors'] != null
            ? (volumeInfo['authors'] as List).join(', ')
            : 'Unknown Author';
    final thumbnail =
        volumeInfo['imageLinks'] != null
            ? volumeInfo['imageLinks']['thumbnail']
            : null;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(bookData: item),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Container(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              thumbnail != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      thumbnail,
                      height: 140,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Container(height: 140, width: 110, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      authors,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategorySection(String title, List books) {
    if (books.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 230,
          padding: EdgeInsets.only(left: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              return buildBookCard(books[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Discover Books 📚'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'mybooks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyBooksPage()),
                );
              } else if (value == 'favorites') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: Icon(Icons.person),
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'mybooks', child: Text('My Books')),
                  PopupMenuItem(value: 'favorites', child: Text('Favorites')),
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for books or authors...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchResults = [];
                          isSearching = false;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    searchBooks(value);
                  },
                  onSubmitted: (value) {
                    searchBooks(value);
                  },
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendationPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.recommend),
                  label: Text('Get Recommendations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Show live search results or genre sections
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchResults[index];
                  final volumeInfo = item['volumeInfo'];
                  final title = volumeInfo['title'] ?? 'No Title';
                  final authors =
                      volumeInfo['authors'] != null
                          ? (volumeInfo['authors'] as List).join(', ')
                          : 'Unknown Author';
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(authors),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsPage(bookData: item),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: SpinKitFadingCircle(color: Colors.deepPurple),
                      )
                      : ListView(
                        children:
                            genreBooks.entries
                                .map(
                                  (entry) => buildCategorySection(
                                    entry.key,
                                    entry.value,
                                  ),
                                )
                                .toList(),
                      ),
            ),
        ],
      ),
    );
  }
}