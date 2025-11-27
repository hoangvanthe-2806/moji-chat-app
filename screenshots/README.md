# Screenshots Directory

Place your app screenshots here.

## Recommended Screenshot Guidelines

### File Naming
- Use descriptive names: `login.png`, `chat_list.png`, `profile.png`
- Use lowercase with underscores: `friend_requests.png`
- Keep file extensions consistent: `.png` or `.jpg`

### Image Specifications
- **Resolution**: 1080x1920 (9:16 aspect ratio) for mobile
- **Format**: PNG (preferred) or JPG
- **Size**: Keep under 500KB per image for GitHub
- **Quality**: High quality, clear text and UI elements

### Screenshots to Include

**Lưu ý**: Chỉ màn hình Settings cần 2 ảnh (light và dark), các màn hình khác chỉ cần 1 ảnh.

1. **login.png** - Màn hình đăng nhập
2. **register.png** - Màn hình đăng ký
3. **chat_list.png** - Danh sách chat
4. **chat_detail.png** - Chi tiết chat
5. **search.png** - Tìm kiếm user
6. **friends.png** - Danh sách bạn bè
7. **friend_requests.png** - Lời mời kết bạn
8. **edit_profile.png** - Chỉnh sửa profile
9. **settings_light.png** / **settings_dark.png** - Settings (cần 2 ảnh: chế độ sáng và chế độ tối)

### How to Take Screenshots

#### Android
```bash
# Using ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshots/
```

#### iOS Simulator
- Cmd + S to save screenshot
- Or use: Device → Screenshot

#### Physical Device
- Use device screenshot feature
- Transfer to computer
- Rename and place in this directory

### Tips
- Remove sensitive information before committing
- Use consistent device frame (optional)
- Show key features in each screenshot
- Consider dark mode screenshots too

