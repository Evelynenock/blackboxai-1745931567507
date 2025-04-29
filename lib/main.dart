import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'models/contribution.dart';
import 'providers/group_data_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GroupDataProvider(),
      child: GroupContributionApp(),
    ),
  );
}

class GroupContributionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Contributions (Tsh.)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoleSelectionScreen(),
    );
  }
}

enum UserRole { admin, contributionManager, member }

class RoleSelectionScreen extends StatelessWidget {
  void navigateToRoleScreen(BuildContext context, UserRole role) {
    Widget screen;
    switch (role) {
      case UserRole.admin:
        screen = AdminScreen();
        break;
      case UserRole.contributionManager:
        screen = ContributionManagerScreen();
        break;
      case UserRole.member:
        screen = MemberScreen();
        break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Choose your role to continue',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToRoleScreen(context, UserRole.admin),
              child: Text('Admin'),
            ),
            ElevatedButton(
              onPressed: () => navigateToRoleScreen(context, UserRole.contributionManager),
              child: Text('Contribution Manager'),
            ),
            ElevatedButton(
              onPressed: () => navigateToRoleScreen(context, UserRole.member),
              child: Text('Member'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _addMember(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      Provider.of<GroupDataProvider>(context, listen: false).addMember(name);
      _nameController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = Provider.of<GroupDataProvider>(context).members;
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Manage Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Member Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addMember(context),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: members.isEmpty
                  ? Center(child: Text('No members added yet.'))
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return ListTile(
                          title: Text(member.name),
                          subtitle: Text('Role: Member'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContributionManagerScreen extends StatefulWidget {
  @override
  _ContributionManagerScreenState createState() => _ContributionManagerScreenState();
}

class _ContributionManagerScreenState extends State<ContributionManagerScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  void _addContribution(BuildContext context) {
    final amountText = _amountController.text.trim();
    final userId = _userIdController.text.trim();
    if (amountText.isNotEmpty && userId.isNotEmpty) {
      final amount = double.tryParse(amountText);
      if (amount != null && amount > 0) {
        Provider.of<GroupDataProvider>(context, listen: false).addContribution(userId, amount);
        _amountController.clear();
        _userIdController.clear();
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contributions = Provider.of<GroupDataProvider>(context).contributions;
    return Scaffold(
      appBar: AppBar(
        title: Text('Contribution Manager Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Add Contribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Member ID',
              ),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (Tsh.)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addContribution(context),
              child: Text('Add Contribution'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: contributions.isEmpty
                  ? Center(child: Text('No contributions added yet.'))
                  : ListView.builder(
                      itemCount: contributions.length,
                      itemBuilder: (context, index) {
                        final contribution = contributions[index];
                        return ListTile(
                          title: Text('Tsh. \${contribution.amount.toStringAsFixed(2)}'),
                          subtitle: Text('Member ID: \${contribution.userId} - Date: \${contribution.date.toLocal().toString().split(" ")[0]}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final TextEditingController _userIdController = TextEditingController();
  List<Contribution> contributions = [];

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _searchContributions() {
    final userId = _userIdController.text.trim();
    if (userId.isNotEmpty) {
      final provider = Provider.of<GroupDataProvider>(context, listen: false);
      final results = provider.contributionsForUser(userId);
      setState(() {
        contributions = results;
      });
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No contributions found for Member ID: \$userId')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Member Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'View Your Contributions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Enter Your Member ID',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchContributions,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: contributions.isEmpty
                  ? Center(child: Text('No contributions to display.'))
                  : ListView.builder(
                      itemCount: contributions.length,
                      itemBuilder: (context, index) {
                        final contribution = contributions[index];
                        return ListTile(
                          title: Text('Tsh. \${contribution.amount.toStringAsFixed(2)}'),
                          subtitle: Text('Date: \${contribution.date.toLocal().toString().split(" ")[0]}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
