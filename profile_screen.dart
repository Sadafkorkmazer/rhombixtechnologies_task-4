import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFEAF0FF),
              child: Icon(
                Icons.person,
                size: 54,
                color: Color(0xFF2457C5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? 'Voter',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(user?.email ?? 'No email available'),
            const SizedBox(height: 32),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Account status'),
                subtitle: Text(
                  user?.emailVerified == true
                      ? 'Email verified'
                      : 'Email verification not confirmed',
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}