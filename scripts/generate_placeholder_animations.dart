/// Script to generate placeholder animation files for demo purposes
/// 
/// This script creates simple Lottie JSON files for all letters (A-Z, 0-9)
/// and common words using the placeholder template.
/// 
/// Run with: dart run scripts/generate_placeholder_animations.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🎬 Generating placeholder animations...\n');

  // Load template
  final templateFile = File('assets/animations/placeholder_animation_template.json');
  if (!await templateFile.exists()) {
    print('❌ Template file not found!');
    return;
  }

  final template = jsonDecode(await templateFile.readAsString());

  // Generate letter animations
  await generateLetterAnimations(template);

  // Generate word animations
  await generateWordAnimations(template);

  print('\n✅ All placeholder animations generated!');
  print('📝 Note: These are simple placeholders for demo purposes.');
  print('   Replace with professional animations for production.');
}

Future<void> generateLetterAnimations(Map<String, dynamic> template) async {
  print('📝 Generating letter animations (A-Z, 0-9)...');

  final lettersDir = Directory('assets/animations/letters');
  await lettersDir.create(recursive: true);

  // Generate A-Z
  for (int i = 0; i < 26; i++) {
    final letter = String.fromCharCode(65 + i); // A-Z
    await generateAnimation(template, letter, lettersDir);
  }

  // Generate 0-9
  for (int i = 0; i <= 9; i++) {
    await generateAnimation(template, i.toString(), lettersDir);
  }

  print('   ✓ Generated 36 letter animations');
}

Future<void> generateWordAnimations(Map<String, dynamic> template) async {
  print('📝 Generating word animations...');

  final words = {
    'common': [
      'hello', 'thank', 'please', 'sorry', 'yes', 'no', 'help', 'stop',
      'go', 'come', 'wait', 'understand', 'good', 'bad', 'happy', 'sad',
      'love', 'like', 'want', 'need'
    ],
    'questions': [
      'what', 'where', 'when', 'why', 'how', 'who', 'which', 'can', 'will', 'do'
    ],
    'family': [
      'mother', 'father', 'sister', 'brother', 'family', 'friend',
      'baby', 'child', 'man', 'woman'
    ],
    'emergency': [
      'emergency', 'danger', 'safe', 'police', 'ambulance', 'fire',
      'hospital', 'doctor', 'medicine', 'pain'
    ],
  };

  int totalWords = 0;
  for (final category in words.entries) {
    final categoryDir = Directory('assets/animations/words/${category.key}');
    await categoryDir.create(recursive: true);

    for (final word in category.value) {
      await generateAnimation(template, word, categoryDir);
      totalWords++;
    }
  }

  print('   ✓ Generated $totalWords word animations');
}

Future<void> generateAnimation(
  Map<String, dynamic> template,
  String label,
  Directory directory,
) async {
  // Clone template
  final animation = Map<String, dynamic>.from(template);

  // Update name
  animation['nm'] = 'ASL_$label';

  // Update text layer to show the letter/word
  if (animation['layers'] != null && animation['layers'].length > 1) {
    final textLayer = animation['layers'][1];
    if (textLayer['t'] != null && textLayer['t']['d'] != null) {
      textLayer['t']['d']['k'][0]['s']['t'] = label.toUpperCase();
    }
  }

  // Write file
  final file = File('${directory.path}/$label.json');
  await file.writeAsString(
    JsonEncoder.withIndent('  ').convert(animation),
  );
}