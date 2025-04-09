// lib/screens/share_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qualhon_test/model/post.dart';
import 'package:qualhon_test/providers/post_provider.dart';

class ShareScreen extends StatefulWidget {
  final List<XFile> images;
  final int filterIndex;
  final double filterStrength;

  const ShareScreen({
    super.key,
    required this.images,
    required this.filterIndex,
    required this.filterStrength,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('MMM d').format(date);
  }

  void _sharePost() {
    if (widget.images.isEmpty) return;

    final now = DateTime.now();
    
    final post = Post(
      userName: 'John Karter',
      userImage: 'assets/profile.jpg',
      imagePath: widget.images[0].path,
      caption: _captionController.text,
      likes: 0,
      comments: 0,
      timeAgo: _formatTimeAgo(now),
      filterIndex: widget.filterIndex,
      filterStrength: widget.filterStrength,
      timestamp: now,
    );

    Provider.of<PostProvider>(context, listen: false).addPost(post);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.images.isNotEmpty)
                    Image.file(File(widget.images[0].path)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _sharePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Share Now'),
            ),
          ),
        ],
      ),
    );
  }
}