libtiff-ios
===========

Based on original script found at http://pastebin.com/Pgiy3rYJ

Compile libTIFF, libPNG and JPEG libraries for use on iOS

Creates fat binary libraries compatible with i386/Simulator,x86_64, arm64, armv7 and armv7s 


    ./build-jpg.sh
    ./build-tiff.sh
    ./build-png.sh
    

Use iOS 9 branch for XCode 7 and bitcode support

Location for the XCode version to use is identified using

    xcode-select -p
    
If you have multiple versions installed, you can switch to a different installation using

    xcode-select -s /full_path_to_xcode/
