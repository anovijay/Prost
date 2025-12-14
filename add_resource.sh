#!/bin/bash

# Open Xcode project and add the resource file
open Prost.xcodeproj

echo "📋 INSTRUCTIONS TO ADD reading.json TO XCODE:"
echo ""
echo "1. In Xcode, right-click on the 'Prost' folder in the Project Navigator"
echo "2. Select 'Add Files to \"Prost\"...'"
echo "3. Navigate to: Prost/Resources/reading.json"
echo "4. Make sure 'Copy items if needed' is UNCHECKED (file is already in place)"
echo "5. Make sure 'Add to targets: Prost' is CHECKED"
echo "6. Click 'Add'"
echo ""
echo "📁 File location: $(pwd)/Prost/Resources/reading.json"
echo ""
