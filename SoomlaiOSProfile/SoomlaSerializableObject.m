//
// Created by Eugene Butusov on 21/11/15.
// Copyright (c) 2015 Soomla. All rights reserved.
//

#import <JSONConsts.h>
#import <SoomlaUtils.h>
#import "SoomlaSerializableObject.h"
#import "PJSONConsts.h"


@implementation SoomlaSerializableObject {

}

-(instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        provider = [UserProfileUtils providerStringToEnum:dict[UP_PROVIDER]];
    }
    return self;
}

-(NSDictionary *)toDictionary {
    return @{
            SOOM_CLASSNAME: [SoomlaUtils getClassName:self],
            UP_PROVIDER:    [UserProfileUtils providerEnumToString:self.provider]
    };
}

@end