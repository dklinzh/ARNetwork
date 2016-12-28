//
//  NSObject+ARInspect.h
//  ARNetwork
//
//  Created by Linzh on 12/28/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ARInspect)
+ (NSArray*)ar_propertyNamesForClassOnly;

- (NSString*)ar_typeOfPropertyNamed:(NSString*)propertyName;

- (NSString*)ar_typeNameForTypeEncoding:(NSString*)typeEncoding;

- (Class)ar_classOfPropertyNamed:(NSString*)propertyName;
@end
