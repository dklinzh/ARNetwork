//
//  NSObject+ARInspect.m
//  ARNetwork
//
//  Created by Linzh on 12/28/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "NSObject+ARInspect.h"
#import <objc/runtime.h>

@implementation NSObject (ARInspect)
+ (NSArray*)ar_propertyNamesForClassOnly {
    // Collection.
    NSMutableArray *propertyNames = [NSMutableArray new];
    
    // Collect for this class.
    NSUInteger propertyCount;
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    for (int index = 0; index < propertyCount; index++)
    {
        NSString *eachPropertyName = [NSString stringWithUTF8String:property_getName(properties[index])];
        [propertyNames addObject:eachPropertyName];
    }
    
    free(properties); // As it is a copy
    
    // Return immutable.
    return [NSArray arrayWithArray:propertyNames];
}

- (NSString*)ar_typeOfPropertyNamed:(NSString*)propertyName {
    NSString *propertyType = nil;
    NSString *propertyAttributes;
    
    // Get Class of property.
    Class class = object_getClass(self);
    objc_property_t property = class_getProperty(class, [propertyName UTF8String]);
    
    // Try to get getter method.
    if (property == NULL)
    {
        char typeCString[256];
        Method getter = class_getInstanceMethod(class, NSSelectorFromString(propertyName));
        method_getReturnType(getter, typeCString, 256);
        propertyAttributes = [NSString stringWithCString:typeCString encoding:NSUTF8StringEncoding];
        
        // Mimic type encoding for `typeNameForTypeEncoding:`.
        propertyType = [self ar_typeNameForTypeEncoding:[NSString stringWithFormat:@"T%@", propertyAttributes]];
        
        if (getter == NULL)
        { ARLogError(@"No property called `%@` of %@", propertyName, NSStringFromClass(self)); }
    }
    
    // Or go on with property attribute parsing.
    else
    {
        // Get property attributes.
        const char *propertyAttributesCString;
        propertyAttributesCString = property_getAttributes(property);
        propertyAttributes = [NSString stringWithCString:propertyAttributesCString encoding:NSUTF8StringEncoding];
        
        if (propertyAttributesCString == NULL)
        { ARLogError(@"Could not get attributes for property called `%@` of <%@>", propertyName, NSStringFromClass(self)); }
        
        // Parse property attributes.
        NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
        if (splitPropertyAttributes.count > 0)
        {
            // From Objective-C Runtime Programming Guide.
            // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
            NSString *encodeType = splitPropertyAttributes[0];
            NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
            propertyType = (splitEncodeType.count > 1) ? splitEncodeType[1] : [self ar_typeNameForTypeEncoding:encodeType];
        }
        else
        { ARLogError(@"Could not parse attributes for property called `%@` of <%@>å", propertyName, NSStringFromClass(self)); }
    }
    
    return propertyType;
}

- (NSString*)ar_typeNameForTypeEncoding:(NSString*)typeEncoding {
    // From Objective-C Runtime Programming Guide.
    // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    NSDictionary *typeNamesForTypeEncodings = @{
                                                
                                                @"Tc" : @"char",
                                                @"Ti" : @"int",
                                                @"Ts" : @"short",
                                                @"Tl" : @"long",
                                                @"Tq" : @"long long",
                                                @"TC" : @"unsigned char",
                                                @"TI" : @"unsigned int",
                                                @"TS" : @"unsigned short",
                                                @"TL" : @"unsigned long",
                                                @"TQ" : @"unsigned long long",
                                                @"Tf" : @"float",
                                                @"Td" : @"double",
                                                @"Tv" : @"void",
                                                @"T^v" : @"void*",
                                                @"T*" : @"char*",
                                                @"T@" : @"id",
                                                @"T#" : @"Class",
                                                @"T:" : @"SEL",
                                                
                                                @"T^c" : @"char*",
                                                @"T^i" : @"int*",
                                                @"T^s" : @"short*",
                                                @"T^l" : @"long*",
                                                @"T^q" : @"long long*",
                                                @"T^C" : @"unsigned char*",
                                                @"T^I" : @"unsigned int*",
                                                @"T^S" : @"unsigned short*",
                                                @"T^L" : @"unsigned long*",
                                                @"T^Q" : @"unsigned long long*",
                                                @"T^f" : @"float*",
                                                @"T^d" : @"double*",
                                                @"T^v" : @"void*",
                                                @"T^*" : @"char**",
                                                
                                                @"T@" : @"id",
                                                @"T#" : @"Class",
                                                @"T:" : @"SEL"
                                                
                                                };
    
    // Recognized format.
    if ([[typeNamesForTypeEncodings allKeys] containsObject:typeEncoding])
    { return [typeNamesForTypeEncodings objectForKey:typeEncoding]; }
    
    // Struct property.
    if ([typeEncoding hasPrefix:@"T{"])
    {
        // Try to get struct name.
        NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"{="];
        NSArray *components = [typeEncoding componentsSeparatedByCharactersInSet:delimiters];
        NSString *structName;
        if (components.count > 1)
        { structName = components[1]; }
        
        // Falls back to `struct` when unknown name encountered.
        if ([structName isEqualToString:@"?"]) structName = @"struct";
        
        return structName;
    }
    
    // Falls back to raw encoding if none of the above.
    return typeEncoding;
}

- (Class)ar_classOfPropertyNamed:(NSString*)propertyName {
    // Attempt to get class of property.
    Class class = nil;
    NSString *className = [self ar_typeOfPropertyNamed:propertyName];
    class = NSClassFromString(className);
    
    // Warning.
    if (class == nil)
    { ARLogError(@"No class called `%@` in runtime", className); }
    
    return class;
}
@end
