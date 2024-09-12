// using riverpod for state management task (view model)
// Write business logic in a manner similar to Stateless widgets.
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart' as fp;
part 'auth_viewmodel.g.dart';

// run with flutter pub run build_runner build for generation
@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;
  @override
  AsyncValue<UserModel>? build() {
    // will only get userModel only when signsup or login
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );
    // print(res);
    final val = switch (res) {
      fp.Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      fp.Right(value: final r) => state = AsyncValue.data(r),
    };
    print(val);
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.login(
      email: email,
      password: password,
    );
    // print(res);
    // whenever the login is succes we ned to call setToken
    final val = switch (res) {
      fp.Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      fp.Right(value: final r) => state = _loginSuccess(r),
    };
    print(val);
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  // getting user data based on the token
  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);
      final val = switch (res) {
        fp.Left(value: final l) => state = AsyncValue.error(
            l.message,
            StackTrace.current,
          ),
        fp.Right(value: final r) => _getDataSuccess(r),
      };
      return val.value;
    }
    return null;
  }

  AsyncValue<UserModel> _getDataSuccess(UserModel user) {
    // this will tells if we want to go to signup or login pagr
    // at will tell us if the user is logged in or not
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }
}
