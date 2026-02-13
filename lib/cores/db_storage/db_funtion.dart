import 'dart:convert';

import 'package:logic_mathematics/cores/db_storage/db_storage.dart';
import 'package:logic_mathematics/cores/enum/enum_data_key.dart';
import 'package:logic_mathematics/cores/enum/enum_difficulty_type.dart';
import 'package:logic_mathematics/cores/extentions/shared.dart';
import 'package:logic_mathematics/cores/models/groupchatai_model.dart';
import 'package:logic_mathematics/cores/models/option_quesion_model.dart';
import 'package:logic_mathematics/main.dart';

class DataBaseFuntion {
  final _dataBase = serviceLocator<DbStorage>();

  // save star
  Future<void> saveStar(int value) async {
    await _dataBase.save(DataBaseKey.star.name, value.toString());
  }

  Future<int> getStar() async {
    final data = await _dataBase.get(DataBaseKey.star.name);
    return data is String
        ? data.isNotEmpty
              ? int.parse(data)
              : 10
        : 10;
  }

  // Word Puzzle Best Times
  Future<void> saveWordPuzzleBestTime(String category, int seconds) async {
    final key = 'word_puzzle_time_$category';
    await _dataBase.save(key, seconds.toString());
  }

  Future<String> getWordPuzzleBestTime(String category) async {
    final key = 'word_puzzle_time_$category';
    final data = await _dataBase.get(key);
    if (data is String && data.isNotEmpty) {
      int seconds = int.parse(data);
      String mm = (seconds ~/ 60).toString().padLeft(2, '0');
      String ss = (seconds % 60).toString().padLeft(2, '0');
      return "$mm:$ss";
    }
    return '00:00';
  }

  Future<Map<String, String>> getAllWordPuzzleBestTimes() async {
    List<String> categories = [
      'Face',
      'Fruits',
      'Vegetables',
      'Colors',
      'Occupations',
      'Musical Instruments',
      'Flowers',
      'Bar',
      'Bathroom',
      'House',
      'Makeup',
      'Family',
    ];

    Map<String, String> times = {};
    for (String category in categories) {
      times[category] = await getWordPuzzleBestTime(category);
    }
    return times;
  }

  /// loadCoinsFromLocal

  Future<String> loadCoinsFromLocal() async {
    final data = await _dataBase.get(DataBaseKey.loadCoinsFromLocal.name);
    return data is String ? data : '';
  }

  /// set loadCoinsFromLocal
  Future<void> setLoadCoinsFromLocal(String value) async {
    await _dataBase.save(DataBaseKey.loadCoinsFromLocal.name, value);
  }

  /// save number of questions and difficulty
  Future<void> saveNumberOfQuestionsAndDifficulty() {
    return _dataBase.save(
      DataBaseKey.numberOfQuestions.name,
      jsonEncode(Shared.instance.numberOfQuestions.toMap()),
    );
  }

  /// get number of questions and difficulty
  Future<OptionQuesionModel> getNumberOfQuestionsAndDifficulty() async {
    final data = await _dataBase.get(DataBaseKey.numberOfQuestions.name);
    if (data is String && data.isNotEmpty) {
      final Map<String, dynamic> map = jsonDecode(data);
      return OptionQuesionModel.fromMap(map);
    } else {
      return OptionQuesionModel(
        option: Difficulty.easy.name,
        numberOfQuestions: 20,
      );
    }
  }

  Future<void> saveCheckInToday() async {
    final now = DateTime.now();
    final checkInDates = await getCheckInDates();
    checkInDates.add(DateTime(now.year, now.month, now.day));
    await _dataBase.save(
      DataBaseKey.checkInDates.name,
      jsonEncode(checkInDates.map((e) => e.toIso8601String()).toList()),
    );
  }

  /// Lấy danh sách ngày trong ngày điểm danh
  /// Trả về danh sách các ngày đã điểm danh trong tuần hiện tại
  Future<List<DateTime>> getCheckInDates() async {
    final data = await _dataBase.get(DataBaseKey.checkInDates.name);
    if (data != null && data.isNotEmpty) {
      return List<DateTime>.from(
        jsonDecode(data).map((e) => DateTime.parse(e)),
      );
    }
    return [];
  }

  Future<void> saveLastCheckInDate(DateTime date) async {
    final checkInDates = await getCheckInDates();
    if (!checkInDates.any(
      (element) =>
          element.year == date.year &&
          element.month == date.month &&
          element.day == date.day,
    )) {
      checkInDates.add(date);
      await _dataBase.save(
        DataBaseKey.checkInDates.name,
        jsonEncode(checkInDates.map((e) => e.toIso8601String()).toList()),
      );
    }
  }

  Future<DateTime> getlastCheckInDate() async {
    final checkInDates = await getCheckInDates();
    if (checkInDates.isNotEmpty) {
      checkInDates.sort((a, b) => b.compareTo(a));
      return checkInDates.first;
    }
    return DateTime(2000);
  }

  /// Xóa danh sách ngày điểm danh
  Future<void> clearCheckInDates() async {
    await _dataBase.delete(DataBaseKey.checkInDates.name);
  }

  ///
  Future<bool> checkInToday() async {
    final checkInDates = await getCheckInDates();
    final now = DateTime.now();
    return checkInDates.isNotEmpty
        ? checkInDates
              .where(
                (date) =>
                    date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day,
              )
              .isEmpty
        : true;
  }

  // ChatAI
  Future<bool> saveChatAi(ChatGroup chatGroup) async {
    final list = await getListChatAi();
    final oldItem = list
        .where((element) => element.idGroup == chatGroup.idGroup)
        .firstOrNull;
    if (oldItem != null) {
      oldItem.listchat.clear();
      oldItem.listchat.addAll(chatGroup.listchat);
      oldItem.isPin = chatGroup.isPin;
      oldItem.isFav = chatGroup.isFav;
      oldItem.isImp = chatGroup.isImp;
      oldItem.label = chatGroup.label;
      oldItem.isArchived = chatGroup.isArchived;
      oldItem.namegroup = chatGroup.namegroup;
      oldItem.updated = DateTime.now();
    } else {
      list.insert(0, chatGroup);
    }
    await _dataBase.save(
      DataBaseKey.historychatai.name,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    return true;
  }

  Future<List<ChatGroup>> getListChatAi() async {
    final data = await _dataBase.get(DataBaseKey.historychatai.name);
    if (data != null && data.isNotEmpty) {
      return List.from(
        jsonDecode(data),
      ).map((e) => ChatGroup.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> deleteChatAi(String idGroup) async {
    final list = await getListChatAi();
    if (list.isNotEmpty) {
      final itemRemove = list
          .where((element) => element.idGroup == idGroup)
          .firstOrNull;
      if (itemRemove != null) {
        list.remove(itemRemove);
        await _dataBase.save(
          DataBaseKey.historychatai.name,
          jsonEncode(list.map((e) => e.toJson()).toList()),
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> saveListChatAi(List<ChatGroup> list) async {
    await _dataBase.save(
      DataBaseKey.historychatai.name,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    return true;
  }

  // gem 2048 high score
  Future<void> saveGem2048HighScore({
    required Map<String, dynamic> value,
  }) async {
    await _dataBase.save(DataBaseKey.gem2048HighScore.name, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getGem2048HighScore() async {
    final data = await _dataBase.get(DataBaseKey.gem2048HighScore.name);
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<bool> onBorading() async {
    final data = await _dataBase.get(DataBaseKey.onBoarding.name);
    return data is String ? data == 'true' : false;
  }

  Future<void> setOnBorading(bool value) async {
    await _dataBase.save(DataBaseKey.onBoarding.name, value.toString());
  }
}
