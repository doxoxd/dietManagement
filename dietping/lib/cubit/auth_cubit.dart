import 'dart:convert';
import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api.dart';
import '../model/user.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // 사용자 ID 확인 함수
  void checkUserId({
    required var id,
    required var name,
    required var email,
    required var password,
    required var nickname,
    required int age,
    required var gender,
    required double kcal,
    required double height,
    required double weight
  }) async {
    try {
      emit(AuthLoading());
      bool isAvailable = await AuthService().checkUserId(id:id);

      if (isAvailable == true) {
        // 아이디가 사용 가능할 때 회원가입 진행
        User user = await AuthService().signUp(
            id: id,
            name: name,
            email: email,
            password: password,
            nickname: nickname,
            age: age,
            gender: gender,
            kcal: kcal,
            height: height,
            weight: weight
        );
        emit(AuthSuccess(user)); // 성공 시 상태 전환
      } else {
        // 아이디가 중복될 때 오류 메시지 전달
        emit(AuthFailed('Id is already in use. Please try another id'));
      }
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }

  void signIn({
    required var id,
    required var password,
  }) async {
    try {
      emit(AuthLoading());
      User user = await AuthService().signIn(id: id, password: password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }

  void signUp({
    required var id,
    required var name,
    required var email,
    required var password,
    required var nickname,
    required int age,
    required var gender,
    required double kcal,
    required double height,
    required double weight
  }) async {
    try {
      emit(AuthLoading());
      User user = await AuthService().signUp(id: id, name: name, email: email, password: password, nickname:nickname, age:age,gender: gender, kcal: kcal, height: height, weight: weight);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }

  void signOut() async {
    try {
      emit(AuthLoading());
      await AuthService().signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailed(e.toString()));
    }
  }

//  void getCurrentUser(String id) async {
//    try {
//      User user = await UserService().getUserById(id);
//      emit(AuthSuccess(user));
//    } catch (e) {
//      emit(AuthFailed(e.toString()));
//    }
//  }
}