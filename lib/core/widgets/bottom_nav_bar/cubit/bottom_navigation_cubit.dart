import 'package:bloc/bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';

part 'bottom_navigation_state.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(BottomNavigationInitial());

  StatefulNavigationShell? navigationShell;
  int currentIndex = 0;
  void goToBranch(int index) {
    if (navigationShell != null) {
      navigationShell!.goBranch(index);
      currentIndex = index;
      emit(ChangeBottomNavigationBranch(index));
    }
  }

  getSections() async {
    emit(BottomNavigationLoading());
  }

  bool isSectionVisible() {
    return true;
  }
}
