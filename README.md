# EVC GUI

## About

I made this app because I use the Echo Value Calculator website a lot, but I really wanted a way to save echo presets; and honestly, the web UI could use some love. So I built a cross-platform Flutter app for it!

This was also my excuse to learn Flutter, so the code might be a bit messy. If you spot something weird, that's probably why.

Full credit goes to [AstyuteChick](https://github.com/AstyuteChick) for making the original calculator. This app just wraps their awesome backend with a friendlier UI, as well as echo saving functionality.

## Screenshots

![Main Menu](.github/images/main-menu.png)
![Echo Build Screen](.github/images/build-screen.png)
![Compare Echoes Screen](.github/images/compare-screen.png)

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart 3.0+
- Compatible IDE (VS Code, Android Studio, etc.)

### Installation

#### Option 1: Run the precompiled Windows binary

1. Go to the [latest releases page](https://github.com/phnthnhnm/evc/releases/latest).
2. Download the `evc-version-windows-x64.zip` file.
3. Extract it anywhere and run `evc.exe`.

#### Option 2: Build from source

1. **Clone the repository:**
   ```sh
   git clone https://github.com/phnthnhnm/evc.git
   cd evc
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
   
> [!WARNING]
> **Disclaimer:** Only the Windows version has been tested so far. Other desktop versions (MacOS and Linux) should still work as I don't use any Windows-specific APIs. No guarantees for mobile (too different layout) and web (CORS issue).  

3. **Run the app:**

- For mobile:
  ```sh
  flutter run
  ```
- For desktop (Windows/macOS/Linux):
  ```sh
  flutter run -d windows
  flutter run -d macos
  flutter run -d linux
  ```
- For web:
  ```sh
  flutter run -d chrome
  ```

## How to Use

For instructions, check out the [official guide](https://www.echovaluecalc.com/instruct) from the Echo Value Calculator website, specifically the "Full Score" section.

## File Structure

```
lib/
  main.dart
  models/
  screens/
    settings/
  services/
  utils/
  widgets/
assets/
  attributes/
  portraits/
  stats/
  weapons/
```

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

This project is licensed under the GPL 3.0 License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Echo Value Calculator by AstyuteChick](https://www.echovaluecalc.com)
- This app uses assets from the game Wuthering Waves by Kuro Games. EVC GUI is not affiliated with or endorsed by Kuro Games. All trademarks and copyrights belong to their respective owners.
