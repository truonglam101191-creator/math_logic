FEATURES
========

Tóm tắt: tập tài liệu ngắn liệt kê các chức năng chính của ứng dụng và vị trí mã nguồn để tham khảo nhanh.

## Tổng quan
- Loại dự án: Flutter (đa nền tảng: Android/iOS/web/desktop).
- Entry point: `lib/main.dart`.
- Quản lý dependency & assets: `pubspec.yaml`.

## Mini-games
1. Pikachu Connect
   - Mô tả: game ghép cặp với đường nối giữa 2 ô. Có animation đường nối, hint, nhiều mức độ khó.
   - File chính:
     - UI / page: `lib/features/mini_game/pikachu_connect_game/pikachu_connect_game_page.dart`
     - Logic/board: `lib/features/mini_game/pikachu_connect_game/logic/pikachu_board.dart`
     - Widgets: `lib/features/mini_game/pikachu_connect_game/widgets/` (ví dụ `board_widget.dart`, `tile_widget.dart`)
   - Tính năng: animated connection line (màu đen), hint sau 3 lựa chọn sai, difficulty (easy/medium/hard), persistence hook cho số kết nối, sử dụng Material icons cho tiles.

2. Tetris
   - Mô tả: mini-game kiểu Tetris.
   - File: `lib/features/mini_game/pages/tetris_game.dart`.
   - Ghi chú: đã sửa lifecycle của Timer để tránh lỗi setState sau dispose.

3. Các trò khác / packages
   - Pac-men / trò khác: `packages/pac_men_game/`.
   - Shared internal package: `packages/oziapi/`.

## Ads & Monetization
- Banner / adaptive ads:
  - `lib/cores/widgets/admanager_banner.dart` (Ad Manager / DFP)
  - `lib/cores/widgets/admob_adapter_banner.dart` (BannerAd / adaptive)
- Ad controller: folder `lib/cores/adsmob/` (nếu có) quản lý interstitial/reward.
- Toggle hiển thị: `Shared.instance.isShowAds` (ở `lib/cores/extentions/shared.dart`).
- Ghi chú: các banner đã được điều chỉnh để hiển thị nhãn "Ad" và khung tách biệt.

## Chat AI
- Lịch sử chat / UI: `lib/features/chat_ai/history_chatai_page.dart`.
- Tính năng: hiển thị lịch sử, empty state handling.

## Firebase & Backend
- Firebase config: `android/app/google-services.json` và iOS Pods trong `ios/`.
- SDKs: Firestore, Firebase Core, App Check, v.v. (thấy trong `ios/Pods/` và cấu hình Android).

## Localization (L10n)
- Cấu hình: `l10n.yaml`.
- Code generate: `lib/gen/` và folder `l10n/`.

## Assets
- Hình ảnh / Âm thanh / Maps:
  - `assets/`, `audio/`, `images/`, `map.tmj`.
- Web public assets: `public/` và `web/`.

## CI / Build / Release
- GitHub Actions workflow: `.github/workflows/android-release.yml` (đã tune để cache và build nhanh hơn).
- Shorebird config: `shorebird.yaml`.
- Keystore / builds: `builds/limit_123456.jks` và các file release chứa trong `builds/`.

## Tests
- Unit tests: `test/fraction_utils_test.dart`.
- Gợi ý: nên thêm tests cho game logic (Pikachu board matching / hint logic).

## Devtools & Scripts
- Git helper scripts: `cleanup_git.sh`, `fix_git_push.sh`, `git_cleanup_commands.md`.
- Analyzer rules: `analysis_options.yaml`, `devtools_options.yaml`.

## Các file/đường dẫn quan trọng khác
- `lib/cores/widgets/` — widgets dùng chung (ads, UI helpers).
- `lib/cores/extentions/` — extension & shared helpers (ví dụ `shared.dart`).
- `lib/features/` — nơi chứa các tính năng / pages theo domain.

## Kiểm tra & Chạy nhanh (local)
- Cài Flutter (stable), sau đó:

```bash
flutter pub get
flutter run -d <device>
```

- Để build APK nhanh (áp dụng tương tự cho CI):

```bash
flutter build apk --release --target-platform android-arm64 --no-shrink
```

## Gợi ý tiếp theo
- Muốn tôi commit file này cho bạn? (Đã tạo `FEATURES.md` trong repo.)
- Tôi có thể tạo thêm `FEATURES_DETAILED.md` tự động liệt kê từng page/class nếu bạn muốn.

---
File này được tạo tự động để giúp tra cứu nhanh chức năng chính trong repo.
