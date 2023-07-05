//
//  UIButton+xsfix.m
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import "UIButton+xsfix.h"

@implementation UIButton (xsfix)

- (void)addTouchupInsideSelector:(NSString *)sel target:(id)target{
    [self addTarget:target action:NSSelectorFromString(sel) forControlEvents:UIControlEventTouchUpInside];
}


+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title superV:(UIView *)superV
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:title?:@"按钮" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [superV addSubview:btn];
    
    return btn;
}

@end
