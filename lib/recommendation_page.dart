import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'firestore_service.dart'; // your service where favorites are stored

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  bool isLoading = true;
  List<String> recommendations = [];
  final String openAIApiKey =
      'your api key'; // << paste your key here

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    final favoriteBooks = await FirestoreService.getBooksFromList('favorites');
    print('🔥 Favorite Books Fetched: $favoriteBooks');

    if (favoriteBooks.isEmpty) {
      setState(() {
        isLoading = false;
        recommendations = [];
      });
      return;
    }

    final favoriteTitles = favoriteBooks.map((book) => book['title']).toList();

    final prompt =
        "I like these books: ${favoriteTitles.join(", ")}. Recommend me some similar good books with title and author names.";

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIApiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 500,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'] as String;

      setState(() {
        isLoading = false;
        recommendations =
            reply.split('\n').where((line) => line.trim().isNotEmpty).toList();
      });
    } else {
      print('❌ Failed to get recommendations: ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Recommendations 📚'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : recommendations.isEmpty
              ? Center(
                child: Text(
                  'Please add some favorite books first to get personalized recommendations.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(recommendations[index]));
                },
              ),
    );
  }
}
