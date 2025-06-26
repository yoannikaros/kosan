import 'package:flutter/material.dart';
import 'package:kosan/models/user.dart';
import 'package:kosan/screens/login_screen.dart';
import 'package:kosan/screens/change_username_screen.dart';
import 'package:kosan/screens/change_password_screen.dart';
import 'package:kosan/screens/delete_account_screen.dart';
import 'package:kosan/screens/terms_of_service_screen.dart';
import 'package:kosan/screens/privacy_policy_screen.dart';
import 'package:kosan/screens/contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentUser.email ?? 'No email set',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.red[400],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.blue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[50],
        child: ListView(
          children: [
            _buildProfileHeader(),
            _buildSectionHeader('Account'),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Change Username',
              onTap: () async {
                final newUsername = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeUsernameScreen(user: _currentUser)),
                );
                if (newUsername != null) {
                  setState(() {
                    _currentUser = User(
                      id: _currentUser.id,
                      ownerId: _currentUser.ownerId,
                      username: newUsername,
                      password: _currentUser.password,
                      role: _currentUser.role,
                      email: _currentUser.email,
                      createdAt: _currentUser.createdAt,
                    );
                  });
                }
              },
              iconColor: Colors.blue,
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen(user: _currentUser)),
                );
              },
              iconColor: Colors.green,
            ),
            _buildSettingItem(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccountScreen(user: _currentUser)),
                );
              },
              iconColor: Colors.red,
            ),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: _showLogoutDialog,
              iconColor: Colors.orange,
            ),
            _buildSectionHeader('General'),
            _buildSettingItem(
              icon: Icons.star_border,
              title: 'Rate Us',
              onTap: () {
                // TODO: Implement rate us
              },
              iconColor: Colors.amber,
            ),
            _buildSectionHeader('Support'),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                );
              },
              iconColor: Colors.indigo,
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
              iconColor: Colors.teal,
            ),
            _buildSettingItem(
              icon: Icons.contact_support_outlined,
              title: 'Contact Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                );
              },
              iconColor: Colors.deepPurple,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
} 