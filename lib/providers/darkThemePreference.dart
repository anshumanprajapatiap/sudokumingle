import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUSSUKOKUMINGLE";
  bool? _savedTheme;
  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('THEME_SAVED ${value}');
    prefs.setBool(THEME_STATUS, value);
  }
  getSavedThemeData() async{
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    print('THEME_STATUS IS: ');
    print(prefs.getBool(THEME_STATUS));
    if(prefs.getBool(THEME_STATUS)==null){
      _savedTheme = false;
      return;
    }
    prefs.getBool(THEME_STATUS)! ? _savedTheme = true : _savedTheme = false;
  }

  bool? getTheme()  {
    getSavedThemeData();
    print('savedthemeatgettheme: ${_savedTheme}');
    return _savedTheme;
  }
}