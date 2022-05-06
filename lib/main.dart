import 'package:budget_tracker/screens/home.dart';
import 'package:budget_tracker/services/budget_service.dart';
import 'package:budget_tracker/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  return runApp(
    MyApp(
      sharedPreferences: sharedPreferences,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({required this.sharedPreferences, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(
            create: (_) => ThemeService(sharedPreferences)),
        ChangeNotifierProvider<BudgetService>(create: (_) => BudgetService()),
      ],
      child: Builder(builder: (context) {
        final themeService = Provider.of<ThemeService>(context);

        return MaterialApp(
          title: 'Budget Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                brightness:
                    themeService.darkTheme ? Brightness.dark : Brightness.light,
                seedColor: Colors.indigo),
          ),
          home: const Home(),
        );
      }),
    );
  }
}