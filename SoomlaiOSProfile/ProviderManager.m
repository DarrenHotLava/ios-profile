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

#import "ProviderManager.h"
#import "ProviderNotFoundException.h"
#import "ProfileEventHandling.h"
#import "SoomlaUtils.h"
#import "IAuthProvider.h"
#import "ISocialProvider.h"
#import "IGameServicesProvider.h"


@implementation ProviderManager {
    NSMutableDictionary *_providers;
}

static NSString* TAG = @"SOOMLA ProviderManager";


- (id)init {
    return [self initWithProviderParameters:nil];
}

-(instancetype)initWithProviderParameters:(NSDictionary *)providerParameters {
    if (self = [super init]) {

        // Fetch a list of provider classes
        NSArray* providerClasses = [self loadAllProviderClasses];
        if (!providerClasses || [providerClasses count] == 0) {
            return nil;
        }

        _providers = [NSMutableDictionary dictionary];

        for (Class klass in providerClasses) {
            @try {
                id provider = [[klass alloc] init];
                id targetProvider = @([provider getProvider]);
                if (providerParameters) {
                    [provider applyParams:providerParameters[targetProvider]];
                }
                _providers[targetProvider] = provider;
            }
            @catch (NSException *exception) {
                LogError(TAG, @"Couldn't instantiate provider class. Something's totally wrong here.");
            }
        }
    }
    return self;
}

- (NSArray *)loadAllProviderClasses {
    NSMutableArray* providersArr = [NSMutableArray array];

    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class nextClass = classes[i];
            if (class_conformsToProtocol(nextClass, @protocol(IProvider))) {
                [providersArr addObject:NSClassFromString(NSStringFromClass(classes[i]))];
            }
        }
        free(classes);
    }

    return providersArr;
}

-(id<IProvider>)getProvider:(Provider)provider conformsToProtocol:(Protocol *)protocol {
    id<IProvider> instance = _providers[@(provider)];
    if (!instance || ![instance conformsToProtocol:protocol]) {
        @throw [[ProviderNotFoundException alloc] initWithProvider:provider];
    }
    return instance;
}

-(NSArray *)getAllProvidersConformingToProtocol:(Protocol *)protocol {
    NSMutableArray *result = [NSMutableArray new];
    for (id<IProvider> provider in _providers.allValues) {
        if ([provider conformsToProtocol:protocol]) {
            [result addObject:provider];
        }
    }
    return result;
}

-(id<IAuthProvider>)getAuthProvider:(Provider)provider {
    return (id<IAuthProvider>)[self getProvider:provider conformsToProtocol:@protocol(IAuthProvider)];
}

-(NSArray *)getAllAuthProviders {
    return [self getAllProvidersConformingToProtocol:@protocol(IAuthProvider)];
}

-(id<ISocialProvider>)getSocialProvider:(Provider)provider {
    return (id<ISocialProvider>)[self getProvider:provider conformsToProtocol:@protocol(ISocialProvider)];
}

-(NSArray *)getAllSocialProviders {
    return [self getAllProvidersConformingToProtocol:@protocol(ISocialProvider)];
}

-(id<IGameServicesProvider>)getGameServicesProvider:(Provider)provider {
    return (id<IGameServicesProvider>)[self getProvider:provider conformsToProtocol:@protocol(IGameServicesProvider)];
}

-(NSArray *)getAllGameServicesProviders {
    return [self getAllProvidersConformingToProtocol:@protocol(IGameServicesProvider)];
}

@end
