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

#import <objc/runtime.h>

#import "ProviderLoader.h"
#import "ProviderNotFoundException.h"
#import "ProfileEventHandling.h"
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

- (BOOL)loadProvidersWithProtocol:(Protocol *)protocol andProviderParams:(NSDictionary *)providerParams {

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
            id targetProvider = @([provider getProvider]);
            if (providerParams) {
                [provider applyParams:providerParams[targetProvider]];
            }
            self.providers[targetProvider] = provider;
        }
        @catch (NSException *exception) {
            LogError(TAG, @"Couldn't instantiate provider class. Something's totally wrong here.");
        }
    }

    return YES;
}

- (id<IProvider>)getProvider:(Provider)provider {
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

    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class nextClass = classes[i];

            if (class_conformsToProtocol(nextClass, protocol)) {
                [providersArr addObject:NSClassFromString(NSStringFromClass(classes[i]))];
            }
        }
        free(classes);
    }

    return providersArr;
}

@end
