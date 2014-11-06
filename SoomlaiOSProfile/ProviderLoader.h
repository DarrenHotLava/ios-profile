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


/**
 ABSTRACT.
 A parent class that provides functionality for dynamic loading of providers.
 */
@interface ProviderLoader : NSObject {
    
    @private
    NSMutableDictionary* providers;
}

@property (strong, nonatomic) NSMutableDictionary* providers;

/**
 Constructor
 
 @exception NSInternalInconsistencyException if trying to instantiate 
 `ProviderLoader` itself
 */
- (id)init;

/**
 Loads and instatiates all providers implementing the supplied protocol
 
 @param protocol The protocol which the providers should implement
 @param providerParams Special initialization parameters for loaded providers
 @return YES if all providers were loaded, NO otherwise
 */
- (BOOL)loadProvidersWithProtocol:(Protocol *)protocol andProviderParams:(NSDictionary *)providerParams;

/**
 Retrieves an instance of a class which implements provider logic for the
 supplied social network
 
 @param provider The provider to get a concrete instance of
 @return The instance handling social interaction with the supplied provider
 @exception ProviderNotFoundException if the provider is not supported
 */
- (id<IProvider>)getProvider:(Provider)provider;


@end
