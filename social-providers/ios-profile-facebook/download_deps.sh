#!/bin/sh

if [ ! -d libs ];
then
	mkdir libs
fi

if [ ! -d libs/FBSDKShareKit.framework ];
then
	curl -o fb-latest.zip https://origincache.facebook.com/developers/resources/?id=facebook-ios-sdk-current.zip
	mkdir fb-sources
	unzip fb-latest.zip -d fb-sources
	rm fb-latest.zip
	cp -r fb-sources/*.framework libs/
	cp -r fb-sources/*.bundle libs/
	rm -rf fb-sources
fi
