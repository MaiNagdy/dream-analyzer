import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/dream_service.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const DreamAnalyzerApp());
}

class DreamAnalyzerApp extends StatelessWidget {
  const DreamAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<DreamService>(create: (_) => DreamService()),
      ],
      child: MaterialApp(
        title: 'محلل الأحلام',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'SA'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'), // Arabic
          Locale('en', 'US'), // English
        ],
        localeListResolutionCallback: (locales, supportedLocales) {
          // Always default to Arabic if the system locale is not supported
          if (locales != null) {
            for (Locale locale in locales) {
              if (supportedLocales.any((supportedLocale) => 
                  supportedLocale.languageCode == locale.languageCode)) {
                return locale;
              }
            }
          }
          // Default fallback to Arabic
          return const Locale('ar', 'SA');
        },
        localeResolutionCallback: (locale, supportedLocales) {
          // If the device locale is not supported, default to Arabic
          if (locale != null) {
            for (Locale supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return const Locale('ar', 'SA');
        },
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: const Color(0xFF6B46C1),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          
          // Better app bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          
          // Improved button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 2,
              shadowColor: const Color(0xFF6B46C1).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Better card theme
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(8),
          ),
          
          // Improved input decoration
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          
          // Text theme improvements
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          
          // Snackbar theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF374151),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        
        // Add error handling
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Material(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ في التطبيق',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'يرجى إعادة تشغيل التطبيق',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return child ?? const SizedBox();
        },
        
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in AuthProvider
    final authProvider = context.watch<AuthProvider>();

    // Show a loading indicator while the auth state is being determined initially
    if (authProvider.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Based on the isLoggedIn flag, show either HomeScreen or LoginScreen
    if (authProvider.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class _ErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const _ErrorBoundary({required this.child});

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      print('Flutter Error: ${details.exception}');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = details.exception.toString();
        });
      }
    };
  }

  void _resetError() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.refresh,
                  size: 64,
                  color: Color(0xFF6B46C1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'حدث خطأ مؤقت',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'يرجى المحاولة مرة أخرى',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _resetError,
                  child: const Text('إعادة المحاولة'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Logout and go to login screen
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                  child: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
} 