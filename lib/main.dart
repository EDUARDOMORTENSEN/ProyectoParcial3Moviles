import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'di/injection_container.dart';
import 'domain/entities/training_entity.dart';

import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/training_viewmodel.dart';
import 'presentation/viewmodels/statistics_viewmodel.dart';
import 'presentation/viewmodels/ranking_viewmodel.dart';

import 'presentation/views/splash_screen.dart';
import 'presentation/views/auth/login_screen.dart';
import 'presentation/views/auth/register_screen.dart';
import 'presentation/views/home/home_screen.dart';
import 'presentation/views/training/training_screen.dart';
import 'presentation/views/training/training_detail_screen.dart';
import 'presentation/views/statistics/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "dummy_api_key_for_ui_testing",
          appId: "1:1234567890:web:1234567890abcdef",
          messagingSenderId: "1234567890",
          projectId: "dummy-project",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1F38),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            loginUseCase: di.loginUseCase,
            registerUseCase: di.registerUseCase,
            logoutUseCase: di.logoutUseCase,
            authRepository: di.authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TrainingViewModel(
            saveTrainingUseCase: di.saveTrainingUseCase,
            getTrainingHistoryUseCase: di.getTrainingHistoryUseCase,
            routeRepository: di.routeRepository,
            rankingRepository: di.rankingRepository,
            locationService: di.locationService,
            stepCounterService: di.stepCounterService,
            restApiDatasource: di.restApiDatasource,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsViewModel(
            getStatisticsUseCase: di.getStatisticsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RankingViewModel(
            getRankingUseCase: di.getRankingUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.training: (_) => const TrainingScreen(),
          AppRoutes.statistics: (_) => const StatisticsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.trainingDetail) {
            final training = settings.arguments as TrainingEntity;
            return MaterialPageRoute(
              builder: (_) => TrainingDetailScreen(training: training),
            );
          }
          return null;
        },
      ),
    );
  }
}
