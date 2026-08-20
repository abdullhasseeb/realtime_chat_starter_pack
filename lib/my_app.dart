import 'package:flutter/material.dart';
import 'package:realtime_chat/utils/constants/app_messenger.dart';
import 'package:realtime_chat/utils/theme/theme.dart';

import 'common/widgets/layouts/scroll_behaviour.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: AppMessenger.key,
      debugShowCheckedModeBanner: false,

      /// Theme
      theme: UPAppTheme.lightTheme,
      darkTheme: UPAppTheme.darkTheme,

      /// Go Router
      /// Global Scroll Behaviour
      scrollBehavior: UPScrollBehaviour(),
    );
  }
}
