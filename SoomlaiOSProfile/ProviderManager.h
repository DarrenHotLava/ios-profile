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
#import "IProvider.h"

@protocol IGameServicesProvider;
@protocol ISocialProvider;
@protocol IAuthProvider;


/**
 A parent class that provides unified access to all providers.
 */
@interface ProviderManager : NSObject

/**
 Constructor
 */
-(instancetype)init;
-(instancetype)initWithProviderParameters:(NSDictionary *)providerParameters;

/**
 Retrieves an instance of a class which implements provider logic
 
 @param provider The provider to get a concrete instance of
 @return The instance handling interaction with the supplied provider
 @exception ProviderNotFoundException if the provider is not supported
 */

-(id<IAuthProvider>)getAuthProvider:(Provider)provider;
-(NSArray *)getAllAuthProviders;

-(id<ISocialProvider>)getSocialProvider:(Provider)provider;
-(NSArray *)getAllSocialProviders;

-(id<IGameServicesProvider>)getGameServicesProvider:(Provider)provider;
-(NSArray *)getAllGameServicesProviders;

@end
