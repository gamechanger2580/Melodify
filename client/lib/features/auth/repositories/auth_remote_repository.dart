import 'dart:convert';
import 'package:client/core/constants/server_constatnt.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(AuthRemoteRepositoryRef ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  // this is if faliure then only string but if success then return MAP
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          // use  uvicorn main:app --reload --host 0.0.0.0 --port 8000
          // make your own file in core/constants/server_constants.dart
          // and push you IP address in there
          '${ServerConstatnt.serverUrl}/auth/signup',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': name,
            'email': email,
            'password': password,
          },
        ),
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201) {
        // handled error make it into good format for that we can do
        return Left(AppFailure(resBodyMap['detail']));
      }
      return Right(UserModel.fromMap(resBodyMap));
    } catch (e) {
      // print(e);
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          // use  uvicorn main:app --reload --host 0.0.0.0 --port 8000
          // make your own file in core/constants/server_constants.dart
          // and push you IP address in there
          '${ServerConstatnt.serverUrl}/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail']));
      }
      // we have to store the token as well
      // the token will signify
      // the token will authenticate the user
      // to store token if or if not null we used token
      // to ensure that token will be created and store
      return Right(UserModel.fromMap(resBodyMap['user'])
          .copyWith(token: resBodyMap['token']));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          // use  uvicorn main:app --reload --host 0.0.0.0 --port 8000
          // make your own file in core/constants/server_constants.dart
          // and push you IP address in there
          '${ServerConstatnt.serverUrl}/auth/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail']));
      }
      // we have to store the token as well
      // the token will signify
      // the token will authenticate the user
      // to store token if or if not null we used token
      // to ensure that token will be created and store
      return Right(
        UserModel.fromMap(resBodyMap).copyWith(token: token),
      );
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
