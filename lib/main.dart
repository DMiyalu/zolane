import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  final result = await AppBootstrap.init();

  // Needed for DateFormat(..., 'fr_FR') usages (eg. rent month labels).
  await initializeDateFormatting('fr_FR');

  runApp(
    ZolaneApp(
      firebaseReady: result.firebaseReady,
      authRepository: result.authRepository,
    ),
  );
}
