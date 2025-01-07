import 'package:get/get.dart';
import 'package:flutter_tour_app/localization/bangla.dart';
import 'package:flutter_tour_app/localization/english.dart';

class AppLanguages extends Translations{

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': english,
    'bn_BD': bangla,
  };

}