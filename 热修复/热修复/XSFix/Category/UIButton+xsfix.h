//
//  UIButton+xsfix.h
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (xsfix)

- (void)addTouchupInsideSelector:(NSString *)sel target:(id)target;

//buttonWithFrame:title:superV:
+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title superV:(UIView *)superV;

@end

NS_ASSUME_NONNULL_END
