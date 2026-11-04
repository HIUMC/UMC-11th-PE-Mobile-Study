import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'core/network/api_clients.dart';
import 'data/services/week6_services.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => createMovieLogClient(),
          dispose: (_, client) => client.close(),
        ),
        Provider(create: (context) => MemberCheckService(context.read())),
        Provider(create: (context) => RatingApiService(context.read())),
        Provider(
          create: (_) => TmdbMovieService(createTmdbClient()),
          dispose: (_, service) => service.dio.close(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
