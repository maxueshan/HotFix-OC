//
//  NSInvocation+LYAddtion.h
//  LYFix
//
//  Created by xly on 2018/7/26.
//  Copyright © 2018年 Xly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (LYAddtion)

@property (nonatomic, strong) id returnValue_obj;

@property (nonatomic, copy) NSArray *arguments;

- (void)setMyArgument:(id)obj atIndex:(NSInteger)argumentIndex;
- (id)myArgumentAtIndex:(NSUInteger)index;

@end
