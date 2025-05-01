import 'package:flutter/material.dart';
import 'firestore_service.dart';

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

  Widget buildList(List<Map<String, dynamic>> books) {
    return books.isEmpty
        ? Center(child: Text('No books here.'))
        : ListView.builder(
          itemCount: books.length,
          itemBuilder:
              (context, index) => ListTile(
                title: Text(books[index]['title'] ?? 'No Title'),
                subtitle: Text(books[index]['authors'] ?? ''),
              ),
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildList(currentlyReading),
          buildList(wantToRead),
          buildList(finishedReading),
        ],
      ),
    );
  }
}
