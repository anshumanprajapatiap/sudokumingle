import 'package:shared_preferences/shared_preferences.dart';

class SoundPreference {
  static const SOUND_STATUS = "SOUNDSTATUSSUKOKUMINGLE";
  bool? _savedSound;
  setSound(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('SOUND_SAVED ${value}');
    prefs.setBool(SOUND_STATUS, value);
  }
  getSavedSoundData() async{
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    print('SOUND_STATUS IS: ');
    print(prefs.getBool(SOUND_STATUS));
    if(prefs.getBool(SOUND_STATUS)==null){
      _savedSound = false;
      return;
    }
    prefs.getBool(SOUND_STATUS)! ? _savedSound = true : _savedSound = false;
  }

  bool? getSound()  {
    getSavedSoundData();
    return _savedSound;
  }
}