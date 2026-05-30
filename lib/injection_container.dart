import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rdfresh/core/notification/data/services/secure_notification_service.dart';
import 'package:rdfresh/core/notification/data/services/enhanced_notification_service.dart';
import 'package:rdfresh/features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_auth_state.dart';
import 'features/auth/domain/usecases/login_with_email.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register_with_email.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/faq/data/datasources/faq_remote_data_source.dart';
import 'features/faq/data/repositories/faq_repository_impl.dart';
import 'features/faq/domain/repositories/faq_repository.dart';
import 'features/faq/domain/usecases/get_faqs.dart';
import 'features/faq/presentation/bloc/faq_bloc.dart';

import 'features/delivery/data/datasources/order_remote_data_source.dart';
import 'features/delivery/data/repositories/order_repository_impl.dart';
import 'features/delivery/domain/repositories/order_repository.dart';
import 'features/delivery/domain/usecases/get_active_orders_usecase.dart';
import 'features/delivery/domain/usecases/complete_order_usecase.dart';
import 'features/delivery/presentation/bloc/order_bloc.dart';

import 'features/Products/data/datasources/product_remote_data_source.dart';
import 'features/Products/data/repositories/product_repository_impl.dart';
import 'features/Products/domain/repositories/product_repository.dart';
import 'features/Products/domain/usecases/get_all_products.dart';
import 'features/Products/presentation/bloc/product_bloc.dart';

import 'features/cart/data/datasources/cart_remote_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart.dart';
import 'features/cart/domain/usecases/get_cart.dart';
import 'features/cart/domain/usecases/clear_cart.dart';
import 'features/cart/domain/usecases/update_cart_quantity.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

import 'features/orders/data/datasources/order_remote_data_source.dart'
    as checkout_ds;
import 'features/orders/data/repositories/order_repository_impl.dart'
    as checkout_repo_impl;
import 'features/orders/domain/repositories/order_repository.dart'
    as checkout_repo;
import 'features/orders/domain/usecases/create_order.dart';
import 'features/orders/presentation/bloc/checkout_order_bloc.dart';

import 'core/notification/data/services/notification_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =========================
  // External / Core
  // =========================
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  sl.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);

  // =========================
  // Notification Service
  // =========================
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // =========================
  // Auth - Data Sources
  // =========================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // =========================
  // Notification Services
  // =========================
  sl.registerLazySingleton<SecureNotificationService>(
    () => SecureNotificationService(),
  );

  sl.registerLazySingleton<EnhancedNotificationService>(
    () => EnhancedNotificationService(),
  );

  // =========================
  // Auth - Repository
  // =========================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureNotificationService: sl(),
    ),
  );

  // =========================
  // Auth - Use Cases
  // =========================
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetAuthState(sl()));

  // =========================
  // Auth - Bloc
  // =========================
  sl.registerFactory(
    () => AuthBloc(
      loginWithEmail: sl(),
      registerWithEmail: sl(),
      logout: sl(),
      getAuthState: sl(),
      authRepository: sl(),
      secureNotificationService: sl(),
    ),
  );

  // =========================
  // FAQ - Data Source
  // =========================
  sl.registerLazySingleton<FaqRemoteDataSource>(
    () => FaqRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // =========================
  // FAQ - Repository
  // =========================
  sl.registerLazySingleton<FaqRepository>(() => FaqRepositoryImpl(sl()));

  // =========================
  // FAQ - Use Case
  // =========================
  sl.registerLazySingleton(() => GetFaqs(sl()));

  // =========================
  // FAQ - Bloc
  // =========================
  sl.registerFactory(() => FaqBloc(sl()));

  // =========================
  // Order - Data Source
  // =========================
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // =========================
  // Order - Repository
  // =========================
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );

  // =========================
  // Order - Use Cases
  // =========================
  sl.registerLazySingleton(() => GetActiveOrdersUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOrderUseCase(sl()));

  // =========================
  // Order - Bloc
  // =========================
  sl.registerFactory<OrderBloc>(
    () => OrderBloc(
      getActiveOrders: sl(),
      completeOrder: sl(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  // =========================
  // Product - Data Source
  // =========================
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // =========================
  // Product - Repository
  // =========================
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // =========================
  // Product - Use Case
  // =========================
  sl.registerLazySingleton(() => GetAllProducts(sl()));

  // =========================
  // Product - Bloc
  // =========================
  sl.registerFactory(() => ProductBloc(getAllProducts: sl()));

  // =========================
  // Cart - Data Source
  // =========================
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // =========================
  // Cart - Repository
  // =========================
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );

  // =========================
  // Cart - Use Cases
  // =========================
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantity(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));

  // =========================
  // Cart - Bloc
  // =========================
  sl.registerFactory(
    () => CartBloc(
      getCart: sl(),
      addToCart: sl(),
      updateCartItemQuantity: sl(),
      clearCart: sl(),
    ),
  );

  // =========================
  // Orders - Data Sources
  // =========================
  // Order creation goes through Cloud Functions (server-side)
  // QuickBooks and ShipStation credentials never reach the mobile client
  sl.registerLazySingleton<checkout_ds.CheckoutOrderRemoteDataSource>(
    () => checkout_ds.CheckoutOrderRemoteDataSourceImpl(
      firestore: sl(),
      functions: sl(),
    ),
  );

  // =========================
  // Orders - Repository
  // =========================
  sl.registerLazySingleton<checkout_repo.CheckoutOrderRepository>(
    () =>
        checkout_repo_impl.CheckoutOrderRepositoryImpl(remoteDataSource: sl()),
  );

  // =========================
  // Orders - Use Cases
  // =========================
  sl.registerLazySingleton(() => CreateCheckoutOrder(sl()));

  // =========================
  // Orders - Bloc
  // =========================
  sl.registerFactory(() => CheckoutOrderBloc(createCheckoutOrder: sl()));
}
