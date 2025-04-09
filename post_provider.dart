// lib/providers/post_provider.dart
import 'package:flutter/foundation.dart';
import 'package:qualhon_test/model/post.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  // Make this method return Future<void>
  Future<void> addPost(Post post) async {
    // Simulate network delay (remove in production)
    await Future.delayed(const Duration(milliseconds: 500));

    _posts.insert(0, post);
    notifyListeners();
  }
}