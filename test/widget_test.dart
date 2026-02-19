// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:zolane/app/app.dart';
import 'package:zolane/features/auth/domain/entities/app_user.dart';
import 'package:zolane/features/auth/domain/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => const Stream<AppUser?>.empty();

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('Shows Firebase config screen when missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ZolaneApp(
        firebaseReady: false,
        authRepository: _FakeAuthRepository(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Firebase non configuré'), findsOneWidget);
  });
}
