//
//  NSObject+xsKeyValue.m
//  热修复
//
//  Created by xueshan1 on 2019/11/18.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import "NSObject+xsKeyValue.h"


@implementation NSObject (xsKeyValue)


#pragma mark -- KVC
-(id) is_objectValueForKeyPath:(NSString *) keyPath defaultValue:(id)defalutValue{
    
    if([self isKindOfClass:[NSNull class]]
       || keyPath == nil){
        return defalutValue;
    }
    
    @try {
        return [self valueForKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        
    }
    return defalutValue;
}


- (id)is_objectValueForKeyPath:(NSString *)keyPath
{
    return [self is_objectValueForKeyPath:keyPath defaultValue:nil];
}

-(id) is_objectValueForKey:(NSString *)key defaultValue:(id)defalutValue
{
    if([self isKindOfClass:[NSNull class]]
       || key == nil){
        return defalutValue;
    }
    
    @try {
        return [self valueForKey:key];
    }
    @catch (NSException *exception) {
        
    }
    return defalutValue;
}

- (id)is_objectValueForKey:(NSString *)key
{
    return [self is_objectValueForKey:key defaultValue:nil];
}


-(void) is_setObjectValue:(id) value forKeyPath:(NSString *) keyPath
{
    @try {
        [self setValue:value forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
    }
}

-(void) is_setObjectValue:(id) value forKey:(NSString *) key{
    
    @try {
        [self setValue:value forKey:key];
    }
    @catch (NSException *exception) {
    }
}


@end
