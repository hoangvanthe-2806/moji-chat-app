import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(UserProfileInitial());

  final _supabase = Supabase.instance.client;

  Future<void> loadUserProfile(String userId) async {
    emit(UserProfileLoading());
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      emit(UserProfileLoaded(data, false));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
