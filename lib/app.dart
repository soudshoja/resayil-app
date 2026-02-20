import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resayil_app/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/config/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/chats/providers/chats_provider.dart';
import 'features/settings/providers/locale_provider.dart';

class ResayilApp extends ConsumerWidget {
  const ResayilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);

    // Initialize connectivity-based retry for pending messages ONLY when authenticated
    ref.listen(authStateProvider, (previous, current) {
      if (current.hasValue && current.value == true) {
        ref.read(pendingMessagesRetryProvider);
      }
    });

    return MaterialApp(
      title: 'Resayil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: authState.when(
        data: (_) {
          final router = ref.watch(routerProvider);
          return _RouterWrapper(router: router);
        },
        loading: () => const _LoadingScreen(),
        error: (error, stackTrace) => _ErrorScreen(
          error: error,
          onRetry: () {
            ref.invalidate(authStateProvider);
          },
        ),
      ),
    );
  }
}

class _RouterWrapper extends StatelessWidget {
  final GoRouter router;

  const _RouterWrapper({required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Resayil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111b21),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00a884)),
            ),
            const SizedBox(height: 16),
            Text(
              'Resayil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFe9edef),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _ErrorScreen({
    required this.error,
    this.onRetry,
  });

  String _getErrorTitle(Object error) {
    final errorStr = error.toString();
    if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return 'Session Expired';
    }
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'Connection Timeout';
    }
    if (errorStr.contains('Network') || errorStr.contains('SocketException')) {
      return 'Network Error';
    }
    return 'Initialization Error';
  }

  String _getErrorMessage(Object error) {
    final errorStr = error.toString();
    if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return 'Your session has expired. Please login again.';
    }
    if (errorStr.contains('Firebase initialization timed out')) {
      return 'Firebase took too long to initialize. This usually happens with slow network connections. Tap Retry to try again.';
    }
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'The connection took too long. Please check your network and try again.';
    }
    if (errorStr.contains('Network') || errorStr.contains('SocketException')) {
      return 'Unable to connect to the network. Please check your internet connection.';
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111b21),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFef5350),
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  _getErrorTitle(error),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFFe9edef),
                        fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _getErrorMessage(error),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8696a0),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (onRetry != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00a884),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Color(0xFFe9edef),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
