import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'review_service.dart';

class BookDetailsPage extends StatefulWidget {
  final Map bookData;

  const BookDetailsPage({Key? key, required this.bookData}) : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<Map<String, dynamic>> reviews = [];
  late String bookId;
  int userRating = 0;

  @override
  void initState() {
    super.initState();
    bookId = widget.bookData['id'] ?? '';
    fetchReviews();
    loadUserRating();
  }

  Future<void> fetchReviews() async {
    try {
      reviews = await ReviewService.getReviews(bookId);
      setState(() {});
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> loadUserRating() async {
    try {
      final rating = await FirestoreService.getBookRating(bookId);
      if (rating != null) {
        setState(() {
          userRating = rating;
        });
      }
    } catch (e) {
      print('Error loading user rating: $e');
    }
  }

  Future<void> saveUserRating() async {
    try {
      await FirestoreService.saveBookRating(bookId, userRating);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Your Rating Saved!')));
    } catch (e) {
      print('Error saving user rating: $e');
    }
  }

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

  void _showMyBooksDialog(Map<String, dynamic> bookData) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Add to My Books'),
          children: [
            SimpleDialogOption(
              child: Text('📖 Currently Reading'),
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreService.initializeUserData();
                await FirestoreService.addBookToList(
                  'currentlyReading',
                  bookData,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Added to Currently Reading!')),
                );
              },
            ),
            SimpleDialogOption(
              child: Text('📚 Want to Read'),
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreService.initializeUserData();
                await FirestoreService.addBookToList('wantToRead', bookData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Added to Want to Read!')),
                );
              },
            ),
            SimpleDialogOption(
              child: Text('✅ Finished Reading'),
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreService.initializeUserData();
                await FirestoreService.addBookToList(
                  'finishedReading',
                  bookData,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Added to Finished Reading!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final volumeInfo = widget.bookData['volumeInfo'];
    final title = volumeInfo['title'] ?? 'No Title';
    final authors =
        volumeInfo['authors'] != null
            ? (volumeInfo['authors'] as List).join(', ')
            : 'Unknown Author';
    final description =
        volumeInfo['description'] ?? 'No description available.';
    final thumbnail =
        volumeInfo['imageLinks'] != null
            ? volumeInfo['imageLinks']['thumbnail']
            : null;
    final categories =
        volumeInfo['categories'] != null
            ? (volumeInfo['categories'] as List).join(', ')
            : 'No Category';
    final averageRating =
        volumeInfo['averageRating']?.toString() ?? 'No rating';
    final ratingsCount = volumeInfo['ratingsCount']?.toString() ?? '0';

    final bookDataToSave = {
      'title': title,
      'authors': authors,
      'thumbnail': thumbnail,
      'categories': categories,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
    };

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

            // 📖 Description
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

            // ⭐ User Rating
            Text(
              'Your Rating',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveUserRating,
              child: Text('Save Rating', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Divider(height: 30, thickness: 1),

            // 🚀 Main Buttons
            buildModernButton(Icons.favorite, 'Add to Favorites', () async {
              await FirestoreService.initializeUserData();
              await FirestoreService.addBookToList('favorites', bookDataToSave);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('✅ Added to Favorites!')));
            }),
            buildModernButton(Icons.menu_book, 'Add to My Books', () {
              _showMyBooksDialog(bookDataToSave);
            }),
            buildModernButton(Icons.rate_review, 'Write a Review', () async {
              await showDialog(
                context: context,
                builder:
                    (context) => WriteReviewDialog(
                      bookId: bookId,
                      onReviewAdded: fetchReviews,
                    ),
              );
            }),
            Divider(height: 30, thickness: 1),

            // 📝 Reviews
            Text(
              'User Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            reviews.isEmpty
                ? Text('No reviews yet.', style: TextStyle(fontSize: 16))
                : Column(
                  children:
                      reviews.map((review) {
                        return ListTile(
                          title: Text(review['username'] ?? 'Unknown User'),
                          subtitle: Text(review['reviewText'] ?? ''),
                        );
                      }).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget buildModernButton(IconData icon, String text, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class WriteReviewDialog extends StatefulWidget {
  final String bookId;
  final VoidCallback onReviewAdded;

  const WriteReviewDialog({
    Key? key,
    required this.bookId,
    required this.onReviewAdded,
  }) : super(key: key);

  @override
  _WriteReviewDialogState createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Write a Review'),
      content: TextField(
        controller: reviewController,
        maxLines: 5,
        decoration: InputDecoration(hintText: 'Enter your review here...'),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (reviewController.text.trim().isNotEmpty) {
              await ReviewService.addReview(
                widget.bookId,
                reviewController.text.trim(),
              );
              widget.onReviewAdded();
              Navigator.pop(context);
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
