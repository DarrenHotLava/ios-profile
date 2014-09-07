/*
 Copyright (C) 2012-2014 Soomla Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "UserProfileUtils.h"

@implementation UserProfileUtils

+ (NSString *)providerEnumToString:(Provider)provider {
    
    switch(provider) {
        case FACEBOOK:
            return @"facebook";
        case FOURSQUARE:
            return @"foursquare";
        case GOOGLE:
            return @"google";
        case LINKEDIN:
            return @"linkedin";
        case MYSPACE:
            return @"myspace";
        case TWITTER:
            return @"twitter";
        case YAHOO:
            return @"yahoo";
        case SALESFORCE:
            return @"salesforce";
        case YAMMER:
            return @"yammer";
        case RUNKEEPER:
            return @"runkeeper";
        case INSTAGRAM:
            return @"instagram";
        case FLICKR:
            return @"flickr";
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return nil;
}

+ (Provider)providerStringToEnum:(NSString *)provider {
    Provider result;
    
    if ([provider isEqualToString:@"facebook"]) {
        result = FACEBOOK;
    } else if ([provider isEqualToString:@"foursquare"]) {
        result = FOURSQUARE;
    } else if ([provider isEqualToString:@"google"]) {
        result = GOOGLE;
    } else if ([provider isEqualToString:@"linkedin"]) {
        result = LINKEDIN;
    } else if ([provider isEqualToString:@"twitter"]) {
        result = TWITTER;
    } else if ([provider isEqualToString:@"yahoo"]) {
        result = YAHOO;
    } else if ([provider isEqualToString:@"salesforce"]) {
        result = SALESFORCE;
    } else if ([provider isEqualToString:@"yammer"]) {
        result = YAMMER;
    } else if ([provider isEqualToString:@"runkeeper"]) {
        result = RUNKEEPER;
    } else if ([provider isEqualToString:@"instagram"]) {
        result = INSTAGRAM;
    } else if ([provider isEqualToString:@"flickr"]) {
        result = FLICKR;
    } else {
        [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}


@end
