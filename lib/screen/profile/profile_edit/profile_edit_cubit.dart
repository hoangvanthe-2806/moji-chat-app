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
          final fileExt = _selectedImage!.path.split('.').last;
          final fileName = "$userId.$fileExt";

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

          // Lấy public URL
          avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
        } catch (storageError) {
          // Nếu lỗi storage, vẫn cho phép update name và bio
          print("Lỗi upload ảnh: $storageError");
          // Có thể emit warning nhưng vẫn tiếp tục
        }
      }

      // Update bảng users
      final updateData = <String, dynamic>{
        'name': name,
        'bio': bio,
      };
      
      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await _supabase.from('users').update(updateData).eq('id', userId);

      emit(ProfileEditSuccess());
    } catch (e) {
      emit(ProfileEditError(e.toString()));
    }
  }
}
