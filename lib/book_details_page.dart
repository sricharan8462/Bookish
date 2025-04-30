import 'package:flutter/material.dart';

class BookDetailsPage extends StatefulWidget {
  final Map bookData;

  const BookDetailsPage({Key? key, required this.bookData}) : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  int userRating = 0;

  Widget buildStar(int starNumber) {
    return IconButton(
      onPressed: () {
        setState(() {
          userRating = starNumber;
        });
      },
      icon: Icon(
        starNumber <= userRating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final volumeInfo = widget.bookData['volumeInfo'];
    final title = volumeInfo['title'] ?? 'No Title';
    final authors = volumeInfo['authors'] != null
        ? (volumeInfo['authors'] as List).join(', ')
        : 'Unknown Author';
    final description =
        volumeInfo['description'] ?? 'No description available.';
    final thumbnail = volumeInfo['imageLinks'] != null
        ? volumeInfo['imageLinks']['thumbnail']
        : null;
    final categories = volumeInfo['categories'] != null
        ? (volumeInfo['categories'] as List).join(', ')
        : 'No Category';
    final averageRating =
        volumeInfo['averageRating']?.toString() ?? 'No rating';
    final ratingsCount = volumeInfo['ratingsCount']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (thumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(thumbnail, height: 220),
              ),
            SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'by $authors',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            Text('Genre: $categories', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Avg Rating: $averageRating ★ ($ratingsCount ratings)',
              style: TextStyle(fontSize: 16),
            ),
            Divider(height: 30, thickness: 1),

            /// Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            Divider(height: 30, thickness: 1),

            /// User Rating Stars
            Text(
              'Your Rating',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),
          ],
        ),
      ),
    );
  }
}