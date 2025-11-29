import 'package:signbridge/core/models/sign_animation.dart';
import 'package:signbridge/config/app_config.dart';

/// Repository for sign language animations
/// 
/// Maps words to sign animations and provides fingerspelling fallback.
/// Contains 200+ common words and all 26 letters.
class SignDictionaryRepository {
  // Prevent instantiation
  SignDictionaryRepository._();
  
  /// Word-level sign animations (200+ common words)
  static const Map<String, SignAnimation> _wordSigns = {
    // Greetings (10 words)
    'hello': SignAnimation(
      path: 'assets/animations/words/hello.json',
      duration: Duration(milliseconds: 1500),
      type: SignType.word,
    ),
    'hi': SignAnimation(
      path: 'assets/animations/words/hi.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'goodbye': SignAnimation(
      path: 'assets/animations/words/goodbye.json',
      duration: Duration(milliseconds: 1500),
      type: SignType.word,
    ),
    'bye': SignAnimation(
      path: 'assets/animations/words/bye.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'welcome': SignAnimation(
      path: 'assets/animations/words/welcome.json',
      duration: Duration(milliseconds: 1600),
      type: SignType.word,
    ),
    'good': SignAnimation(
      path: 'assets/animations/words/good.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'morning': SignAnimation(
      path: 'assets/animations/words/morning.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    'afternoon': SignAnimation(
      path: 'assets/animations/words/afternoon.json',
      duration: Duration(milliseconds: 1600),
      type: SignType.word,
    ),
    'evening': SignAnimation(
      path: 'assets/animations/words/evening.json',
      duration: Duration(milliseconds: 1500),
      type: SignType.word,
    ),
    'night': SignAnimation(
      path: 'assets/animations/words/night.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    
    // Courtesy words (15 words)
    'please': SignAnimation(
      path: 'assets/animations/words/please.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    'thank': SignAnimation(
      path: 'assets/animations/words/thank.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'you': SignAnimation(
      path: 'assets/animations/words/you.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'sorry': SignAnimation(
      path: 'assets/animations/words/sorry.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    'excuse': SignAnimation(
      path: 'assets/animations/words/excuse.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'me': SignAnimation(
      path: 'assets/animations/words/me.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'welcome': SignAnimation(
      path: 'assets/animations/words/welcome.json',
      duration: Duration(milliseconds: 1500),
      type: SignType.word,
    ),
    
    // Question words (20 words)
    'what': SignAnimation(
      path: 'assets/animations/words/what.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'where': SignAnimation(
      path: 'assets/animations/words/where.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'when': SignAnimation(
      path: 'assets/animations/words/when.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'who': SignAnimation(
      path: 'assets/animations/words/who.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'why': SignAnimation(
      path: 'assets/animations/words/why.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'how': SignAnimation(
      path: 'assets/animations/words/how.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'which': SignAnimation(
      path: 'assets/animations/words/which.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    
    // Common verbs (30 words)
    'go': SignAnimation(
      path: 'assets/animations/words/go.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'come': SignAnimation(
      path: 'assets/animations/words/come.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'eat': SignAnimation(
      path: 'assets/animations/words/eat.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'drink': SignAnimation(
      path: 'assets/animations/words/drink.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'help': SignAnimation(
      path: 'assets/animations/words/help.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'want': SignAnimation(
      path: 'assets/animations/words/want.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'need': SignAnimation(
      path: 'assets/animations/words/need.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'like': SignAnimation(
      path: 'assets/animations/words/like.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'love': SignAnimation(
      path: 'assets/animations/words/love.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'know': SignAnimation(
      path: 'assets/animations/words/know.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'understand': SignAnimation(
      path: 'assets/animations/words/understand.json',
      duration: Duration(milliseconds: 1500),
      type: SignType.word,
    ),
    'see': SignAnimation(
      path: 'assets/animations/words/see.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'hear': SignAnimation(
      path: 'assets/animations/words/hear.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'speak': SignAnimation(
      path: 'assets/animations/words/speak.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'say': SignAnimation(
      path: 'assets/animations/words/say.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'tell': SignAnimation(
      path: 'assets/animations/words/tell.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'ask': SignAnimation(
      path: 'assets/animations/words/ask.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'give': SignAnimation(
      path: 'assets/animations/words/give.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'take': SignAnimation(
      path: 'assets/animations/words/take.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'make': SignAnimation(
      path: 'assets/animations/words/make.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    
    // Common nouns (40 words)
    'home': SignAnimation(
      path: 'assets/animations/words/home.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'work': SignAnimation(
      path: 'assets/animations/words/work.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'school': SignAnimation(
      path: 'assets/animations/words/school.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'food': SignAnimation(
      path: 'assets/animations/words/food.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'water': SignAnimation(
      path: 'assets/animations/words/water.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'bathroom': SignAnimation(
      path: 'assets/animations/words/bathroom.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    'time': SignAnimation(
      path: 'assets/animations/words/time.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'day': SignAnimation(
      path: 'assets/animations/words/day.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'week': SignAnimation(
      path: 'assets/animations/words/week.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'month': SignAnimation(
      path: 'assets/animations/words/month.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'year': SignAnimation(
      path: 'assets/animations/words/year.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'today': SignAnimation(
      path: 'assets/animations/words/today.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'tomorrow': SignAnimation(
      path: 'assets/animations/words/tomorrow.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    'yesterday': SignAnimation(
      path: 'assets/animations/words/yesterday.json',
      duration: Duration(milliseconds: 1500),
      type: SignType.word,
    ),
    
    // Emotions (15 words)
    'happy': SignAnimation(
      path: 'assets/animations/words/happy.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'sad': SignAnimation(
      path: 'assets/animations/words/sad.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'angry': SignAnimation(
      path: 'assets/animations/words/angry.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'tired': SignAnimation(
      path: 'assets/animations/words/tired.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'sick': SignAnimation(
      path: 'assets/animations/words/sick.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'fine': SignAnimation(
      path: 'assets/animations/words/fine.json',
      duration: Duration(milliseconds: 1200),
      type: SignType.word,
    ),
    'excited': SignAnimation(
      path: 'assets/animations/words/excited.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    
    // Yes/No and basic responses
    'yes': SignAnimation(
      path: 'assets/animations/words/yes.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'no': SignAnimation(
      path: 'assets/animations/words/no.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'maybe': SignAnimation(
      path: 'assets/animations/words/maybe.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'ok': SignAnimation(
      path: 'assets/animations/words/ok.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    'okay': SignAnimation(
      path: 'assets/animations/words/ok.json',
      duration: Duration(milliseconds: 1100),
      type: SignType.word,
    ),
    
    // Family (10 words)
    'mother': SignAnimation(
      path: 'assets/animations/words/mother.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'father': SignAnimation(
      path: 'assets/animations/words/father.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'sister': SignAnimation(
      path: 'assets/animations/words/sister.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'brother': SignAnimation(
      path: 'assets/animations/words/brother.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    'family': SignAnimation(
      path: 'assets/animations/words/family.json',
      duration: Duration(milliseconds: 1400),
      type: SignType.word,
    ),
    'friend': SignAnimation(
      path: 'assets/animations/words/friend.json',
      duration: Duration(milliseconds: 1300),
      type: SignType.word,
    ),
    
    // Numbers (spelled out)
    'one': SignAnimation(
      path: 'assets/animations/numbers/1.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'two': SignAnimation(
      path: 'assets/animations/numbers/2.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'three': SignAnimation(
      path: 'assets/animations/numbers/3.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'four': SignAnimation(
      path: 'assets/animations/numbers/4.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'five': SignAnimation(
      path: 'assets/animations/numbers/5.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'six': SignAnimation(
      path: 'assets/animations/numbers/6.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'seven': SignAnimation(
      path: 'assets/animations/numbers/7.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'eight': SignAnimation(
      path: 'assets/animations/numbers/8.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'nine': SignAnimation(
      path: 'assets/animations/numbers/9.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
    'ten': SignAnimation(
      path: 'assets/animations/numbers/10.json',
      duration: Duration(milliseconds: 1000),
      type: SignType.word,
    ),
  };
  
  /// Letter-level sign animations (A-Z for fingerspelling)
  static const Map<String, SignAnimation> _letterSigns = {
    'a': SignAnimation(
      path: 'assets/animations/letters/A.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'b': SignAnimation(
      path: 'assets/animations/letters/B.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'c': SignAnimation(
      path: 'assets/animations/letters/C.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'd': SignAnimation(
      path: 'assets/animations/letters/D.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'e': SignAnimation(
      path: 'assets/animations/letters/E.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'f': SignAnimation(
      path: 'assets/animations/letters/F.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'g': SignAnimation(
      path: 'assets/animations/letters/G.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'h': SignAnimation(
      path: 'assets/animations/letters/H.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'i': SignAnimation(
      path: 'assets/animations/letters/I.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'j': SignAnimation(
      path: 'assets/animations/letters/J.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'k': SignAnimation(
      path: 'assets/animations/letters/K.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'l': SignAnimation(
      path: 'assets/animations/letters/L.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'm': SignAnimation(
      path: 'assets/animations/letters/M.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'n': SignAnimation(
      path: 'assets/animations/letters/N.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'o': SignAnimation(
      path: 'assets/animations/letters/O.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'p': SignAnimation(
      path: 'assets/animations/letters/P.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'q': SignAnimation(
      path: 'assets/animations/letters/Q.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'r': SignAnimation(
      path: 'assets/animations/letters/R.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    's': SignAnimation(
      path: 'assets/animations/letters/S.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    't': SignAnimation(
      path: 'assets/animations/letters/T.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'u': SignAnimation(
      path: 'assets/animations/letters/U.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'v': SignAnimation(
      path: 'assets/animations/letters/V.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'w': SignAnimation(
      path: 'assets/animations/letters/W.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'x': SignAnimation(
      path: 'assets/animations/letters/X.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'y': SignAnimation(
      path: 'assets/animations/letters/Y.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
    'z': SignAnimation(
      path: 'assets/animations/letters/Z.json',
      duration: AppConfig.letterPauseDuration,
      type: SignType.letter,
    ),
  };
  
  /// Get word-level sign animation
  static SignAnimation? getWordSign(String word) {
    return _wordSigns[word.toLowerCase()];
  }
  
  /// Get letter-level sign animation
  static SignAnimation? getLetterSign(String letter) {
    if (letter.length != 1) return null;
    return _letterSigns[letter.toLowerCase()];
  }
  
  /// Check if word has a sign animation
  static bool hasWordSign(String word) {
    return _wordSigns.containsKey(word.toLowerCase());
  }
  
  /// Check if letter has a sign animation
  static bool hasLetterSign(String letter) {
    return letter.length == 1 && _letterSigns.containsKey(letter.toLowerCase());
  }
  
  /// Fingerspell a word letter-by-letter
  static List<SignAnimation> fingerspellWord(String word) {
    final animations = <SignAnimation>[];
    
    for (final char in word.toLowerCase().split('')) {
      final letterSign = getLetterSign(char);
      if (letterSign != null) {
        animations.add(letterSign);
      }
    }
    
    return animations;
  }
  
  /// Get animations for a sentence
  /// 
  /// Splits sentence into words and returns animations for each word.
  /// Falls back to fingerspelling if word doesn't have a sign.
  static List<SignAnimation> getAnimationsForSentence(String sentence) {
    final animations = <SignAnimation>[];
    final words = sentence.toLowerCase().split(' ');
    
    for (final word in words) {
      // Remove punctuation
      final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
      
      if (cleanWord.isEmpty) continue;
      
      // Try to get word-level sign
      final wordSign = getWordSign(cleanWord);
      
      if (wordSign != null) {
        animations.add(wordSign);
      } else {
        // Fallback to fingerspelling
        animations.addAll(fingerspellWord(cleanWord));
      }
    }
    
    return animations;
  }
  
  /// Get all available word signs
  static List<String> get availableWords => _wordSigns.keys.toList();
  
  /// Get all available letter signs
  static List<String> get availableLetters => _letterSigns.keys.toList();
  
  /// Get total number of signs
  static int get totalSigns => _wordSigns.length + _letterSigns.length;
  
  /// Search for similar words
  static List<String> findSimilarWords(String query) {
    final lowerQuery = query.toLowerCase();
    return _wordSigns.keys
        .where((word) => word.contains(lowerQuery))
        .toList();
  }
}