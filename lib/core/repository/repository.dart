import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../app_config/app_strings.dart';
import '../di/service_locator.dart';
import '../error/exceptions.dart';
import '../network/dio_service.dart';

abstract class Repository {
  DioService dioService = getIt<DioService>();
  Future<Either<CustomException, ReturnType>> exceptionHandler<ReturnType>(
    Future<ReturnType> Function() function,
  ) async {
    try {
      return Right(await function());
    } on CustomException catch (e) {
      log("ssdsdsdsdsddsds:${e.runtimeType}");
      debugPrint(e.toString());

      return Left(e);
    } catch (e, trace) {
      debugPrint("error in exceptionHandler: ${e.toString()}");
      debugPrint("trace in exceptionHandler: ${trace.toString()}");
      return Left(
        CustomException(
          (e is CustomException)
              ? e.message.toString()
              : AppStrings.somethingWentWrong.tr(),
          code: (e is CustomException) ? e.code : null,
        ),
      );
    }
  }
}
