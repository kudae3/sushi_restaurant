import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sushi_restaurant/theme/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _displayName(Map<String, dynamic>? data, User user) {
    final username = data?['username'] as String?;
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }

    final email = data?['email'] as String? ?? user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Guest';
  }

  Widget _infoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: secondaryColor.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: user == null
          ? const Center(
              child: Text(
                'No user signed in.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load profile.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data?.data();
                final name = _displayName(data, user);
                final email = (data?['email'] as String?) ?? user.email ?? 'No email found';
                final uid = user.uid;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F2F2),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 84,
                              width: 84,
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: primaryColor,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            // const SizedBox(height: 6),
                            // Text(
                            //   'Saved in Firestore under users/$uid',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: Colors.grey.shade700,
                            //     fontSize: 13.5,
                            //   ),
                            // ),
                            const SizedBox(height: 14),
                            _infoTile(
                              label: 'Username',
                              value: name,
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 24),
                            _infoTile(
                              label: 'Email',
                              value: email,
                              icon: Icons.email_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
