# 🎮 SignBridge - Super Simple Start Guide
## For Complete Beginners (No Coding Experience Needed!)

---

## 🎯 What You're Going to Do

You're going to run a sign language translation app on your computer or phone. It's like playing a video game - just follow the steps!

---

## 📋 Before You Start - Check These Things

### ✅ Do you have a Windows computer?
- If YES → Great! Continue below
- If NO (Mac/Linux) → The steps are similar, just slightly different

### ✅ Do you have an Android phone or tablet?
- If YES → Perfect! You'll test the app on it
- If NO → That's okay, we can use a virtual phone on your computer

---

## 🚀 Part 1: Install Flutter (The App Builder)

### Step 1: Download Flutter

1. **Open your web browser** (Chrome, Edge, Firefox - any browser)

2. **Go to this website:**
   ```
   https://docs.flutter.dev/get-started/install/windows
   ```

3. **Click the big blue "Download" button**
   - It will download a file called something like `flutter_windows_3.x.x.zip`
   - Wait for it to finish (it's big, about 1GB)

4. **Find the downloaded file**
   - Usually in your "Downloads" folder
   - Right-click on it
   - Choose "Extract All"
   - Extract it to `C:\` (your C drive)
   - You should now have a folder at `C:\flutter`

### Step 2: Tell Windows Where Flutter Is

1. **Press the Windows key** (the key with the Windows logo)

2. **Type:** `environment variables`

3. **Click on:** "Edit the system environment variables"

4. **Click the button** that says "Environment Variables" at the bottom

5. **In the top box** (User variables), find the one called "Path"
   - Click on "Path"
   - Click "Edit"
   - Click "New"
   - Type: `C:\flutter\bin`
   - Click "OK" on all windows

6. **Close everything and restart your computer**
   - This is important! Flutter won't work until you restart

### Step 3: Check if Flutter Works

1. **Press Windows key + R**

2. **Type:** `cmd` and press Enter
   - A black window will open (this is called "Command Prompt")

3. **Type this and press Enter:**
   ```
   flutter doctor
   ```

4. **Wait for it to finish**
   - It will show you a list with checkmarks ✓ and X marks
   - Don't worry if some things have X marks
   - As long as you see "Flutter" with a checkmark, you're good!

---

## 🚀 Part 2: Get Your Project Ready

### Step 4: Open the Project Folder

1. **Press Windows key + E**
   - This opens File Explorer

2. **Navigate to:**
   ```
   C:\Users\first\OneDrive\Desktop\Hackathon\Mobile AI Hackathon
   ```
   - Click on "This PC"
   - Double-click "Local Disk (C:)"
   - Double-click "Users"
   - Double-click "first"
   - Double-click "OneDrive"
   - Double-click "Desktop"
   - Double-click "Hackathon"
   - Double-click "Mobile AI Hackathon"

3. **You should see lots of folders** like:
   - lib
   - assets
   - android
   - test
   - And files like README.md, pubspec.yaml

### Step 5: Open Command Prompt in This Folder

1. **While in the project folder**, click in the address bar at the top
   - It shows the folder path
   - Click on it so it's highlighted

2. **Type:** `cmd` and press Enter
   - A black window opens, but this time it's already in your project folder!

3. **You should see something like:**
   ```
   C:\Users\first\OneDrive\Desktop\Hackathon\Mobile AI Hackathon>
   ```

### Step 6: Download App Dependencies

1. **In the black window (Command Prompt), type:**
   ```
   flutter pub get
   ```

2. **Press Enter**

3. **Wait for it to finish**
   - You'll see lots of text scrolling
   - When it stops and you see the `>` again, it's done
   - This downloads all the pieces the app needs

---

## 🚀 Part 3: Run the App

### Step 7: Connect Your Android Phone (Option A)

**If you have an Android phone:**

1. **On your phone:**
   - Go to Settings
   - Find "About Phone"
   - Tap "Build Number" 7 times (yes, really!)
   - It will say "You are now a developer!"

2. **Go back to Settings:**
   - Find "Developer Options" (it's new!)
   - Turn on "USB Debugging"

3. **Connect your phone to computer with USB cable**

4. **On your phone:**
   - A message will pop up asking "Allow USB debugging?"
   - Tap "OK" or "Allow"

5. **In Command Prompt, type:**
   ```
   flutter devices
   ```
   - You should see your phone listed!

### Step 7: Use Virtual Phone (Option B)

**If you don't have an Android phone:**

1. **Download Android Studio:**
   - Go to: https://developer.android.com/studio
   - Click "Download Android Studio"
   - Install it (just keep clicking "Next")

2. **Open Android Studio**

3. **Click "More Actions" → "Virtual Device Manager"**

4. **Click "Create Device"**
   - Choose "Pixel 6"
   - Click "Next"
   - Choose "Tiramisu" (API 33)
   - Click "Next"
   - Click "Finish"

5. **Click the Play button** (▶) next to your virtual device
   - Wait for the virtual phone to start (takes 1-2 minutes)

6. **In Command Prompt, type:**
   ```
   flutter devices
   ```
   - You should see "emulator" listed!

### Step 8: Run the App!

1. **In Command Prompt, type:**
   ```
   flutter run
   ```

2. **Press Enter**

3. **Wait (this takes 2-5 minutes the first time)**
   - You'll see LOTS of text
   - Don't close the window!
   - Just wait...

4. **The app will appear on your phone/emulator!**
   - You did it! 🎉

---

## 🎮 Part 4: Using the App

### What You'll See:

1. **Home Screen**
   - Two big buttons:
     - "Sign to Speech" - Use camera to recognize sign language
     - "Speech to Sign" - Speak and see sign language

2. **Try Sign to Speech:**
   - Tap "Sign to Speech"
   - You'll see camera view
   - Tap the play button (▶)
   - Make hand gestures in front of camera
   - (Note: It's using fake AI right now, so it won't recognize real signs yet)

3. **Try Speech to Sign:**
   - Tap "Speech to Sign"
   - Tap the microphone button
   - Say something like "Hello"
   - You'll see a simple animation

### Why It's Not Perfect Yet:

The app is using "pretend AI" (called a mock) because:
- The real AI (Cactus SDK) needs to be installed separately
- You need to contact the hackathon organizers to get it
- But the app works and shows you everything!

---

## 🆘 If Something Goes Wrong

### "flutter is not recognized"
- **Problem:** Windows doesn't know where Flutter is
- **Fix:** Go back to Step 2 and make sure you:
  - Added `C:\flutter\bin` to Path
  - Restarted your computer

### "No devices found"
- **Problem:** No phone connected or emulator running
- **Fix:** 
  - Make sure USB debugging is on (phone)
  - Or start the emulator (virtual phone)
  - Run `flutter devices` to check

### "Build failed"
- **Problem:** Something went wrong during build
- **Fix:**
  - Close Command Prompt
  - Open it again in the project folder
  - Run `flutter clean`
  - Then run `flutter pub get`
  - Then try `flutter run` again

### "App crashes immediately"
- **Problem:** Missing dependencies
- **Fix:**
  - Run `flutter pub get` again
  - Make sure you're in the right folder

---

## 📞 Need More Help?

### Ask Someone:
- Show them this guide
- Show them the error message
- They can help you figure it out!

### Check These:
1. Are you in the right folder?
   - Should be: `C:\Users\first\OneDrive\Desktop\Hackathon\Mobile AI Hackathon`

2. Did Flutter install correctly?
   - Run: `flutter doctor`
   - Should see checkmarks

3. Is your phone/emulator connected?
   - Run: `flutter devices`
   - Should see a device listed

---

## 🎉 You Did It!

If you got the app running, you've successfully:
- ✅ Installed Flutter
- ✅ Set up your development environment
- ✅ Run a real mobile app
- ✅ Tested it on a device

**That's amazing for someone with no coding experience!** 🌟

---

## 🚀 What's Next?

### To Get the Real AI Working:

1. **Contact the hackathon organizers**
   - Email them: "I need the Cactus SDK for my project"
   - They'll send you a file or link

2. **When you get it:**
   - Open the file called `CACTUS_SDK_INTEGRATION_GUIDE.md`
   - It has step-by-step instructions
   - Or ask someone to help you with that part

### To Make It Better:

1. **Add real sign language animations**
   - The guide `ANIMATION_ASSETS_GUIDE.md` explains how
   - This is the hard part (needs animation skills)

2. **Test with real people**
   - Show it to friends
   - Get feedback
   - Make improvements

---

## 📚 What You Learned

Even though you're not a coder, you just:
- Used the command line (that black window)
- Installed development tools
- Ran commands
- Built and deployed an app
- Debugged problems

**These are real developer skills!** 🎓

---

**Remember:** The app works right now with "pretend AI". To get real sign language recognition, you need the Cactus SDK from the hackathon organizers. But you can show off the app and all its features already!

**Good luck!** 🍀