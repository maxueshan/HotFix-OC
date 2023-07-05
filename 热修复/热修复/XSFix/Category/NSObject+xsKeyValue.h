//
//  NSObject+xsKeyValue.h
//  热修复
//
//  Created by xueshan1 on 2019/11/18.
//  Copyright © 2019 xueshan1. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface NSObject (xsKeyValue)

#pragma mark -- KVC
-(id) is_objectValueForKeyPath:(NSString *) keyPath defaultValue:(id)defalutValue;

- (id)is_objectValueForKeyPath:(NSString *)keyPath;

-(id) is_objectValueForKey:(NSString *)key defaultValue:(id)defalutValue;

- (id)is_objectValueForKey:(NSString *)key;

-(void) is_setObjectValue:(id) value forKeyPath:(NSString *) keyPath;

-(void) is_setObjectValue:(id) value forKey:(NSString *) key;


@end

 
