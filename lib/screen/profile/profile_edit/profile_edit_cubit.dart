import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit() : super(ProfileEditInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  void pickImage(File image) {
    _selectedImage = image;
    emit(ProfileEditImagePicked());
  }

  Future<void> saveProfile({
    required String name,
    required String bio,
  }) async {
    emit(ProfileEditSaving());

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ProfileEditError("Không tìm thấy user hiện tại"));
        return;
      }

      String? avatarUrl;

      // Nếu có chọn ảnh thì upload lên Storage
      if (_selectedImage != null) {
        try {
          final fileExt = _selectedImage!.path.split('.').last.toLowerCase();
          final fileName = "$userId.$fileExt";
          
          print("Bắt đầu upload ảnh: $fileName");
          print("Đường dẫn file: ${_selectedImage!.path}");

          // Upload file lên Supabase Storage
          await _supabase.storage
              .from('avatars')
              .upload(
                fileName,
                _selectedImage!,
                fileOptions: const FileOptions(
                  upsert: true,
                  cacheControl: '3600',
                ),
              );

          print("Upload thành công, lấy public URL...");

          // Lấy public URL
          avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
          
          print("Avatar URL: $avatarUrl");
        } catch (storageError) {
          // Nếu lỗi storage, emit error và dừng lại
          print("Lỗi upload ảnh: $storageError");
          
          String errorMessage = "Lỗi upload ảnh!\n\n";
          
          if (storageError.toString().contains("Bucket not found")) {
            errorMessage += "❌ Bucket 'avatars' chưa được tạo.\n\n";
            errorMessage += "📋 Cách khắc phục:\n";
            errorMessage += "1. Vào Supabase Dashboard → Storage\n";
            errorMessage += "2. Click 'New bucket'\n";
            errorMessage += "3. Tên: avatars\n";
            errorMessage += "4. Chọn 'Public bucket'\n";
            errorMessage += "5. Click 'Create bucket'";
          } else if (storageError.toString().contains("row-level security") || 
                     storageError.toString().contains("403") ||
                     storageError.toString().contains("Unauthorized")) {
            errorMessage += "❌ RLS Policy chưa được cấu hình.\n\n";
            errorMessage += "📋 Cách khắc phục:\n";
            errorMessage += "1. Vào Supabase Dashboard → SQL Editor\n";
            errorMessage += "2. Chạy các câu lệnh SQL sau:\n\n";
            errorMessage += "CREATE POLICY \"Users can upload avatars\"\n";
            errorMessage += "ON storage.objects FOR INSERT\n";
            errorMessage += "TO authenticated\n";
            errorMessage += "WITH CHECK (bucket_id = 'avatars');\n\n";
            errorMessage += "Xem file SUPABASE_SETUP.md để biết thêm chi tiết!";
          } else {
            errorMessage += "${storageError.toString()}\n\n";
            errorMessage += "Vui lòng kiểm tra:\n";
            errorMessage += "1. Storage bucket 'avatars' đã được tạo\n";
            errorMessage += "2. RLS policy đã được cấu hình";
          }
          
          emit(ProfileEditError(errorMessage));
          return;
        }
      }

      // Update bảng users
      final updateData = <String, dynamic>{
        'name': name,
        'bio': bio,
      };
      
      if (avatarUrl != null && avatarUrl!.isNotEmpty) {
        updateData['avatar_url'] = avatarUrl;
        print("✅ Cập nhật avatar_url vào database: $avatarUrl");
      } else {
        print("⚠️ Không có avatar_url để cập nhật (avatarUrl = $avatarUrl)");
      }

      print("📝 Cập nhật dữ liệu user: $updateData");
      print("👤 User ID: $userId");
      
      final result = await _supabase.from('users').update(updateData).eq('id', userId);
      print("✅ Cập nhật database thành công!");
      print("📊 Kết quả: $result");

      emit(ProfileEditSuccess());
    } catch (e) {
      emit(ProfileEditError(e.toString()));
    }
  }
}
