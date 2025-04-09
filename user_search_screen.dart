import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qualhon_test/model/user.dart';
import 'package:qualhon_test/providers/user_provider.dart';

class UserSearchScreen extends StatefulWidget {
  final List<User> excludedUsers;

  const UserSearchScreen({
    super.key,
    required this.excludedUsers,
  });

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  late List<User> _filteredUsers;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _filteredUsers = _filterUsers(userProvider.users, '');
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _filteredUsers = _filterUsers(userProvider.users, _searchController.text);
    });
  }

  List<User> _filterUsers(List<User> users, String query) {
    return users
        .where((user) =>
    !widget.excludedUsers.any((u) => u.id == user.id) &&
        user.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
          ? Center(child: Text(userProvider.error!))
          : _filteredUsers.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
              onBackgroundImageError: (_, __) => const Icon(Icons.error),
            ),
            title: Text(user.name),
            onTap: () => Navigator.pop(context, user),
          );
        },
      ),
    );
  }
}