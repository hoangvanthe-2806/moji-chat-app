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
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName = "$userId.$fileExt";

        final storagePath = await _supabase.storage
            .from('avatars')
            .upload(fileName, _selectedImage!, fileOptions: const FileOptions(upsert: true));

        avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // Update bảng users
      await _supabase.from('users').update({
        'name': name,
        'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      }).eq('id', userId);

      emit(ProfileEditSuccess());
    } catch (e) {
      emit(ProfileEditError(e.toString()));
    }
  }
}
