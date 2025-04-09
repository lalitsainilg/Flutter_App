// lib/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qualhon_test/model/post.dart';
import 'package:qualhon_test/providers/post_provider.dart';
import 'package:qualhon_test/widgets/post_card.dart';

import 'NewPostScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<PostProvider>(context).posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewPostScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: posts.isEmpty
          ? const Center(
        child: Text(
          'No posts yet',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]); // Now passing Post object
        },
      ),
    );
  }
}