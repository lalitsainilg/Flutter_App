import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qualhon_test/model/post.dart';
import 'package:qualhon_test/model/user.dart'; // Assuming you have a User model
import 'package:qualhon_test/providers/post_provider.dart';
import 'package:qualhon_test/providers/user_provider.dart'; // For fetching users
import 'package:qualhon_test/screen/home_screen.dart';
import 'package:qualhon_test/screen/user_search_screen.dart';

import 'user_search_screen.dart'; // For searching users

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
  final List<User> _taggedUsers = [];
  bool _isPosting = false;
  bool _showTaggingUI = false;
  Offset _tagPosition = Offset.zero;

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  PostProvider _getPostProvider(BuildContext context) {
    final provider = Provider.of<PostProvider>(context, listen: false);
    if (provider == null) {
      throw Exception('PostProvider not found in widget tree');
    }
    return provider;
  }

  Future<void> _sharePost() async {
    if (widget.images.isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    try {
      final now = DateTime.now();

      final post = Post(
        userName: 'John Karter',
        userImage: 'assets/profile.jpg',
        imageUrl: widget.images[0].path,
        caption: _captionController.text,
        taggedUsers: _taggedUsers.map((user) => user.id).toList(),
        likes: 0,
        comments: 0,
        timeAgo: _formatTimeAgo(now),
        filterIndex: widget.filterIndex,
        filterStrength: widget.filterStrength,
        timestamp: now,
      );

      await _getPostProvider(context).addPost(post);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing post: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Future<void> _showUserSearch() async {
    final selectedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (context) => UserSearchScreen(
          excludedUsers: _taggedUsers,
        ),
      ),
    );

    if (selectedUser != null && mounted) {
      setState(() {
        _taggedUsers.add(selectedUser);
      });
    }
  }

  void _removeTaggedUser(User user) {
    setState(() {
      _taggedUsers.remove(user);
    });
  }

  void _handleImageTap(TapUpDetails details) {
    if (!_showTaggingUI) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      _tagPosition = localPosition;
      _showTaggingUI = false;
    });

    _showUserSearch();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isPosting ? null : () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              setState(() {
                _showTaggingUI = !_showTaggingUI;
              });
            },
            tooltip: 'Tag People',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.images.isNotEmpty)
                        GestureDetector(
                          onTapUp: _handleImageTap,
                          child: Stack(
                            children: [
                              Image.file(File(widget.images[0].path)),
                              if (_showTaggingUI)
                                const Center(
                                  child: Text(
                                    'Tap on the image to tag someone',
                                    style: TextStyle(
                                      color: Colors.white,
                                      backgroundColor: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ..._taggedUsers.map((user) {
                                final index = _taggedUsers.indexOf(user);
                                return Positioned(
                                  left: _tagPosition.dx,
                                  top: _tagPosition.dy + (index * 30),
                                  child: _buildUserTag(user),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _captionController,
                              decoration: const InputDecoration(
                                hintText: 'Write a caption...',
                                border: InputBorder.none,
                              ),
                              maxLines: 3,
                            ),
                            if (_taggedUsers.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tagged:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: _taggedUsers
                                        .map((user) => Chip(
                                      label: Text(user.name),
                                      avatar: CircleAvatar(
                                        backgroundImage:
                                        NetworkImage(user.avatarUrl),
                                      ),
                                      onDeleted: () =>
                                          _removeTaggedUser(user),
                                    ))
                                        .toList(),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _sharePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isPosting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Share Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTag(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          const SizedBox(width: 4),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}