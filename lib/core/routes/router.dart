import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rdfresh/features/Support/presentation/screens/support_screen.dart';
import 'package:rdfresh/features/faq/presentation/screens/faq_screen.dart';
import '../../features/auth/presentation/pages/login_signup/singup_screen.dart';
import '../../features/delivery/presentation/screens/delivery_status_screen.dart';
import '../../features/delivery/presentation/screens/delivery_confirmed_screen.dart';
import '../../features/delivery/presentation/screens/active_orders_screen.dart';
import '../../features/delivery/presentation/bloc/order_bloc.dart';
import '../../features/delivery/presentation/bloc/order_event.dart';
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
import '../../features/about/presentation/pages/about_page.dart';
import '../../features/legal/presentation/pages/privacy_policy_page.dart';
import '../../features/legal/presentation/pages/terms_of_service_page.dart';
import '../../features/auth/presentation/pages/email_verification_screen.dart';
import '../../features/delivery/presentation/screens/bag_change_screen.dart';

const _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.privacyPolicy,
  AppRoutes.termsOfService,
  AppRoutes.emailVerification,
  AppRoutes.home,
  AppRoutes.products,
  AppRoutes.about,
  AppRoutes.calculator,
  AppRoutes.more,
  AppRoutes.faq,
  AppRoutes.support,
  AppRoutes.downloads,
};

final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

    if (!isLoggedIn && !isPublicRoute) {
      return AppRoutes.login;
    }

    return null;
  },
  routes: [
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
      path: AppRoutes.privacyPolicy,
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: AppRoutes.termsOfService,
      name: 'terms-of-service',
      builder: (context, state) => const TermsOfServicePage(),
    ),
    GoRoute(
      path: AppRoutes.emailVerification,
      name: 'email-verification',
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const EnhancedNotificationScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.bagChange}/:orderId',
      name: 'bag-change',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return BagChangeScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.activeOrders,
      name: 'active-orders',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => di.sl<OrderBloc>()..add(LoadActiveOrders()),
          child: const ActiveOrdersScreen(),
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.deliveryStatus}/:orderId',
      name: 'delivery-status',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return DeliveryStatusScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.deliveryConfirmed,
      name: 'delivery-confirmed',
      builder: (context, state) {
        final queryParams = state.uri.queryParameters;
        return DeliveryConfirmedScreen(
          orderId: queryParams['orderId'] ?? '',
          rating: int.tryParse(queryParams['rating'] ?? ''),
          feedback: queryParams['feedback'],
        );
      },
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        // 0 — About
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.about,
              name: 'about',
              builder: (context, state) => const AboutPage(),
            ),
          ],
        ),
        // 1 — Products
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.products,
              name: 'products',
              builder: (context, state) => const ProductsPage(),
            ),
          ],
        ),
        // 2 — Home (center, default)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // 3 — Calculator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.calculator,
              name: 'calculator',
              builder: (context, state) => const CalculatorPage(),
            ),
          ],
        ),
        // 4 — More
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
