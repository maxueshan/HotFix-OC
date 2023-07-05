//
//  NSObject+invocation.h
//  热修复
//
//  Created by xueshan1 on 2019/11/14.
//  Copyright © 2019 xueshan1. All rights reserved.
//

 
#import <Foundation/Foundation.h>
 
@interface NSObject (invocation)

/*
 通过实例调用
 */
- (id)invokeWithSelectorName:(NSString *)selectorName arguments:(NSArray *)arguments;
    
    
- (id)performSelector:(SEL)aSelector withArguments:(NSArray *)arguments;
    
@end

 
