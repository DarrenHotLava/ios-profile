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

/**
 A protocol that represents a provider, which will be used later for
 authentication and social actions.
 */
@protocol IProvider <NSObject>

/**
 Applies special initialization parameters to the provider
 
 @param providerParams the parameters needed by the provider to initialize
 */
- (void)applyParams:(NSDictionary *)providerParams;

/**
 Retrieves the `Provider` value of the provider it implements
 @return the `Provider` value of the provider it implements
 */
- (Provider)getProvider;

@end
