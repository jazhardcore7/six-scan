import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/api_service.dart';
import 'data/datasources/database_helper.dart';
import 'data/repositories/scan_repository_impl.dart';
import 'presentation/providers/scan_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
        Provider<Uuid>(create: (_) => const Uuid()),
        ProxyProvider3<ApiService, DatabaseHelper, Uuid, ScanRepositoryImpl>(
          update: (_, api, db, uuid, __) => ScanRepositoryImpl(
            apiService: api,
            databaseHelper: db,
            uuid: uuid,
          ),
        ),
        ChangeNotifierProxyProvider<ScanRepositoryImpl, ScanProvider>(
          create: (context) => ScanProvider(
            repository: Provider.of<ScanRepositoryImpl>(context, listen: false),
          ),
          update: (_, repo, prev) => ScanProvider(repository: repo),
        ),
      ],
      child: MaterialApp(
        title: 'Six Scan',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
