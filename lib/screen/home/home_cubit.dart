import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';



class HomeCubit extends Cubit<int> {
  HomeCubit() : super(0); // tab mặc định = 0 (Chat)
  void changeTab(int index) => emit(index);
}