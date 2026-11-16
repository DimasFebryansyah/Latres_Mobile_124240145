import 'package:flutter_test/flutter_test.dart';
import 'package:latres/app/controllers/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and restores the display name and bio', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = ProfileController(preferences);

    await controller.saveProfile(
      displayName: '  Serial Fan  ',
      bio: '  Menyukai drama.  ',
    );

    final restored = ProfileController(preferences);
    expect(restored.displayName.value, 'Serial Fan');
    expect(restored.bio.value, 'Menyukai drama.');
  });

  test('does not save a blank display name', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = ProfileController(preferences);

    await expectLater(
      controller.saveProfile(displayName: '  ', bio: 'Bio'),
      throwsA(isA<ProfileException>()),
    );
    expect(preferences.getString('profile_display_name'), isNull);
  });
}
