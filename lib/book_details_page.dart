import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'book_details_page.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({Key? key}) : super(key: key);

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> currentlyReading = [];
  List<Map<String, dynamic>> wantToRead = [];
  List<Map<String, dynamic>> finishedReading = [];

  bool isSortedByRating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchMyBooks();
  }

  Future<void> fetchMyBooks() async {
    currentlyReading = await FirestoreService.getBooksFromList(
      'currentlyReading',
    );
    wantToRead = await FirestoreService.getBooksFromList('wantToRead');
    finishedReading = await FirestoreService.getBooksFromList(
      'finishedReading',
    );
    setState(() {});
  }

  void sortFinishedBooks() {
    setState(() {
      finishedReading.sort((a, b) {
        int ratingA = a['userRating'] ?? 0;
        int ratingB = b['userRating'] ?? 0;
        return isSortedByRating
            ? ratingA.compareTo(ratingB)
            : ratingB.compareTo(ratingA);
      });
      isSortedByRating = !isSortedByRating;
    });
  }

  Widget buildList(
    List<Map<String, dynamic>> books, {
    bool showRating = false,
  }) {
    if (books.isEmpty) {
      return Center(child: Text('No books here.'));
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading:
              book['thumbnail'] != null
                  ? Image.network(
                    book['thumbnail'],
                    width: 50,
                    fit: BoxFit.cover,
                  )
                  : Container(width: 50, height: 50, color: Colors.grey),
          title: Text(book['title'] ?? 'No Title'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book['authors'] ?? ''),
              if (showRating && book['userRating'] != null)
                Text('Your Rating: ${book['userRating']} ★'),
            ],
          ),
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
                          'imageLinks': {'thumbnail': book['thumbnail']},
                          'categories': [book['categories']],
                          'averageRating': book['averageRating'],
                          'ratingsCount': book['ratingsCount'],
                          'previewLink': book['previewLink'],
                          'description': 'No description available.',
                        },
                        'id': book['previewLink'], // used as fallback ID
                      },
                    ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Books'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Currently Reading'),
            Tab(text: 'Want to Read'),
            Tab(text: 'Finished Reading'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            tooltip: 'Sort by Rating',
            onPressed: () {
              if (_tabController.index == 2) {
                sortFinishedBooks();
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildList(currentlyReading),
          buildList(wantToRead),
          buildList(finishedReading, showRating: true),
        ],
      ),
    );
  }
}
