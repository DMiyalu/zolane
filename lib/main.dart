import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  final result = await AppBootstrap.init();

  runApp(
    ZolaneApp(
      firebaseReady: result.firebaseReady,
      authRepository: result.authRepository,
    ),
  );
}
