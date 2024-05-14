import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:travel_ease_fyp/LoadungScreen/loading_scrren.dart';
import 'Screens/Profile/profile_controller.dart';
import 'Services/AuthentactionRepository/authentication_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) => Get.put(AuthenticationRepository()));
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51PFI7YP7nb9HAUv5bqd5ZTkEKztBsgvXaYGVBsMg3y7kjE1PgFpZUM7kohvxoKsNWeY3msVUUM5LDluqcrHYGU2K00osKj1YJL';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const LoadingScreen(),
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
