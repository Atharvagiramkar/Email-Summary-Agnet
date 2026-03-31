import 'package:emailsummaryagent/models/user_profile.dart';
import 'package:emailsummaryagent/screens/app_shell.dart';
import 'package:emailsummaryagent/screens/login_screen.dart';
import 'package:emailsummaryagent/screens/preferences_screen.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.backend});

  final AppBackend backend;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: backend.authState(),
      initialData: null,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(backend: backend);
        }

        return FutureBuilder<UserProfile>(
          future: backend.getOrCreateProfile(user),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              return LoginScreen(backend: backend);
            }

            if (!profile.preferencesSet) {
              return PreferencesScreen(
                backend: backend,
                profile: profile,
                isInitialSetup: true,
                initialSetupDestinationBuilder: (prefs) {
                  return AppShell(
                    backend: backend,
                    initialProfile: profile.copyWith(
                      preferences: prefs,
                      preferencesSet: true,
                    ),
                  );
                },
              );
            }

            return AppShell(backend: backend, initialProfile: profile);
          },
        );
      },
    );
  }
}
