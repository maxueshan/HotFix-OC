//
//  NSObject+invocation.m
//  热修复
//
//  Created by xueshan1 on 2019/11/14.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import "NSObject+invocation.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSInvocation+LYAddtion.h"
#import <objc/runtime.h>

@implementation NSObject (invocation)

/*
 通过实例调用
 */
- (id)invokeWithSelectorName:(NSString *)selectorName arguments:(NSArray *)arguments{
 
    if (arguments && ![arguments isKindOfClass:[NSArray class]]) {
        arguments = @[arguments];
    }
//    if ([self isKindOfClass:[JSValue class]]) {
//        instance = [instance toObject];
//    }
    SEL sel = NSSelectorFromString(selectorName);
    NSMethodSignature *signature = [self methodSignatureForSelector:sel];
    if (!signature) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = sel;
    invocation.arguments = arguments;
    [invocation invokeWithTarget:self];
    return invocation.returnValue_obj;
}

- (id)performSelector:(SEL)aSelector withArguments:(NSArray *)arguments{
    
    if (aSelector == nil) {
        @throw [NSException exceptionWithName:@"NullExcetption" reason: @"aSelector or objects is null" userInfo:nil];
        return nil;
    }
    
    NSMethodSignature *methodSignature = nil;
    if (object_isClass(self)) {
        methodSignature = [self methodSignatureForSelector:aSelector];
    }else{
        methodSignature = [[self class] instanceMethodSignatureForSelector:aSelector];
    }
    
    if(methodSignature == nil){
        @throw [NSException exceptionWithName:@"FunctionNotFoundExcetption" reason: [NSString stringWithFormat:@"the %@ not found",NSStringFromSelector(aSelector)] userInfo:nil];
        return nil;
    
    }else {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = aSelector;
        invocation.arguments = arguments;
        [invocation invokeWithTarget:self];;
        return invocation.returnValue_obj;
    }
}

@end
