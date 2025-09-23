#!/bin/bash

# MindHearth App Icon Replacement Script
# This script helps replace the app icon with your new design

echo "🎨 MindHearth App Icon Replacement Script"
echo "=========================================="

# Check if source image exists
if [ ! -f "assets/icons/app_icon.png" ]; then
    echo "❌ Error: assets/icons/app_icon.png not found!"
    echo "Please create your 1024x1024px icon and save it as: assets/icons/app_icon.png"
    exit 1
fi

echo "✅ Found source icon: assets/icons/app_icon.png"

# Create backup of existing icons
echo "📦 Creating backup of existing icons..."
mkdir -p backup_icons/android backup_icons/ios
cp -r android/app/src/main/res/mipmap-* backup_icons/android/ 2>/dev/null || true
cp -r ios/Runner/Assets.xcassets/AppIcon.appiconset/* backup_icons/ios/ 2>/dev/null || true

echo "✅ Backup created in backup_icons/ directory"

# Function to resize image
resize_image() {
    local input="$1"
    local output="$2"
    local size="$3"
    
    if command -v sips >/dev/null 2>&1; then
        # macOS
        sips -z $size $size "$input" --out "$output"
    elif command -v convert >/dev/null 2>&1; then
        # ImageMagick
        convert "$input" -resize ${size}x${size} "$output"
    else
        echo "❌ Error: No image resizing tool found. Please install ImageMagick or use macOS sips"
        return 1
    fi
}

# Android icons
echo "🤖 Generating Android icons..."
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

resize_image "assets/icons/app_icon.png" "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" 72
resize_image "assets/icons/app_icon.png" "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" 48
resize_image "assets/icons/app_icon.png" "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" 96
resize_image "assets/icons/app_icon.png" "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" 144
resize_image "assets/icons/app_icon.png" "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" 192

# iOS icons
echo "🍎 Generating iOS icons..."
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" 1024
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png" 20
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png" 40
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png" 60
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png" 29
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png" 58
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png" 87
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png" 40
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png" 80
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png" 120
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png" 120
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png" 180
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png" 76
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png" 152
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png" 167

echo "✅ All icons generated successfully!"
echo ""
echo "📱 Next steps:"
echo "1. Test the app: flutter run"
echo "2. If you need to restore old icons: cp -r backup_icons/* ."
echo "3. Clean build if needed: flutter clean && flutter pub get"
echo ""
echo "🎉 Your new crescent moon and heart icon is now set!"
