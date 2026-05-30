import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rdfresh/core/routes/router.dart';
import 'package:rdfresh/core/theme/app_theme_new.dart';
import 'package:rdfresh/core/notification/data/services/secure_notification_service.dart';
import 'package:rdfresh/core/notification/data/services/enhanced_notification_service.dart';
import 'package:rdfresh/core/notification/presentation/managers/notification_manager.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationManager _notificationManager = NotificationManager();
  final SecureNotificationService _secureNotificationService =
      di.sl<SecureNotificationService>();
  final EnhancedNotificationService _enhancedNotificationService =
      di.sl<EnhancedNotificationService>();

  @override
  void initState() {
    super.initState();

    // Initialize secure notification service
    _secureNotificationService.initialize();

    // Initialize enhanced notification service and manager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enhancedNotificationService.initialize(context);
      _notificationManager.initialize(context, _enhancedNotificationService);
    });
  }

  @override
  void dispose() {
    _secureNotificationService.dispose();
    _enhancedNotificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'RD Fresh',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: goRouter,
      ),
    );
  }
}
