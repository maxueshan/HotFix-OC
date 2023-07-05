//
//  NSObject+xsfix.h
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (xsfix)

//用于给某各类添加新的方法
- (void)fixMethod;
- (void)fixMethod:(id)arg1;
- (void)fixMethod:(id)arg1 arg2:(id)arg2;
- (void)fixMethod:(id)arg1 arg2:(id)arg2 arg3:(id)arg3;

- (void)fixMethod_A;
- (void)fixMethod_A:(id)arg1;
- (void)fixMethod_A:(id)arg1 arg2:(id)arg2;
- (void)fixMethod_A:(id)arg1 arg2:(id)arg2 arg3:(id)arg3;

- (void)fixMethod_B;
- (void)fixMethod_B:(id)arg1;
- (void)fixMethod_B:(id)arg1 arg2:(id)arg2;
- (void)fixMethod_B:(id)arg1 arg2:(id)arg2 arg3:(id)arg3;
 
- (void)fixMethod_D;
- (void)fixMethod_D:(id)arg1;
- (void)fixMethod_D:(id)arg1 arg2:(id)arg2;
- (void)fixMethod_D:(id)arg1 arg2:(id)arg2 arg3:(id)arg3;

- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector;

+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector;

- (void)xs_setAssociatedObject:(NSString *)key value:(id)value;

@end

NS_ASSUME_NONNULL_END
