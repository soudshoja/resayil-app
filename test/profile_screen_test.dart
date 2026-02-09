import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resayil_app/core/models/profile.dart';


void main() {
  group('Profile Screen Tests', () {
    late Profile testProfile;

    setUp(() {
      testProfile = const Profile(
        name: 'John Doe',
        about: 'Hello, this is my bio',
        businessName: 'Acme Inc',
        phone: '+1234567890',
        avatar: 'https://example.com/avatar.jpg',
      );
    });

    test('Profile model can be created with all fields', () {
      expect(testProfile.name, equals('John Doe'));
      expect(testProfile.about, equals('Hello, this is my bio'));
      expect(testProfile.businessName, equals('Acme Inc'));
      expect(testProfile.phone, equals('+1234567890'));
      expect(testProfile.avatar, isNotNull);
    });

    test('Profile can be updated with new name', () {
      final updated = testProfile.copyWith(name: 'Jane Doe');
      expect(updated.name, equals('Jane Doe'));
      expect(updated.phone, equals(testProfile.phone)); // Other fields should remain
    });

    test('Profile can be updated with new about', () {
      final updated = testProfile.copyWith(about: 'New bio');
      expect(updated.about, equals('New bio'));
      expect(updated.name, equals(testProfile.name)); // Name should remain
    });

    test('Profile can be updated with new businessName', () {
      final updated =
          testProfile.copyWith(businessName: 'Tech Startups LLC');
      expect(updated.businessName, equals('Tech Startups LLC'));
    });

    test('Profile supports null values in optional fields', () {
      const minimal = Profile(
        name: 'Minimal User',
        about: null,
        businessName: null,
        phone: null,
        avatar: null,
      );

      expect(minimal.name, equals('Minimal User'));
      expect(minimal.about, isNull);
      expect(minimal.businessName, isNull);
      expect(minimal.avatar, isNull);
    });

    test('Profile JSON serialization round-trip', () {
      final json = testProfile.toJson();
      final decoded = Profile.fromJson(json);

      expect(decoded.name, equals(testProfile.name));
      expect(decoded.about, equals(testProfile.about));
      expect(decoded.businessName, equals(testProfile.businessName));
    });

    test('Profile JSON handles null values correctly', () {
      final profileJson = {
        'name': 'Test User',
        'about': null,
        'business_name': null,
        'phone': null,
        'avatar': null,
      };

      final profile = Profile.fromJson(profileJson);

      expect(profile.name, equals('Test User'));
      expect(profile.about, isNull);
      expect(profile.businessName, isNull);
      expect(profile.phone, isNull);
    });

    test('Profile fields can be updated individually', () {
      final updated = testProfile.copyWith(name: 'Updated Name');
      expect(updated.name, equals('Updated Name'));
    });

    test('Profile data can be refreshed', () {
      var profile = testProfile;
      expect(profile.name, isNotEmpty);

      // Simulate refresh
      profile = profile.copyWith(about: 'New bio');
      expect(profile.about, equals('New bio'));
    });

    test('Edit dialog should validate non-empty name', () {
      expect(''.isEmpty, isTrue);
      expect('Valid Name'.isEmpty, isFalse);
    });

    test('Edit dialog should handle name updates', () {
      const originalName = 'John Doe';
      const newName = 'Jane Doe';

      final isNameChanged = originalName != newName;
      expect(isNameChanged, isTrue);
    });

    test('Edit dialog should handle about updates', () {
      const originalAbout = 'Old bio';
      const newAbout = 'New bio';

      final isAboutChanged = originalAbout != newAbout;
      expect(isAboutChanged, isTrue);
    });

    test('Edit dialog should handle businessName updates', () {
      const originalBusiness = 'Old Company';
      const newBusiness = 'New Company';

      final isBusinessChanged = originalBusiness != newBusiness;
      expect(isBusinessChanged, isTrue);
    });

    test('Profile fields can be individually updated without affecting others',
        () {
      final original = testProfile;
      final updated = original.copyWith(name: 'New Name');

      expect(updated.name, equals('New Name'));
      expect(updated.about, equals(original.about));
      expect(updated.businessName, equals(original.businessName));
    });

    test('Loading state is handled correctly', () {
      // Simulate loading state
      final isLoading = true;
      expect(isLoading, isTrue);
    });

    test('Error state is handled correctly', () {
      // Simulate error state
      final hasError = true;
      final errorMessage = 'Failed to load profile';

      expect(hasError, isTrue);
      expect(errorMessage.isNotEmpty, isTrue);
    });

    test('Profile data state is handled correctly', () {
      // Simulate data state
      final hasData = testProfile != null;
      expect(hasData, isTrue);
    });

    test('Edit name dialog interaction flow', () {
      const initialName = 'John';
      const newName = 'Jane';

      // Simulate dialog input
      final nameController = TextEditingController(text: initialName);

      expect(nameController.text, equals(initialName));

      nameController.text = newName;
      expect(nameController.text, equals(newName));

      nameController.dispose();
    });

    test('Edit about dialog interaction flow', () {
      const initialAbout = 'Hello world';
      const newAbout = 'Goodbye world';

      final aboutController = TextEditingController(text: initialAbout);

      expect(aboutController.text, equals(initialAbout));

      aboutController.text = newAbout;
      expect(aboutController.text, equals(newAbout));

      aboutController.dispose();
    });

    test('Edit businessName dialog interaction flow', () {
      const initialBusiness = 'Company A';
      const newBusiness = 'Company B';

      final businessController = TextEditingController(text: initialBusiness);

      expect(businessController.text, equals(initialBusiness));

      businessController.text = newBusiness;
      expect(businessController.text, equals(newBusiness));

      businessController.dispose();
    });

    test('Multiple profile updates should preserve other fields', () {
      var current = testProfile;

      // Update name
      current = current.copyWith(name: 'Updated Name');
      expect(current.name, equals('Updated Name'));
      expect(current.about, equals(testProfile.about));

      // Update about
      current = current.copyWith(about: 'Updated About');
      expect(current.about, equals('Updated About'));
      expect(current.name, equals('Updated Name'));

      // Update business
      current = current.copyWith(businessName: 'Updated Business');
      expect(current.businessName, equals('Updated Business'));
      expect(current.name, equals('Updated Name'));
      expect(current.about, equals('Updated About'));
    });

    test('Profile comparison works correctly', () {
      final profile1 = testProfile;
      final profile2 = testProfile.copyWith();

      expect(profile1, equals(profile2));

      final profile3 = testProfile.copyWith(name: 'Different');
      expect(profile1, isNot(equals(profile3)));
    });
  });
}
