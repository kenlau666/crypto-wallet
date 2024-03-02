import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ecm2425_coursework/utils/global_bloc_observer.dart';
import 'app.dart';
import 'providers/wallet_provider.dart';
import 'package:ecm2425_coursework/utils/routes.dart';
import 'package:ecm2425_coursework/pages/login_page.dart';
import 'package:ecm2425_coursework/config/theme_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

void main() async {
  await dotenv.load(fileName: ".env");
  Bloc.observer = const GlobalBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

  // Load the private key
  WalletProvider walletProvider = WalletProvider();
  await walletProvider.loadPrivateKey();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context)=>walletProvider),
    ],
    //   child: const MyApp(),
    child: const BlocProviderWrapper(
      app: DAX(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.getTheme(isDarkMode: false),
        darkTheme: ThemeConfig.getTheme(isDarkMode: true),
        initialRoute: MyRoutes.loginRoute,
        routes: {
          MyRoutes.loginRoute: (context) => const LoginPage(),
        },
      ),
    );
  }
}
