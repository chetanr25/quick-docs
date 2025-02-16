import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_docs/screens/auth/auth_screen.dart';
import 'package:quick_docs/firebase_options.dart';
import 'package:quick_docs/screens/home/first_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:chaquopy/chaquopy.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Python
  try {
    await Chaquopy.executeCode('print("Python is ready")');
  } catch (e) {
    print("Failed to initialize Python: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xff9fc9ff),
          primaryContainer: Color(0xff00325b),
          secondary: Color(0xffffb59d),
          secondaryContainer: Color(0xff872100),
          tertiary: Color(0xff86d2e1),
          tertiaryContainer: Color(0xff004e59),
          appBarColor: Color(0xff872100),
          error: Color(0xffcf6679),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        textTheme: GoogleFonts.exo2TextTheme(),
      ),
      // /*
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const Scaffold(
              body: Center(
                heightFactor: 10,
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // return AuthScreen();
            return const FirstPage();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

Future<Map<String, dynamic>> extractTextFromPdf(String pdfPath) async {
  try {
    final result = await Chaquopy.executeCode('''
from pdf_extractor import extract_text_from_pdf, process_text
import os

if not os.path.exists("$pdfPath"):
    result = {"status": "error", "message": "File not found"}
else:
    result = extract_text_from_pdf("$pdfPath")
    if result["status"] == "success":
        processed = process_text(result["text"])
        if processed["status"] == "success":
            result["processed_text"] = processed["processed_text"]
result
''');

    if (result is Map) {
      return result as Map<String, dynamic>;
    } else {
      return {"status": "error", "message": "Invalid response format"};
    }
  } catch (e) {
    return {"status": "error", "message": e.toString()};
  }
}
