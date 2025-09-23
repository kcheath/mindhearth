#!/bin/bash

# MindHearth App Icons Replacement Script
# This script replaces all app icons in the AppIcons directory

echo "🎨 MindHearth App Icons Replacement Script"
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
mkdir -p backup_app_icons
cp -r ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/* backup_app_icons/ 2>/dev/null || true

echo "✅ Backup created in backup_app_icons/ directory"

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

# Android icons in AppIcons directory
echo "🤖 Generating Android icons in AppIcons directory..."
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-hdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-mdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-xhdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-xxhdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-xxxhdpi

resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-hdpi/ic_launcher.png" 72
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-mdpi/ic_launcher.png" 48
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-xhdpi/ic_launcher.png" 96
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-xxhdpi/ic_launcher.png" 144
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/android/mipmap-xxxhdpi/ic_launcher.png" 192

# iOS icons in AppIcons directory
echo "🍎 Generating iOS icons in AppIcons directory..."
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset

# Generate all the iOS icon sizes
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/16.png" 16
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/20.png" 20
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/29.png" 29
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/32.png" 32
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/40.png" 40
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/48.png" 48
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/50.png" 50
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/55.png" 55
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/57.png" 57
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/58.png" 58
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/60.png" 60
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/64.png" 64
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/66.png" 66
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/72.png" 72
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/76.png" 76
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/80.png" 80
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/87.png" 87
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/88.png" 88
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/92.png" 92
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/100.png" 100
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/102.png" 102
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/1024.png" 1024
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/108.png" 108
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/114.png" 114
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/120.png" 120
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/128.png" 128
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/144.png" 144
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/152.png" 152
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/167.png" 167
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/172.png" 172
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/180.png" 180
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/196.png" 196
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/216.png" 216
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/234.png" 234
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/256.png" 256
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/258.png" 258
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/Assets.xcassets/AppIcon.appiconset/512.png" 512

# App Store and Play Store icons
echo "🏪 Generating store icons..."
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/appstore.png" 1024
resize_image "assets/icons/app_icon.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/playstore.png" 512

echo "✅ All AppIcons directory icons generated successfully!"
echo ""
echo "📱 Next steps:"
echo "1. Test the app: flutter run"
echo "2. If you need to restore old icons: cp -r backup_app_icons/* ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcons/"
echo "3. Clean build if needed: flutter clean && flutter pub get"
echo ""
echo "🎉 Your new crescent moon and heart icon is now set in the AppIcons directory!"
