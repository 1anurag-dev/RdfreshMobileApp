import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rdfresh/features/Support/presentation/screens/support_screen.dart';
import 'package:rdfresh/features/faq/presentation/screens/faq_screen.dart';
import '../../features/auth/presentation/pages/login_signup/singup_screen.dart';
import '../../features/delivery/presentation/screens/delivery_status_screen.dart';
import '../../features/faq/presentation/bloc/faq_bloc.dart';
import '../../features/faq/presentation/bloc/faq_event.dart';
import '../../features/home/presentation/pages/Home_Screen.dart';
import '../../features/auth/presentation/pages/login_signup/login_screen.dart';
import '../../core/notification/presentation/screens/enhanced_notification_screen.dart';
import '../../features/Products/presentation/pages/products_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_event.dart';
import '../../features/orders/presentation/bloc/checkout_order_bloc.dart';
import '../../features/calculator/presentation/pages/calculator_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../injection_container.dart' as di;
import 'app_routes.dart';

import '../../features/home/presentation/widgets/main_wrapper.dart';
import '../../features/home/presentation/pages/more_page.dart';
import '../../features/home/presentation/pages/downloads_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Top-level routes (No Bottom Bar)
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: 'checkout',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => di.sl<CartBloc>()
                ..add(LoadCart(FirebaseAuth.instance.currentUser?.uid ?? '')),
            ),
            BlocProvider(create: (_) => di.sl<CheckoutOrderBloc>()),
          ],
          child: const CheckoutPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      name: 'cart',
      builder: (context, state) {
        return BlocProvider(
          create: (_) =>
              di.sl<CartBloc>()
                ..add(LoadCart(FirebaseAuth.instance.currentUser?.uid ?? '')),
          child: const CartPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const EnhancedNotificationScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.deliveryStatus}/:orderId',
      name: 'delivery-status',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return DeliveryStatusScreen(orderId: orderId);
      },
    ),

    // Shell Route for persistent Bottom Bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },

      branches: [
        // Branch 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch 2: Products
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.products,
              name: 'products',
              builder: (context, state) => const ProductsPage(),
            ),
          ],
        ),
        // Branch 3: Calculator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.calculator,
              name: 'calculator',
              builder: (context, state) => const CalculatorPage(),
            ),
          ],
        ),
        // Branch 4: More
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              name: 'more',
              builder: (context, state) => const MorePage(),
            ),
            GoRoute(
              path: AppRoutes.downloads,
              name: 'downloads',
              builder: (context, state) => const DownloadsPage(),
            ),
            GoRoute(
              path: AppRoutes.support,
              name: 'Support',
              builder: (context, state) => const SupportScreen(),
            ),
            GoRoute(
              path: '/faq',
              name: 'faq',
              builder: (context, state) {
                return BlocProvider(
                  create: (_) => di.sl<FaqBloc>()..add(FetchFaqs()),
                  child: const FaqScreen(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
