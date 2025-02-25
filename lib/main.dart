import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:safwa_u/fetch_screen.dart';
import 'package:safwa_u/providers/dark_theme_provider.dart';
import 'package:safwa_u/providers/orders_provider.dart';
import 'package:safwa_u/providers/products_provider.dart';
import 'package:safwa_u/providers/viewed_prod_provider.dart';
import 'package:safwa_u/screens/auth/forget_password.dart';
import 'package:safwa_u/screens/viewed_recently/viewed_recently_screen.dart';

import 'consts/theme_data.dart';

import 'inner_screen/cat_screen.dart';
import 'inner_screen/feeds_screen.dart';
import 'inner_screen/on_sale_screen.dart';
import 'inner_screen/products_details.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';

import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/btm_bar.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
    await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  )),
            );
          } else if (snapshot.hasError) {
            const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                  body: Center(
                    child: Text('An error occured'),
                  )),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) {
                return themeChangeProvider;
              }),
              ChangeNotifierProvider(
                create: (_) => ProductsProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => CartProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => WishlistProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ViewedProdProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => OrdersProvider(),
              ),
            ],
            child: Consumer<DarkThemeProvider>(
                builder: (context, themeProvider, child) {
                  return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'Flutter Demo',
                      theme: Styles.themeData(themeProvider.getDarkTheme, context),
                      home: const FetchScreen(),
                      routes: {
                        OnSaleScreen.routeName: (ctx) => const OnSaleScreen(),
                        FeedsScreen.routeName: (ctx) => const FeedsScreen(),
                        ProductDetails.routeName: (ctx) => const ProductDetails(),
                        WishlistScreen.routeName: (ctx) => const WishlistScreen(),
                        OrdersScreen.routeName: (ctx) => const OrdersScreen(),
                        ViewedRecentlyScreen.routeName: (ctx) =>
                        const ViewedRecentlyScreen(),
                        RegisterScreen.routeName: (ctx) => const RegisterScreen(),
                        LoginScreen.routeName: (ctx) => const LoginScreen(),
                        ForgetPasswordScreen.routeName: (ctx) =>
                        const ForgetPasswordScreen(),
                        CategoryScreen.routeName: (ctx) => const CategoryScreen(),
                      });
                }),
          );
        });
  }
}
