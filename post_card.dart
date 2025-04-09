// // lib/widgets/post_card.dart
// import 'package:flutter/material.dart';
// import 'package:qualhon_test/model/post.dart';
// import '../model/post.dart';
//
// class PostCard extends StatelessWidget {
//   final Post post;
//
//   const PostCard({super.key, required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // User info
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(post.userImage),
//             ),
//             title: Text(post.userName),
//             trailing: IconButton(
//               icon: const Icon(Icons.more_vert),
//               onPressed: () {},
//             ),
//           ),
//
//           // Post image
//           AspectRatio(
//             aspectRatio: 1,
//             child: Image.network(
//               post.imageUrl,
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           // Actions
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.favorite_border),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.comment_outlined),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {},
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.bookmark_border),
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//           ),
//
//           // Likes
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               '${post.likes} likes',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//
//           // Caption
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: RichText(
//               text: TextSpan(
//                 style: DefaultTextStyle.of(context).style,
//                 children: [
//                   TextSpan(
//                     text: '${post.userName} ',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   TextSpan(text: post.caption),
//                 ],
//               ),
//             ),
//           ),
//
//           // Comments
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'View all ${post.comments} comments',
//               style: TextStyle(
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//
//           // Time ago
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Text(
//               post.timeAgo,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }