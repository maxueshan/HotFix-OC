//
//  NSObject+xsfix.m
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import "NSObject+xsfix.h"
#import <objc/runtime.h>

@implementation NSObject (xsfix)
 
- (void)fixMethod{
    NSLog(@"fixMethod--%@",self);
}
- (void)fixMethod:(id)arg1{
    NSLog(@"--%@  %@",NSStringFromSelector(_cmd), arg1 );
}
- (void)fixMethod:(id)arg1 arg2:(id)arg2{}
- (void)fixMethod:(id)arg1 arg2:(id)arg2 arg3:(id)arg3{}

- (void)fixMethod_A{}
- (void)fixMethod_A:(id)arg1{}
- (void)fixMethod_A:(id)arg1 arg2:(id)arg2{}
- (void)fixMethod_A:(id)arg1 arg2:(id)arg2 arg3:(id)arg3{}
- (void)fixMethod_B{ }
- (void)fixMethod_B:(id)arg1{ }
- (void)fixMethod_B:(id)arg1 arg2:(id)arg2{ }
- (void)fixMethod_B:(id)arg1 arg2:(id)arg2 arg3:(id)arg3{ }
 
- (void)fixMethod_D{ }
- (void)fixMethod_D:(id)arg1{ }
- (void)fixMethod_D:(id)arg1 arg2:(id)arg2{ }
- (void)fixMethod_D:(id)arg1 arg2:(id)arg2 arg3:(id)arg3{ }

 
+ (void)load {

}
- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, origSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector{
    Class class = [self class];

    Method originalMethod = class_getClassMethod(class, origSelector);
    Method swizzledMethod = class_getClassMethod(class, newSelector);
    if (!originalMethod || !swizzledMethod) {
        return;
    }
    
    class = object_getClass((id)class);
    
    BOOL didAddMethod = class_addMethod(class, origSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if(didAddMethod){
        class_replaceMethod(class, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


- (void)xs_setAssociatedObject:(NSString *)key value:(id)value{
    objc_setAssociatedObject(self, [key UTF8String], value, OBJC_ASSOCIATION_RETAIN);
}
- (void)xs_associateObject:(NSString *)key{
    objc_getAssociatedObject(self, [key UTF8String]);
}

@end
