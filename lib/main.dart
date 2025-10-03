import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'client/screens/todo_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  String? SUPABSE_URL = dotenv.env['SUPABASE_URL'];
  String? SUPABSE_ANON_KEY = dotenv.env['SUPABASE_ANON_KEY'];

  if (SUPABSE_ANON_KEY == null || SUPABSE_URL == null) {
    print('MISSING REQUIRED SUPABASE CREDENTIALS');
  }

  await Supabase.initialize(url: SUPABSE_URL!, anonKey: SUPABSE_ANON_KEY!);

  runApp(const MaterialApp(home: ToDoApp()));
}
