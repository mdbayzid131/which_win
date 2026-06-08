import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/core/bindings/initial_binding.dart';

class WhichWinApp extends StatelessWidget {
  const WhichWinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xffffffff),
              scrolledUnderElevation: 0,
            ),
            scaffoldBackgroundColor: const Color(0xffffffff),
          ),
          themeMode: ThemeMode.light,
          initialRoute: AppRoutes.initial,
          initialBinding: InitialBinding(),
          getPages: AppPages.routes,
        );
      },
    );
  }
}
