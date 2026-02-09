# Branded Splash Screen Configuration for iOS

## Overview
The Resayil app now features a branded, modern splash screen that replaces the generic Flutter splash. The splash screen is configured via the `LaunchScreen.storyboard` file and displays immediately when the app launches.

## Design Details

### Colors Used
- **Background**: `#111b21` (RGB: 17, 27, 33) - Dark theme background
- **Accent**: `#00a884` (RGB: 0, 168, 132) - Resayil brand green
- **Text Primary**: `#e9edef` (RGB: 233, 237, 239) - Light text
- **Text Secondary**: `#8696a0` (RGB: 134, 150, 160) - Muted text

### Visual Elements
1. **Background**: Full-screen dark background (#111b21)
2. **Accent Circle**: Subtle semi-transparent green circle (10% opacity) as visual accent
3. **Logo Icon**: Chat bubble emoji (💬) in the accent green color
4. **App Title**: "Resayil" in bold sans-serif font
5. **Tagline**: "Secure Messaging" in smaller secondary text

### Layout
The splash screen is centered and uses Auto Layout constraints for full device compatibility:
- Logo icon positioned in the upper-middle area
- App title positioned below the logo
- Tagline positioned below the app title
- All elements are horizontally centered

## Files Modified

### 1. `/ios/Runner/Base.lproj/LaunchScreen.storyboard`
- **Type**: iOS Storyboard (XML-based UI definition)
- **Changes**:
  - Replaced generic white background with dark theme color (#111b21)
  - Removed deprecated `LaunchImage` asset reference
  - Added custom UI elements:
    - Background view with dark color
    - Subtle accent circle
    - Logo icon (chat bubble emoji)
    - "Resayil" title label
    - "Secure Messaging" subtitle label
  - All elements use Auto Layout constraints for responsive design

### 2. `/ios/Runner/Info.plist`
- **Status**: No changes needed
- **Note**: Already correctly configured with `UILaunchStoryboardName: LaunchScreen`

## Technical Specifications

### Storyboard Configuration
- **Toolsversion**: 13771 (Xcode 9+)
- **Target Runtime**: iOS.CocoaTouch
- **Launch Screen**: YES
- **Auto Layout**: YES
- **Device**: Configured for iPhone (portrait orientation)

### Responsive Design
- Uses Auto Layout constraints for all elements
- Supports all iOS device sizes (iPhones from SE to Pro Max)
- Supports landscape orientation
- Colors use sRGB color space for optimal display

### Color Space
All colors use `sRGB` color space (custom colorSpace="sRGB") for consistent rendering across devices.

## Dark Mode Support
The splash screen uses the dark theme by default, which is optimized for:
- iOS 13+ dark mode
- OLED displays (better power efficiency)
- Reduced eye strain
- Consistent with app's WhatsApp-like dark theme

## Testing the Splash Screen

### On Simulator
```bash
# Build and run on iOS simulator
cd ~/resayil_app
export PATH="$HOME/flutter/bin:$PATH"
flutter run
```

### On Device
```bash
# Build and run on connected iOS device
flutter run
```

### Visual Verification
1. Launch the app
2. Observe the splash screen displays for ~1-2 seconds before the app loads
3. Verify elements are centered and properly positioned
4. Check that colors match the expected dark theme
5. Ensure text is clearly visible on the dark background

## iOS Version Compatibility
- **Minimum**: iOS 11.0+ (inherited from Flutter requirements)
- **Tested**: iOS 13+ (modern devices)
- **Supports**: All standard iPhones and iPads in portrait mode

## Future Enhancements
Potential improvements for future iterations:
1. Add animated splash screen (UIView animation)
2. Add gradient background
3. Replace emoji with custom vector icon image
4. Add app version number
5. Support landscape orientation with adjusted layout

## Notes
- The splash screen displays before the Flutter engine loads
- The transition from splash to app is handled automatically by iOS
- No additional configuration is needed in the Flutter app code
- The storyboard is cached by iOS, ensuring fast load times

## References
- Apple Design Guidelines: https://developer.apple.com/design/human-interface-guidelines/launch-screens
- iOS Launch Screen Documentation: https://developer.apple.com/documentation/uikit/uilaunchscreenview
- Flutter iOS Launch Screen: https://flutter.dev/docs/deployment/ios#adding-a-launch-screen-for-ios
