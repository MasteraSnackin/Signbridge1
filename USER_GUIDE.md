# SignBridge User Guide

Complete guide for using the SignBridge sign language translation application.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Sign-to-Speech Mode](#sign-to-speech-mode)
3. [Speech-to-Sign Mode](#speech-to-sign-mode)
4. [Settings](#settings)
5. [Tips & Best Practices](#tips--best-practices)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)

---

## Getting Started

### First Launch

When you first open SignBridge:

1. **Grant Permissions**
   - The app will ask for camera access
   - Tap "Allow" to enable sign recognition
   - The app will ask for microphone access
   - Tap "Allow" to enable speech input

2. **Model Download** (First time only)
   - AI models will download automatically
   - This takes 2-5 minutes depending on your connection
   - You only need to do this once
   - Models are stored on your device for offline use

3. **Home Screen**
   - You'll see two main options:
     - **Sign to Speech**: Recognize sign language and speak it
     - **Speech to Sign**: Speak and see sign language

### Navigation

- **Home Button**: Returns to main menu
- **Settings Icon**: Access app settings
- **Back Button**: Returns to previous screen

---

## Sign-to-Speech Mode

Convert sign language gestures into spoken words.

### How to Use

#### Step 1: Start Recognition

1. Tap **"Sign to Speech"** on the home screen
2. Position yourself in front of the camera
3. Tap the **Play button** (▶) to start

#### Step 2: Sign Letters

1. Make ASL hand gestures in front of the camera
2. Hold each sign steady for 1-2 seconds
3. Watch the recognized letter appear on screen
4. The confidence indicator shows recognition accuracy

#### Step 3: Build Words

1. Sign letters one by one
2. Letters appear in the text box as recognized
3. When you complete a word, the app speaks it
4. Tap **Clear** to start a new word

### Camera Tips

**Lighting:**
- Use good lighting (natural light is best)
- Avoid backlighting (don't stand in front of windows)
- Ensure your hands are well-lit

**Position:**
- Keep hands in camera view
- Distance: 1-2 feet from camera
- Center your hands in the frame
- Keep background simple and uncluttered

**Hand Gestures:**
- Make clear, distinct signs
- Hold each sign steady
- Avoid rapid movements
- Face your palm toward the camera

### Understanding the Interface

**Camera View:**
- Shows live camera feed
- Green box indicates hand detected
- Red box indicates no hand detected

**Text Display:**
- Shows recognized letters/words
- Updates in real-time
- Large, easy-to-read font

**Confidence Indicator:**
- **Green bar**: High confidence (75-100%)
- **Orange bar**: Medium confidence (50-75%)
- **Red bar**: Low confidence (0-50%)
- Percentage shows exact confidence

**Control Buttons:**
- **Play (▶)**: Start recognition
- **Stop (■)**: Stop recognition
- **Clear (✕)**: Clear recognized text

### Supported Signs

**Letters:** A-Z (26 letters)
**Numbers:** 0-9 (10 digits)
**Total:** 36 basic signs

---

## Speech-to-Sign Mode

Convert spoken words into sign language animations.

### How to Use

#### Step 1: Start Listening

1. Tap **"Speech to Sign"** on the home screen
2. Tap the **Microphone button**
3. The button turns red when listening

#### Step 2: Speak

1. Speak clearly into your device
2. Use normal speaking pace
3. Pause briefly between words
4. Watch your words appear as text

#### Step 3: Watch Signs

1. Sign animations play automatically
2. One word at a time
3. Animations repeat if needed
4. Tap to replay

### Speaking Tips

**Voice:**
- Speak clearly and naturally
- Use normal volume
- Avoid shouting or whispering
- Minimize background noise

**Pacing:**
- Speak at normal speed
- Pause briefly between words
- Don't rush
- Enunciate clearly

**Environment:**
- Find a quiet location
- Reduce background noise
- Close windows if outside is noisy
- Turn off TV/music

### Understanding the Interface

**Transcription Box:**
- Shows your spoken words
- Updates in real-time
- Highlighted word is currently being signed

**Animation Display:**
- Shows sign language avatar
- Smooth, clear animations
- Loops for clarity

**Microphone Button:**
- **Blue**: Ready to listen
- **Red**: Currently listening
- **Gray**: Processing

**Playback Controls:**
- **Replay**: Watch animation again
- **Speed**: Adjust animation speed
- **Next**: Skip to next word

### Supported Words

**Common Words:** 200+ everyday words
- Greetings: hello, goodbye, thank you
- Questions: what, where, when, why, how
- Family: mother, father, sister, brother
- Emergency: help, danger, police, hospital

**Fallback:**
- Unknown words are fingerspelled letter-by-letter
- All letters A-Z supported

---

## Settings

Access settings by tapping the gear icon (⚙️).

### Model Management

**Download Models:**
- Manually download AI models
- Check download progress
- Verify model integrity

**Update Models:**
- Check for model updates
- Download newer versions
- Manage storage space

**Model Info:**
- View model sizes
- Check versions
- See download status

### Recognition Settings

**Confidence Threshold:**
- Adjust minimum confidence (default: 75%)
- Lower = more permissive (may have errors)
- Higher = more strict (may miss signs)

**Frame Rate:**
- Adjust processing speed (default: 10 FPS)
- Lower = better battery life
- Higher = faster recognition

**Temporal Buffer:**
- Adjust stability filter (default: 5 frames)
- Higher = more stable but slower
- Lower = faster but less stable

### Animation Settings

**Playback Speed:**
- Slow (0.5x): Easier to learn
- Normal (1.0x): Natural pace
- Fast (1.5x): Quick review

**Auto-Replay:**
- Enable/disable automatic replay
- Set replay count
- Adjust pause between replays

**Animation Style:**
- Choose avatar style
- Adjust animation quality
- Enable/disable effects

### Hybrid Mode (Advanced)

**Enable Cloud Processing:**
- Use cloud for low-confidence signs
- Improves accuracy
- Requires internet connection

**Privacy Settings:**
- View processing statistics
- See local vs cloud usage
- Clear usage data

**Fallback Behavior:**
- Always use local first
- Cloud only for low confidence
- Automatic fallback if cloud fails

### Privacy & Data

**Data Collection:**
- No personal data collected
- All processing on-device by default
- Cloud processing optional

**Usage Statistics:**
- View recognition accuracy
- See processing times
- Check model performance

**Clear Data:**
- Clear recognition history
- Reset settings
- Delete cached data

### About

- App version
- Model versions
- Credits and licenses
- Contact support

---

## Tips & Best Practices

### For Best Recognition

**Lighting:**
✅ Use bright, even lighting
✅ Natural daylight is ideal
❌ Avoid shadows on hands
❌ Don't use backlighting

**Camera Position:**
✅ Keep hands centered
✅ Maintain 1-2 feet distance
✅ Keep hands in frame
❌ Don't move too fast

**Hand Gestures:**
✅ Make clear, distinct signs
✅ Hold each sign steady
✅ Face palm toward camera
❌ Don't overlap fingers

### For Best Speech Recognition

**Speaking:**
✅ Speak clearly and naturally
✅ Use normal volume
✅ Pause between words
❌ Don't shout or whisper

**Environment:**
✅ Find quiet location
✅ Minimize background noise
✅ Close to microphone
❌ Avoid echo-y rooms

### Battery Saving

**Reduce Power Usage:**
- Lower frame rate (5 FPS)
- Reduce screen brightness
- Close other apps
- Use power saving mode

**Optimize Performance:**
- Keep app updated
- Clear cache regularly
- Restart app if slow
- Ensure good signal (for hybrid mode)

### Learning ASL

**Practice:**
- Start with alphabet
- Learn common words
- Practice daily
- Use mirror to check form

**Resources:**
- ASL dictionaries online
- Video tutorials
- Local ASL classes
- Deaf community events

---

## Troubleshooting

### Recognition Issues

**"No hand detected"**
- Ensure hands are in camera view
- Check lighting
- Move closer to camera
- Clean camera lens

**"Low confidence"**
- Make clearer signs
- Hold sign steady longer
- Improve lighting
- Check hand position

**"Wrong letter recognized"**
- Review ASL alphabet
- Make more distinct signs
- Hold sign longer
- Adjust confidence threshold

### Speech Issues

**"Not hearing me"**
- Check microphone permission
- Speak louder
- Reduce background noise
- Check device volume

**"Wrong words"**
- Speak more clearly
- Slow down
- Reduce background noise
- Check language settings

**"No animation"**
- Check internet (if using cloud)
- Restart app
- Clear cache
- Reinstall app

### Performance Issues

**"App is slow"**
- Close other apps
- Restart device
- Clear app cache
- Check storage space

**"App crashes"**
- Update to latest version
- Restart device
- Reinstall app
- Contact support

**"Battery drains fast"**
- Lower frame rate
- Reduce screen brightness
- Disable hybrid mode
- Close when not in use

### Connection Issues

**"Models won't download"**
- Check internet connection
- Check storage space
- Try WiFi instead of cellular
- Restart app

**"Cloud mode not working"**
- Check internet connection
- Verify hybrid mode enabled
- Check firewall settings
- Try again later

---

## FAQ

### General

**Q: Is SignBridge free?**
A: Yes, SignBridge is completely free to use.

**Q: Does it work offline?**
A: Yes! All AI processing happens on your device. Internet is only needed for initial model download and optional cloud features.

**Q: What sign languages are supported?**
A: Currently supports American Sign Language (ASL). More languages coming soon.

**Q: Can I use it on iPhone?**
A: Currently Android only. iOS version in development.

### Privacy

**Q: Is my data collected?**
A: No. All processing happens on your device. No video or audio is sent to servers unless you enable cloud mode.

**Q: What about cloud mode?**
A: Cloud mode is optional. When enabled, only low-confidence frames are sent to cloud for improved accuracy. You can view usage statistics in settings.

**Q: Can I delete my data?**
A: Yes. Go to Settings → Privacy → Clear Data.

### Technical

**Q: How accurate is recognition?**
A: Typically 85-95% accurate with good lighting and clear signs. Accuracy improves with practice.

**Q: How much storage does it use?**
A: About 1.1GB for all AI models. Additional space for cache and animations.

**Q: Does it drain battery?**
A: Moderate battery usage during active recognition. Adjust frame rate in settings to optimize.

**Q: What Android version is required?**
A: Android 7.0 (API 24) or higher.

### Usage

**Q: How do I learn ASL?**
A: SignBridge helps practice, but we recommend:
- Online ASL courses
- Local ASL classes
- ASL dictionaries
- Practice with Deaf community

**Q: Can it recognize full sentences?**
A: Currently recognizes individual letters and words. Sentence recognition coming in future updates.

**Q: What if a word isn't recognized?**
A: Unknown words are fingerspelled letter-by-letter automatically.

### Support

**Q: How do I report a bug?**
A: Go to Settings → About → Report Issue

**Q: How do I request a feature?**
A: Email us at support@signbridge.app

**Q: Where can I get help?**
A: Check this guide, visit our website, or contact support.

---

## Keyboard Shortcuts (Android)

- **Space**: Start/Stop recognition
- **Enter**: Clear text
- **Volume Up**: Increase confidence threshold
- **Volume Down**: Decrease confidence threshold
- **Back**: Return to previous screen

---

## Accessibility Features

**For Deaf/Hard of Hearing:**
- Visual feedback for all audio
- Vibration alerts
- Text-based notifications

**For Blind/Low Vision:**
- Screen reader support
- High contrast mode
- Large text option
- Voice guidance

**For Motor Impairments:**
- Voice control
- Adjustable button sizes
- Simplified interface option

---

## Getting Help

### In-App Help
- Tap "?" icon for context help
- View tutorials in Settings
- Access this guide from menu

### Online Resources
- Website: www.signbridge.app
- Email: support@signbridge.app
- Community: forum.signbridge.app

### Emergency Support
For urgent issues, contact:
- Email: urgent@signbridge.app
- Response time: 24 hours

---

## Credits

**Development Team:**
- SignBridge Development Team

**AI Models:**
- Cactus SDK (LFM2-VL, Qwen3, Whisper)

**ASL Resources:**
- ASL-LEX Database
- Deaf Community Contributors

**Special Thanks:**
- Beta testers
- ASL consultants
- Accessibility advisors

---

## Version Information

**Current Version:** 1.0.0
**Release Date:** January 15, 2024
**Last Updated:** January 15, 2024

---

**For technical documentation, see:**
- [API Reference](API_REFERENCE.md)
- [Technical Architecture](TECHNICAL_ARCHITECTURE.md)
- [Simple Start Guide](SIMPLE_START_GUIDE.md)

**Need help getting started?**
- See [Simple Start Guide](SIMPLE_START_GUIDE.md) for installation
- See [README](README.md) for quick overview