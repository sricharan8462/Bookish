import 'package:flutter/material.dart';

class MyBooksPage extends StatelessWidget {
  const MyBooksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Books'),
          backgroundColor: Colors.deepPurple,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Currently Reading'),
              Tab(text: 'Want to Read'),
              Tab(text: 'Finished Reading'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Currently Reading')),
            Center(child: Text('Want to Read')),
            Center(child: Text('Finished Reading')),
          ],
        ),
      ),
    );
  }
}