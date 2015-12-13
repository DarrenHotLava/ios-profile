#!/bin/sh

if [ ! -d libs ];
then
	mkdir libs
fi

# download Google Sign In framework if needed
if [ ! -d libs/GoogleSignIn.framework ];
then
	echo 'Downloading GoogleSignIn.framework...'
	curl -o google_signin_sdk_2_4_0.zip https://developers.google.com/identity/sign-in/ios/sdk/google_signin_sdk_2_4_0.zip
	unzip google_signin_sdk_2_4_0.zip
	rm google_signin_sdk_2_4_0.zip
	cp -r google_signin_sdk_2_4_0/*.framework libs/
	cp -r google_signin_sdk_2_4_0/*.bundle libs/
    rm -rf google_signin_sdk_2_4_0
fi

# download Google + if needed
if [ ! -d libs/GooglePlus.framework ];
then
	echo 'Downloading GooglePlus.framework...'
	curl -o google-plus-ios-sdk-1.7.1.zip https://developers.google.com/+/mobile/ios/sdk/google-plus-ios-sdk-1.7.1.zip
	unzip google-plus-ios-sdk-1.7.1.zip
	rm google-plus-ios-sdk-1.7.1.zip
	cp -r google-plus-ios-sdk-1.7.1/*.framework libs/
	cp -r google-plus-ios-sdk-1.7.1/*.bundle libs/
    rm -rf google-plus-ios-sdk-1.7.1
fi

# download GPGS framework if needed
if [ ! -d libs/gpg.framework ];
then
	echo 'Downloading GPGS.framework...'
	curl -o gpg-cpp-sdk.v2.0.zip https://developers.google.com/games/services/downloads/gpg-cpp-sdk.v2.0.zip
	unzip gpg-cpp-sdk.v2.0.zip
	rm gpg-cpp-sdk.v2.0.zip
	cp -r gpg-cpp-sdk/ios/*.framework libs/
	cp -r gpg-cpp-sdk/ios/*.bundle libs/
    rm -rf gpg-cpp-sdk
fi
