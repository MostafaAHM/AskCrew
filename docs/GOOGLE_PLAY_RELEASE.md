# Upload release to Google Play

## 1. Create an upload keystore (first time only)

If you don’t have a keystore yet:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Use a strong password and remember the alias (e.g. `upload`). **Back up the `.jks` file and passwords securely.**

## 2. Configure release signing

In the project’s `android/` directory:

1. Copy the example file:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
2. Edit `android/key.properties` and set each line (no quotes around values):

   | Key | Meaning |
   |-----|---------|
   | `storePassword` | Password you chose for the keystore |
   | `keyPassword` | Password for the key inside the keystore (often the same as `storePassword`) |
   | `keyAlias` | Alias from `keytool` (e.g. `upload` if you used `-alias upload`) |
   | `storeFile` | Path to the `.jks` file. **Resolved from the `android/` folder**, not the repo root. |

   Examples for `storeFile`:

   - Keystore in project root: `../upload-keystore.jks`
   - Keystore in your home directory (matches step 1): use the full path (e.g. `/Users/yourname/upload-keystore.jks` on macOS/Linux, or `C:\\Users\\YourName\\upload-keystore.jks` on Windows). `~` is **not** expanded in this file.

   Example file:

   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=/Users/yourname/upload-keystore.jks
   ```

`key.properties` is gitignored; do not commit it.

## 3. Bump version (optional)

In `pubspec.yaml`, update:

- **version:** e.g. `1.0.0+1` → `1.0.0+2` (or `1.0.1+1` for a new version name).  
- First number = `versionName` (user-facing).  
- Number after `+` = `versionCode` (must increase for each Play Store upload).

## 4. Build the App Bundle

From the project root:

```bash
flutter clean
flutter pub get
flutter build appbundle
```

Output:

- `build/app/outputs/bundle/release/app-release.aab`

## 5. Upload to Google Play Console

1. Open [Google Play Console](https://play.google.com/console).
2. Select the app (or create it).
3. Go to **Release** → **Production** (or **Testing** → **Internal/Closed testing**).
4. **Create new release**.
5. Upload `app-release.aab` (drag & drop or **Upload**).
6. Add **Release name** (e.g. `1.0.0 (2)`) and **Release notes**.
7. Review and **Save** → **Review release** → **Start rollout**.

## 6. Play App Signing (recommended)

If you’re asked to enroll in **Play App Signing**:

- Choose **Continue** and upload your first AAB signed with your upload key.  
- Google will use an app signing key for distribution; you keep using your upload key for future builds.

## Troubleshooting

- **Build fails with signing errors:** Ensure `android/key.properties` exists and paths/passwords are correct; `storeFile` is relative to the `android/` directory.
- **Version code already used:** Increase the build number in `pubspec.yaml` (the part after `+`).
- **App not found:** Create the app in Play Console first and complete the required store listing and policy steps.
