#!/bin/bash

echo "Building the project..."
xcodebuild -project BookTracker.xcodeproj \
           -scheme BookTracker \
           -configuration Debug \
           -sdk iphonesimulator \
           -derivedDataPath build

if [ $? -ne 0 ]; then
    echo "Build failed. Exiting."
    exit 1
fi

echo "Installing the app on the simulator..."
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/BookTracker.app

if [ $? -ne 0 ]; then
    echo "Install failed. Exiting."
    exit 1
fi

echo "Launching the app on the simulator..."
xcrun simctl launch booted id.ios.rajaongkirios.BookTracker

if [ $? -ne 0 ]; then
    echo "Launch failed. Exiting."
    exit 1
fi

echo "App launched successfully!"
