import 'package:flutter_test/flutter_test.dart';
import 'package:latres/app/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('accepts any nine-digit NIM and clears the session on logout', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AuthController(preferences, initialUsername: null);

    final loggedIn = await controller.login(
      nim: ' 012345678 ',
      password: '123',
    );

    expect(loggedIn, isTrue);
    expect(controller.isAuthenticated.value, isTrue);
    expect(controller.username.value, '012345678');
    expect(preferences.getBool('isLoggedIn'), isTrue);

    await controller.logout();

    expect(controller.isAuthenticated.value, isFalse);
    expect(preferences.getString('username'), isNull);
    expect(preferences.getBool('isLoggedIn'), isNull);
  });

  test('rejects NIMs that are not exactly nine digits', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AuthController(preferences, initialUsername: null);

    for (final nim in ['12345678', '1234567890', '1234abc89']) {
      final loggedIn = await controller.login(nim: nim, password: '123');

      expect(loggedIn, isFalse);
    }

    expect(controller.isAuthenticated.value, isFalse);
    expect(preferences.getBool('isLoggedIn'), isNull);
  });

  test('rejects the wrong password for a valid NIM', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AuthController(preferences, initialUsername: null);

    final loggedIn = await controller.login(
      nim: '124240145',
      password: 'wrong',
    );

    expect(loggedIn, isFalse);
    expect(controller.isAuthenticated.value, isFalse);
  });
}
