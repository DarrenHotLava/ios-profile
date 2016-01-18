### v1.4.1 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.4.0...v1.4.1)

* Changes
  * Removed binaries from repo

### v1.4.0 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.3.0...v1.4.0)

* New Features
  * Added Google-Play Game Services social provider - with Leaderboards
  * Added Leaderboards support for GameCenter

* Changes
  * Changed Provider inheritance structure
  * Removed frameworks and libs from repo - added a download_deps script for it

### v1.3.0 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.2.0...v1.3.0)

* New Features
  * Added Leaderboards to GameCenter

### v1.2.0 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.9...v1.2.0)

* New Features
  * Added GameCenter as a social provider

### v1.1.9 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.8...v1.1.9)

* Fixes
  * Minor issues in logout

### v1.1.8 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.7...v1.1.8)

* Fixes
  * OpenAppRatingPage can’t open app page in AppStore

* Changes
  * Replaced deprecated read_stream permission with user_posts

### v1.1.7 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.6...v1.1.7)

* Features
  * New funcionallity for Profile

### v1.1.6 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.5...v1.1.6)

* Fixes
  * libSTTwitter updated to fix various issues.
  * Calling SoomlaProfile.login from within OnSoomlaProfileInitialized triggers a CC_ASSERT(mInited);

* Changes
  * Removed binaries and improved build scripts

### v1.1.5 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.4...v1.1.5)

* Fixes
  * Minor issues in extraParams
  * Changed getFeed in iOS according Android implementation

### v1.1.4 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.3...v1.1.4)

* New Features
  * Implemented Auto Login
  * Support extra params in UserProfile

* Changes
  * Added version in code
  * G+. Allow to log in from WebView instead of Safari on iOS

### v1.1.3 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.2...v1.1.3)

* New Features
  * Implemented auto login

* Fixes
  * Fixed WebView in Twitter login does not look well in landscape orientation
  * Fixed uploadImage signature

### v1.1.2 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.1...v1.1.2)

* Fixes
  * multiShare crash on iPad with iOS8
  * Fix for rating on iOS 7+

* Changes
  * avoid Safari login in FB
  * avoid Safari login in Twitter
  * improve working with the permissions in FB

### v1.1.1 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.0...v1.1.1)

* Fixes
  * Fix `publish_actions` permission

### v1.1.0 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.5...v1.1.0)

**BREAKING API VERSION**

* New Features
  * Implemented Pagination for getContactsWithProvider and getFeedWithProvider
  * Implemented multi-sharing (sharing with the native functionality of your target platform)
  * Implemented methods to show confirmation dialog before some actions
  * Supporting permissions param in FB

* Changes
  * Changed signature of `-[SoomlaProfile like:andPageId:andReward:]` (***breaking change***)

### v1.0.5 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.4...v1.0.5)

* Changes
  * Fixes to KVS from submodule

### v1.0.4 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.3...v1.0.4)

* New Features
  * Supporting uploadImage with NSData

### v1.0.3 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.2...v1.0.3)

* Fixes
  * Giving rewards before sending completion events
  * Making getStoredUserProfiles unrelated to profile init

### v1.0.2 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.1...v1.0.2)

* New Features
  * Adding getStoredUserProfiles
  * Upgrading example functionality

### v1.0.1 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.0...v1.0.1)

* Changes
  * Fixed the name of event handling class.

### v1.0.0 (17.11.14)
* Features
  * The module is integrated with Facebook, Google Plus and Twitter
  * Ability to preform following actions on multiple social networks (parallel):
    * Login/Logout
    * Update status
    * Update Story (supported fully in Facebook only)
    * Upload image
    * Get user profile + store it on the device
    * Get user's contacts (not all social networks provide all information)
    * Get user's most recent feed (not supported in Google Plus)
  * Common interface to handling URL callbacks from web authentication within module
