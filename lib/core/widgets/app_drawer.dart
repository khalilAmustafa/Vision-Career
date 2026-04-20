import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/user_profile_service.dart';
import '../../../core/services/settings_service.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF0D1A2D) 
          : Colors.white,
      child: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: UserProfileService().getCurrentUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data = snapshot.data;
            final username = data?['username'] ?? 'User';

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF162338),
                        Color(0xFF0E1C2F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF57D6FF),
                          Color(0xFF2D7FFF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  accountName: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    user?.email ?? 'No email',
                  ),
                ),

                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    'Profile',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    l10n.settings,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(settingsService: SettingsService()),
                      ),
                    );
                  },
                ),

                const Spacer(),
                const Divider(),

                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
