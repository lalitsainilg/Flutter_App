import 'package:flutter/material.dart';
import '../model/user.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network call
      await Future.delayed(const Duration(seconds: 1));

      // Replace with actual API call
      // final response = await http.get(Uri.parse('your_api_url'));
      // _users = parseUsers(response.body);

      _users = [
        User(id: '1', name: 'John Doe', avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg'),
        User(id: '2', name: 'Jane Smith', avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg'),
        User(id: '3', name: 'Mike Johnson', avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg'),
        User(id: '4', name: 'Sarah Williams', avatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg'),
      ];
    } catch (e) {
      _error = 'Failed to load users: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}