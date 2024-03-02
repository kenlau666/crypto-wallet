import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecm2425_coursework/features/transaction/bloc/transaction_cubit.dart';
import 'package:ecm2425_coursework/pages/login_page.dart';
import 'package:ecm2425_coursework/utils/routes.dart';

import 'config/theme_config.dart';
import 'domain/alchemy/alchemy.dart';

class BlocProviderWrapper extends StatefulWidget {
  const BlocProviderWrapper({super.key, required this.app});

  final Widget app;

  @override
  State<BlocProviderWrapper> createState() {
    log(
      DateTime.now().toIso8601String(),
      name: "DateTime.now()",
    );
    log(
      "============================== START ==============================",
      name: "ECM2425",
    );
    return _BlocProviderWrapperState();
  }
}

class _BlocProviderWrapperState extends State<BlocProviderWrapper> {
  late final AlchemyRepository _alchemyRepository;

  @override
  void initState() {
    super.initState();
    _alchemyRepository = AlchemyRepository();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: _alchemyRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TransactionCubit>(
            lazy: false,
            create: (BuildContext context) => TransactionCubit(
              alchemyRepository: _alchemyRepository,
              privateKey:
                  '0xc5776283570a25a5b3559ba8d110e5b86dc089aa71b130ba825ccf7e1e22c5de',
            ),
          ),
        ],
        child: widget.app,
      ),
    );
  }
}

class DAX extends StatefulWidget {
  const DAX({Key? key}) : super(key: key);

  @override
  State<DAX> createState() => _DAXState();
}

class _DAXState extends State<DAX> {
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
