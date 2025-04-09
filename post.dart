class Post {
  final String userName;
  final String userImage;
  final String imageUrl;
  final String caption;
  final List<String> taggedUsers; // Changed to List<String> for user IDs
  final int likes;
  final int comments;
  final String timeAgo;
  final int filterIndex;
  final double filterStrength;
  final DateTime timestamp;

  const Post({
    required this.userName,
    required this.userImage,
    required this.imageUrl,
    required this.caption,
    this.taggedUsers = const [],
    this.likes = 0,
    this.comments = 0,
    required this.timeAgo,
    required this.filterIndex,
    required this.filterStrength,
    required this.timestamp,
  });
}