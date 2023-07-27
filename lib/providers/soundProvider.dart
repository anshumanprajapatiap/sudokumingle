

import 'package:flutter/cupertino.dart';
import 'package:sudokumingle/sharedPreference/soundPreference.dart';

class SoundProvider with ChangeNotifier {
  SoundPreference soundPreference = SoundPreference();
  bool _isSoundOn = false;

  bool get isSoundOn => _isSoundOn;

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    print('somodeund: -${_isSoundOn}');
    soundPreference.setSound(_isSoundOn);
    notifyListeners();
  }

  bool getSound() {
    if (soundPreference.getSound() != null) {
      _isSoundOn = soundPreference.getSound()!;
    }
    print('getting sound');
    return _isSoundOn;
  }

}