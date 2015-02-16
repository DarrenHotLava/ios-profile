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
