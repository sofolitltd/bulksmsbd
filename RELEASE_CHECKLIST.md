# Release Checklist

Run through this checklist before every git push and pub.dev publish.

## 1. Bump version

- [ ] `pubspec.yaml` — update `version: x.y.z`
- [ ] `CHANGELOG.md` — add entry for the new version

## 2. Update version references

- [ ] `README.md` — install example: `bulksmsbd: ^x.y.z`
- [ ] `demo/pubspec.yaml` — dependency: `bulksmsbd: ^x.y.z`

## 3. Verify

- [ ] `flutter analyze` (root)
- [ ] `flutter analyze` (demo/)
- [ ] `dart pub publish --dry-run`

## 4. Publish

- [ ] `git add -A && git commit -m "Bump to x.y.z - ..."`
- [ ] `git push`
- [ ] `dart pub publish --force`
