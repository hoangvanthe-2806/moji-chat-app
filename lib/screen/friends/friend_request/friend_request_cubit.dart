import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/friend_service.dart';
import 'friend_request_state.dart';

class FriendRequestCubit extends Cubit<FriendRequestState> {
  final FriendService _service;

  FriendRequestCubit(this._service) : super(FriendRequestInitial());

  /// Load tất cả lời mời nhận được
  Future<void> loadRequests() async {
    emit(FriendRequestLoading());
    try {
      final data = await _service.getIncomingRequests();
      // đảm bảo luôn là List<Map<String, dynamic>>
      final requests = List<Map<String, dynamic>>.from(data);
      emit(FriendRequestLoaded(requests));
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  /// Chấp nhận lời mời
  Future<void> accept(String requestId) async {
    try {
      await _service.acceptFriendRequest(requestId);
      await loadRequests(); // reload sau khi accept
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  /// Từ chối lời mời
  Future<void> decline(String requestId) async {
    try {
      await _service.rejectFriendRequest(requestId);
      await loadRequests(); // reload sau khi decline
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }
}
