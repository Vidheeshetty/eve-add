# Saath - Flutter Client

A cross-platform mobile application for phone number verification using OTP, built with Flutter.

## Features

- Phone number verification with OTP
- Clean and responsive UI
- Cross-platform support (iOS & Android)
- Secure API communication
- Form validation

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for mobile development)
- An IDE (VS Code or Android Studio) with Flutter plugins
- Node.js backend server (see [server README](../server/README.md))

## Getting Started

### 1. Setup Flutter

Make sure you have Flutter installed and set up on your system:

```bash
# Check Flutter installation
flutter doctor
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd Saath/client
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Environment

Update the API endpoint in `lib/phone_verification_page.dart`:

```dart
// For Android emulator
Uri.parse('http://10.0.2.2:5000/api/otp')

// For iOS simulator
// Uri.parse('http://localhost:5000/api/otp')

// For physical device (replace with your computer's IP)
// Uri.parse('http://<YOUR_IP>:5000/api/otp')
```

### 5. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

## Project Structure

```
lib/
├── main.dart          # Application entry point
├── models/            # Data models
├── screens/           # App screens
├── services/          # API services
├── utils/             # Helper functions
└── widgets/           # Reusable widgets
```

## Dependencies

- `http`: ^1.2.0 - For making HTTP requests
- `provider`: ^6.1.1 - State management
- `intl`: ^0.19.0 - Internationalization and formatting
- `cupertino_icons`: ^1.0.8 - Cupertino icons

## Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS (macOS only)
flutter build ios --release
# Open in Xcode for distribution
open ios/Runner.xcworkspace
```

## Development

### Common Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate app icons
flutter pub run flutter_launcher_icons
```

### Hot Reload

- Press `r` in the terminal for hot reload
- Press `R` for a full restart
- Press `h` for all interactive options

## Troubleshooting

- **Android Emulator Issues**:
  - Ensure hardware acceleration is enabled
  - Check that HAXM is installed (for Intel processors)

- **iOS Build Issues**:
  - Run `pod install` in the `ios` directory
  - Open Xcode and resolve any signing issues

- **Network Errors**:
  - Ensure the backend server is running
  - Check CORS settings in the backend
  - For Android emulator, use `10.0.2.2` to access localhost

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Backend Placeholder (for Events API)

If you want to test the Flutter app with a mock backend, you can use the following Python (Flask) code as a starting point. This provides all the endpoints the app expects for event features, with dummy data or empty responses.

Create a file called `backend_placeholder.py` in the project root (or a new `backend/` folder) and run it with Python 3 and Flask installed.

```python
from flask import Flask, jsonify, request
app = Flask(__name__)

@app.route('/api/events', methods=['GET'])
def get_events():
    return jsonify({'events': []})

@app.route('/api/events', methods=['POST'])
def create_event():
    return jsonify({'message': 'Event created'}), 201

@app.route('/api/events/<event_id>', methods=['GET'])
def get_event_details(event_id):
    return jsonify({'event': {}})

@app.route('/api/events/join/<event_id>', methods=['POST'])
def join_event(event_id):
    return jsonify({'message': 'Joined event'})

@app.route('/api/events/user/<user_id>', methods=['GET'])
def get_user_events(user_id):
    return jsonify({'events': []})

@app.route('/api/events/confirm/<event_id>', methods=['GET'])
def confirm_event(event_id):
    return jsonify({'message': 'Event confirmed'})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

- Install Flask: `pip install flask`
- Run: `python backend_placeholder.py`

This will let your Flutter app connect to all the event endpoints it expects, even if you haven't built the real backend yet.
