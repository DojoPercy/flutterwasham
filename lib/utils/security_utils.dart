//import 'dart:convert';

import 'package:WashAm/configuration/allowed_paths.dart';
import 'package:WashAm/configuration/app_logger.dart';
import 'package:WashAm/configuration/constants.dart';
import 'package:WashAm/configuration/local_storage.dart';

class SecurityUtils {
  static final _log = AppLogger.getLogger("SecurityUtils");

  Future<bool> isUserLoggedIn() async {
    final token = await AppLocalStorage().read(StorageKeys.jwtToken.name);

    final result = token != null;
    _log.debug(token);
    _log.trace("END:isUserLoggedIn", [result]);
    return result;
  }

  Future<bool?> isUserExists() async {
    final isExist =
        await AppLocalStorage().read(StorageKeysData.isExistingUser);

    final result = isExist;
    _log.trace("END:isUserLoggedIn", [result]);
    return result;
  }

  /// Check if the path is allowed
  ///
  /// Some paths are allowed to be accessed without JWT token like login, register, forgot-password, etc.
  static bool isAllowedPath(String path) {
    _log.trace("BEGIN:isAllowedPath", [path]);
    final result = allowedPaths.contains(path);
    _log.trace("END:isAllowedPath", [result]);
    return result;
  }
}
