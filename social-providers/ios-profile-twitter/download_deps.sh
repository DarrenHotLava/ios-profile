#!/bin/sh

if [ ! -d libs ];
then
	mkdir libs
fi

if [ ! -f libs/libSTTwitter.a ]; 
then
	git clone --recursive https://github.com/EugeneButusov/libSTTwitter.a-universal.git
	xcodebuild -configuration Release -project libSTTwitter.a-universal/STTwitter.xcodeproj -target STTwitter clean build
	mv libSTTwitter.a-universal/out/Release-universal/libSTTwitter.a libs/libSTTwitter.a
	rm -rf libSTTwitter.a-universal
fi
