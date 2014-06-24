//
//  ProviderLoader.m
//  SoomlaiOSProfile
//
//  Created by Gur Dotan on 6/2/14.
//  Copyright (c) 2014 Soomla. All rights reserved.
//

#import <objc/runtime.h>

#import "ProviderLoader.h"
#import "ProviderNotFoundException.h"
#import "UserProfileEventHandling.h"
#import "SoomlaUtils.h"
#import "IAuthProvider.h"
#import "ISocialProvider.h"


@implementation ProviderLoader

@synthesize providers;

static NSString* TAG = @"SOOMLA ProviderLoader";


- (id)init {
    self = [super init];
    if ([self class] == [ProviderLoader class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate AbstractClass directly." userInfo:nil];
    }
    return self;
}

- (BOOL)loadProvidersWithProtocol:(Protocol *)protocol {

    // Fetch a list of provider classes
    NSArray* providerClasses = [self tryFetchProvidersWithProtocol:protocol];
    if (!providerClasses || [providerClasses count] == 0) {
        return NO;
    }

    self.providers = [NSMutableDictionary dictionary];

    // Instantiate each provider class with reflection
    for (Class klass in providerClasses) {
        @try {
            id provider = [[klass alloc] init];
            self.providers[@([provider getProvider])] = provider;
        }
        @catch (NSException *exception) {
            LogError(TAG, @"Couldn't instantiate provider class. Something's totally wrong here.");
        }
    }

    return YES;
}

- (id<IProvider>)getProvider:(enum Provider)provider {
    id<IProvider> p = [self.providers objectForKey:@(provider)];
    if (!p) {
        @throw [[ProviderNotFoundException alloc] initWithProvider:provider];
    }

    return p;
}

- (NSArray *)tryFetchProvidersWithProtocol:(Protocol *)protocol {

    NSArray* providersArr = [self loadAllClassesConformingToProtocol:protocol];

    if (![providersArr count]) {
        LogDebug(TAG, ([NSString stringWithFormat:@"Failed to load provider.  No classes conform to the protocols: %@", protocol]));
        return nil;
    }

    return providersArr;
}

- (NSArray *)loadAllClassesConformingToProtocol:(Protocol *)protocol {
    NSMutableArray* providersArr = [NSMutableArray array];

    int numClasses;
    Class *classes = NULL;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    BOOL isSocialProvider = protocol == @protocol(ISocialProvider);

    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class nextClass = classes[i];

            // To make sure that only one type of provider (social or auth) is added each time
            // this method is called, and given that social providers inherit from auth providers,
            // we must check strict conformity or non-conformity.
            if (isSocialProvider) {
                if (class_conformsToProtocol(nextClass, protocol) &&
                    class_conformsToProtocol(nextClass, @protocol(IAuthProvider))) {
                    [providersArr addObject:NSClassFromString(NSStringFromClass(classes[i]))];
                }
            } else {
                if (class_conformsToProtocol(nextClass, protocol) &&
                    !class_conformsToProtocol(nextClass, @protocol(ISocialProvider))) {
                    [providersArr addObject:NSClassFromString(NSStringFromClass(classes[i]))];
                }
            }
        }
        free(classes);
    }

    return providersArr;
}

@end
