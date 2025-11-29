#!/bin/bash

################################################################################
# SignBridge APK Build Script (Linux/macOS)
# 
# This script automates the Flutter APK build process for SignBridge.
# It checks prerequisites, installs dependencies, runs tests, and builds APKs.
#
# Usage: ./setup_and_build.sh [options]
# Options:
#   --skip-tests    Skip running tests
#   --debug-only    Build debug APK only
#   --release-only  Build release APK only
#   --clean         Clean before building
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
SKIP_TESTS=false
DEBUG_ONLY=false
RELEASE_ONLY=false
CLEAN_BUILD=false

for arg in "$@"; do
    case $arg in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --debug-only)
            DEBUG_ONLY=true
            shift
            ;;
        --release-only)
            RELEASE_ONLY=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Usage: $0 [--skip-tests] [--debug-only] [--release-only] [--clean]"
            exit 1
            ;;
    esac
done

# Function to print colored messages
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Start build process
print_header "SignBridge APK Build Script"
echo "Starting build process at $(date)"
echo ""

# Step 1: Check Flutter installation
print_header "Step 1: Checking Flutter Installation"

if ! command_exists flutter; then
    print_error "Flutter is not installed or not in PATH"
    echo ""
    echo "Please install Flutter first:"
    echo "  macOS: brew install flutter"
    echo "  Linux: https://flutter.dev/docs/get-started/install/linux"
    echo ""
    echo "Or follow FLUTTER_INSTALLATION_GUIDE.md for detailed instructions"
    exit 1
fi

print_success "Flutter is installed"
flutter --version
echo ""

# Step 2: Run Flutter Doctor
print_header "Step 2: Running Flutter Doctor"

flutter doctor -v
echo ""

# Check if Android toolchain is available
if ! flutter doctor | grep -q "Android toolchain"; then
    print_warning "Android toolchain may not be properly configured"
    print_info "Run 'flutter doctor' to see detailed issues"
fi

# Step 3: Check project structure
print_header "Step 3: Verifying Project Structure"

if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Are you in the project root?"
    exit 1
fi

print_success "Project structure verified"
echo ""

# Step 4: Clean build (if requested)
if [ "$CLEAN_BUILD" = true ]; then
    print_header "Step 4: Cleaning Previous Builds"
    
    flutter clean
    print_success "Clean completed"
    echo ""
fi

# Step 5: Install dependencies
print_header "Step 5: Installing Dependencies"

flutter pub get
print_success "Dependencies installed"
echo ""

# Step 6: Run tests (unless skipped)
if [ "$SKIP_TESTS" = false ]; then
    print_header "Step 6: Running Tests"
    
    if flutter test; then
        print_success "All tests passed"
    else
        print_warning "Some tests failed, but continuing with build"
    fi
    echo ""
else
    print_info "Skipping tests (--skip-tests flag used)"
    echo ""
fi

# Step 7: Build APKs
print_header "Step 7: Building APKs"

BUILD_DIR="build/app/outputs/flutter-apk"

# Build debug APK
if [ "$RELEASE_ONLY" = false ]; then
    print_info "Building debug APK..."
    
    if flutter build apk --debug; then
        print_success "Debug APK built successfully"
        
        if [ -f "$BUILD_DIR/app-debug.apk" ]; then
            DEBUG_SIZE=$(du -h "$BUILD_DIR/app-debug.apk" | cut -f1)
            print_info "Debug APK size: $DEBUG_SIZE"
            print_info "Location: $BUILD_DIR/app-debug.apk"
        fi
    else
        print_error "Debug APK build failed"
        exit 1
    fi
    echo ""
fi

# Build release APK
if [ "$DEBUG_ONLY" = false ]; then
    print_info "Building release APKs (split by architecture)..."
    
    if flutter build apk --release --split-per-abi; then
        print_success "Release APKs built successfully"
        echo ""
        
        # List all built APKs
        print_info "Built APKs:"
        for apk in "$BUILD_DIR"/*.apk; do
            if [ -f "$apk" ]; then
                SIZE=$(du -h "$apk" | cut -f1)
                FILENAME=$(basename "$apk")
                echo "  - $FILENAME ($SIZE)"
            fi
        done
    else
        print_error "Release APK build failed"
        exit 1
    fi
    echo ""
fi

# Step 8: Generate checksums
print_header "Step 8: Generating Checksums"

CHECKSUM_FILE="$BUILD_DIR/checksums.txt"
> "$CHECKSUM_FILE"  # Clear file

for apk in "$BUILD_DIR"/*.apk; do
    if [ -f "$apk" ]; then
        FILENAME=$(basename "$apk")
        
        # Generate SHA256 checksum
        if command_exists shasum; then
            CHECKSUM=$(shasum -a 256 "$apk" | cut -d' ' -f1)
        elif command_exists sha256sum; then
            CHECKSUM=$(sha256sum "$apk" | cut -d' ' -f1)
        else
            print_warning "No checksum tool available (shasum or sha256sum)"
            continue
        fi
        
        echo "$CHECKSUM  $FILENAME" >> "$CHECKSUM_FILE"
        print_info "$FILENAME: $CHECKSUM"
    fi
done

print_success "Checksums saved to $CHECKSUM_FILE"
echo ""

# Step 9: Build summary
print_header "Build Summary"

echo "Build completed successfully at $(date)"
echo ""
echo "Output directory: $BUILD_DIR"
echo ""

if [ -d "$BUILD_DIR" ]; then
    echo "Available APKs:"
    ls -lh "$BUILD_DIR"/*.apk 2>/dev/null || echo "No APK files found"
fi

echo ""
print_success "Build process completed!"
echo ""

# Step 10: Next steps
print_header "Next Steps"

echo "To install on a connected device:"
echo "  adb install $BUILD_DIR/app-arm64-v8a-release.apk"
echo ""
echo "To install via file transfer:"
echo "  1. Copy APK to your device"
echo "  2. Open file manager on device"
echo "  3. Tap APK file to install"
echo ""
echo "For more information, see:"
echo "  - APK_BUILD_GUIDE.md"
echo "  - FLUTTER_INSTALLATION_GUIDE.md"
echo "  - DEPLOYMENT_CHECKLIST.md"
echo ""

print_success "All done! 🎉"