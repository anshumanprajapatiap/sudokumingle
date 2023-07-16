
enum Difficulty {
  none, // error handled
  easy, // 45-50-55 [Filled]
  medium, // 39-40-45 [Filled]
  hard, // 28-30-35 [Filled]
  master, // 17-20-25 [Filled]
  grandmaster, // 6-10-15 [Filled]
  donnottry // 3-5 [Filled]
}

extension DifficultyEnumToString on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.none:
        return 'None';
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.master:
        return 'Master';
      case Difficulty.grandmaster:
        return 'Grandmaster';
      case Difficulty.donnottry:
        return 'Do Not Try';
    }
  }
}

Difficulty stringToDifficulty(String value) {
  switch (value) {
    case 'None':
      return Difficulty.none;
    case 'Easy':
      return Difficulty.easy;
    case 'Medium':
      return Difficulty.medium;
    case 'Hard':
      return Difficulty.hard;
    case 'Master':
      return Difficulty.master;
    case 'Grandmaster':
      return Difficulty.grandmaster;
    case 'Do Not Try':
      return Difficulty.donnottry;
    default:
      throw ArgumentError('Invalid Difficulty value: $value');
  }
}
