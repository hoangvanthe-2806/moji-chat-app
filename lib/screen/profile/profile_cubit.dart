

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_model.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ProfileError("Không tìm thấy user hiện tại"));
        return;
      }

      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        emit(ProfileError("User không tồn tại"));
        return;
      }

      emit(ProfileLoaded(UserModel.fromMap(data)));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

}
