import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/contribution.dart';
import 'package:uuid/uuid.dart';

class GroupDataProvider extends ChangeNotifier {
  final List<User> _members = [];
  final List<Contribution> _contributions = [];
  final uuid = Uuid();

  List<User> get members => List.unmodifiable(_members);
  List<Contribution> get contributions => List.unmodifiable(_contributions);

  void addMember(String name) {
    final newMember = User(id: uuid.v4(), name: name, role: UserRole.member);
    _members.add(newMember);
    notifyListeners();
  }

  void addContribution(String userId, double amount) {
    final newContribution = Contribution(
      id: uuid.v4(),
      userId: userId,
      amount: amount,
      date: DateTime.now(),
    );
    _contributions.add(newContribution);
    notifyListeners();
  }

  List<Contribution> contributionsForUser(String userId) {
    return _contributions.where((c) => c.userId == userId).toList();
  }
}
