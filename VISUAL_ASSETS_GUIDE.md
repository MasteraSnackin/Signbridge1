# 🎨 Visual Assets Guide for SignBridge

Guide for creating and managing visual assets for the SignBridge project.

---

## 📋 Table of Contents

1. [Required Assets](#required-assets)
2. [Asset Specifications](#asset-specifications)
3. [Design Guidelines](#design-guidelines)
4. [Asset Creation Tools](#asset-creation-tools)
5. [Implementation Guide](#implementation-guide)

---

## Required Assets

### 🎯 Priority 1: Essential Assets

#### 1. App Icon
- **Purpose**: Android launcher icon
- **Sizes Required**:
  - `mipmap-mdpi`: 48x48px
  - `mipmap-hdpi`: 72x72px
  - `mipmap-xhdpi`: 96x96px
  - `mipmap-xxhdpi`: 144x144px
  - `mipmap-xxxhdpi`: 192x192px
- **Format**: PNG with transparency
- **Location**: `android/app/src/main/res/mipmap-*/ic_launcher.png`

**Design Concept**:
```
┌─────────────────┐
│                 │
│      🤝         │  Two hands forming a bridge
│    ╱   ╲       │  Gradient: Blue to Purple
│   ╱     ╲      │  Modern, accessible design
│  ╱       ╲     │
│                 │
└─────────────────┘
```

#### 2. Feature Graphic (GitHub Banner)
- **Size**: 1280x640px
- **Format**: PNG or JPG
- **Location**: `assets/images/github-banner.png`

**Layout**:
```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  🤝 SignBridge                                    [App Icon]   │
│  Breaking Communication Barriers                               │
│                                                                │
│  📹 Sign → Speech  |  🎤 Speech → Sign  |  🔒 Privacy-First   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

#### 3. Screenshots (App Store & GitHub)
- **Sizes**: 1080x2400px (9:19.5 ratio)
- **Format**: PNG
- **Quantity**: 4-6 screenshots
- **Location**: `assets/images/screenshots/`

**Required Screenshots**:
1. Home screen
2. Sign-to-Speech in action
3. Speech-to-Sign with animation
4. Settings screen
5. Privacy dashboard
6. Tutorial/onboarding

### 🎯 Priority 2: Marketing Assets

#### 4. Demo GIF
- **Size**: 800x1600px (max)
- **Format**: GIF or MP4
- **Duration**: 10-15 seconds
- **Location**: `assets/images/demo.gif`

**Content**: Show complete sign-to-speech flow

#### 5. Logo Variations
- **Formats**: SVG, PNG (multiple sizes)
- **Variations**:
  - Full color
  - White (for dark backgrounds)
  - Black (for light backgrounds)
  - Icon only
- **Location**: `assets/images/logo/`

#### 6. Social Media Assets
- **Twitter/X Card**: 1200x675px
- **Facebook Share**: 1200x630px
- **LinkedIn**: 1200x627px
- **Location**: `assets/images/social/`

---

## Asset Specifications

### Color Palette

```
Primary Colors:
├─ Primary Blue:    #007bff  (Main brand color)
├─ Primary Dark:    #0056b3  (Darker variant)
└─ Primary Light:   #4da3ff  (Lighter variant)

Secondary Colors:
├─ Secondary Gray:  #6c757d  (Text, borders)
├─ Success Green:   #28a745  (Success states)
├─ Warning Orange:  #ffc107  (Warnings)
└─ Error Red:       #dc3545  (Errors)

Background Colors:
├─ Background:      #ffffff  (Light mode)
├─ Surface:         #f8f9fa  (Cards, surfaces)
└─ Dark Background: #1a1a1a  (Dark mode)

Text Colors:
├─ Primary Text:    #212529  (Main text)
├─ Secondary Text:  #6c757d  (Secondary text)
└─ Disabled Text:   #adb5bd  (Disabled state)
```

### Typography

```
Font Family: Roboto (Material Design)

Headings:
├─ H1: 32sp, Bold
├─ H2: 24sp, Bold
├─ H3: 20sp, Medium
└─ H4: 16sp, Medium

Body Text:
├─ Body 1: 16sp, Regular
├─ Body 2: 14sp, Regular
└─ Caption: 12sp, Regular

Buttons:
└─ Button: 14sp, Medium, Uppercase
```

### Icon Style

```
Style Guidelines:
├─ Type: Material Design Icons
├─ Weight: Regular (400)
├─ Size: 24dp standard
├─ Color: Follow color palette
└─ Style: Rounded corners preferred
```

---

## Design Guidelines

### Brand Identity

**Core Values**:
- 🔒 **Privacy**: Emphasize local processing
- ⚡ **Speed**: Show real-time capabilities
- 🤝 **Accessibility**: Inclusive design
- 🎯 **Simplicity**: Clean, intuitive interface

**Visual Style**:
- Modern and minimal
- High contrast for accessibility
- Consistent spacing (8dp grid)
- Rounded corners (8dp radius)
- Material Design 3 principles

### Screenshot Guidelines

**Do's**:
- ✅ Use realistic data
- ✅ Show key features
- ✅ Include UI elements
- ✅ Demonstrate value
- ✅ Use high resolution
- ✅ Show happy path

**Don'ts**:
- ❌ No personal information
- ❌ No debug overlays
- ❌ No error states (unless intentional)
- ❌ No placeholder text
- ❌ No low-quality images
- ❌ No cluttered screens

### Animation Guidelines

**Sign Animations**:
- Duration: 1.5 seconds per sign
- Format: Lottie JSON
- Frame rate: 30 FPS
- Size: < 100KB per animation
- Style: Consistent character design

**UI Animations**:
- Duration: 200-300ms
- Easing: Material standard
- Purpose: Provide feedback
- Subtlety: Not distracting

---

## Asset Creation Tools

### Recommended Tools

#### 1. Vector Graphics
- **Figma** (Free, web-based)
  - Best for: UI design, prototyping
  - Export: PNG, SVG, PDF
  
- **Adobe Illustrator** (Paid)
  - Best for: Logo design, icons
  - Export: All formats

- **Inkscape** (Free, open-source)
  - Best for: Vector editing
  - Export: SVG, PNG

#### 2. Raster Graphics
- **Figma** (Free)
  - Best for: Screenshots, mockups
  
- **Adobe Photoshop** (Paid)
  - Best for: Photo editing, composites
  
- **GIMP** (Free, open-source)
  - Best for: Image editing

#### 3. Animation
- **LottieFiles** (Free)
  - Best for: Sign animations
  - Export: Lottie JSON
  
- **Adobe After Effects** (Paid)
  - Best for: Complex animations
  - Export: Lottie via plugin

#### 4. Screen Recording
- **Android Studio Emulator** (Free)
  - Built-in screen recording
  
- **scrcpy** (Free, open-source)
  - Screen mirroring and recording
  
- **OBS Studio** (Free)
  - Professional recording

#### 5. GIF Creation
- **ScreenToGif** (Free, Windows)
- **LICEcap** (Free, cross-platform)
- **Gifski** (Free, Mac)

---

## Implementation Guide

### Adding App Icon

1. **Create icon in required sizes**
2. **Place in appropriate directories**:
   ```
   android/app/src/main/res/
   ├── mipmap-mdpi/ic_launcher.png
   ├── mipmap-hdpi/ic_launcher.png
   ├── mipmap-xhdpi/ic_launcher.png
   ├── mipmap-xxhdpi/ic_launcher.png
   └── mipmap-xxxhdpi/ic_launcher.png
   ```
3. **Update AndroidManifest.xml**:
   ```xml
   <application
       android:icon="@mipmap/ic_launcher"
       ...>
   ```

### Adding Screenshots to README

```markdown
## Screenshots

<div align="center">
  <img src="assets/images/screenshots/home.png" width="200" alt="Home Screen"/>
  <img src="assets/images/screenshots/sign-to-speech.png" width="200" alt="Sign to Speech"/>
  <img src="assets/images/screenshots/speech-to-sign.png" width="200" alt="Speech to Sign"/>
</div>
```

### Adding Demo GIF

```markdown
## Demo

![SignBridge Demo](assets/images/demo.gif)
```

### Adding Banner to README

```markdown
<div align="center">
  <img src="assets/images/github-banner.png" alt="SignBridge Banner"/>
</div>
```

---

## Asset Checklist

### Pre-Launch Checklist

- [ ] **App Icon**
  - [ ] All sizes created
  - [ ] Properly placed in directories
  - [ ] Tested on device
  
- [ ] **Screenshots**
  - [ ] Home screen
  - [ ] Sign-to-Speech mode
  - [ ] Speech-to-Sign mode
  - [ ] Settings screen
  - [ ] All in high resolution
  
- [ ] **Marketing Assets**
  - [ ] GitHub banner created
  - [ ] Demo GIF recorded
  - [ ] Logo variations created
  
- [ ] **Documentation**
  - [ ] Assets added to README
  - [ ] Links verified
  - [ ] Images optimized

### Quality Checklist

- [ ] All images are high resolution
- [ ] File sizes are optimized
- [ ] No personal information visible
- [ ] Consistent branding
- [ ] Accessible color contrast
- [ ] All links work
- [ ] Mobile-friendly display

---

## Asset Optimization

### Image Optimization

**Tools**:
- **TinyPNG** - PNG compression
- **ImageOptim** - Mac image optimizer
- **Squoosh** - Web-based optimizer

**Guidelines**:
- Screenshots: < 500KB each
- Icons: < 50KB each
- Banner: < 200KB
- GIF: < 5MB

### Best Practices

1. **Use appropriate formats**:
   - PNG: Icons, screenshots (transparency needed)
   - JPG: Photos, banners (no transparency)
   - SVG: Logos, icons (scalable)
   - GIF/MP4: Animations

2. **Optimize for web**:
   - Compress images
   - Use appropriate dimensions
   - Consider lazy loading

3. **Maintain quality**:
   - Keep source files
   - Export at 2x for retina displays
   - Test on multiple devices

---

## Templates

### Screenshot Template (Figma)

```
Frame: 1080x2400px
Background: #ffffff
Status Bar: Android 13 style
Navigation: Material Design 3
Content: Actual app screens
```

### Banner Template

```
Canvas: 1280x640px
Background: Gradient (Blue to Purple)
Logo: Left side, 200x200px
Text: Right side, Roboto Bold
Icons: Bottom, feature highlights
```

---

## Resources

### Design Inspiration
- [Dribbble - Accessibility Apps](https://dribbble.com/tags/accessibility)
- [Behance - Mobile App Design](https://www.behance.net/search/projects?search=mobile%20app)
- [Material Design Gallery](https://material.io/design)

### Icon Resources
- [Material Icons](https://fonts.google.com/icons)
- [Heroicons](https://heroicons.com/)
- [Feather Icons](https://feathericons.com/)

### Stock Photos
- [Unsplash](https://unsplash.com/)
- [Pexels](https://www.pexels.com/)
- [Pixabay](https://pixabay.com/)

### Learning Resources
- [Material Design Guidelines](https://material.io/design)
- [Android Design Patterns](https://www.android.com/design/)
- [Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

## Support

For questions about visual assets:
- Open an issue on GitHub
- Check existing documentation
- Review Material Design guidelines

---

**Last Updated**: 2025-11-26
**Version**: 1.0.0