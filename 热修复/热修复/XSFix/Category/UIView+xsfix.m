//
//  UIView+xsfix.m
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import "UIView+xsfix.h"

@implementation UIView (xsfix)

- (void)setXs_x:(CGFloat)xs_x{
    CGRect frame = self.frame;
    frame.origin.x = xs_x;
    self.frame = frame;
}
- (CGFloat)xs_x{
    return self.frame.origin.x;
}
- (void)setXs_y:(CGFloat)xs_y{
    CGRect frame = self.frame;
    frame.origin.y = xs_y;
    self.frame = frame;
}
- (CGFloat)xs_y{
    return self.frame.origin.y;
}
- (void)setXs_centerX:(CGFloat)xs_centerX{
    CGPoint point = self.center;
    point.x = xs_centerX;
    self.center = point;
}
- (CGFloat)xs_centerX{
    return self.center.x;
}
- (void)setXs_centerY:(CGFloat)xs_centerY{
    CGPoint point = self.center;
    point.y = xs_centerY;
    self.center = point;
}
- (CGFloat)xs_centerY{
    return self.center.y;
}
- (void)setXs_width:(CGFloat)xs_width{
    CGRect frame = self.frame;
    frame.size.width = xs_width;
    self.frame = frame;
}
- (CGFloat)xs_width{
    return self.frame.size.width;
}
- (void)setXs_height:(CGFloat)xs_height{
    CGRect frame = self.frame;
    frame.size.height = xs_height;
    self.frame = frame;
}
- (CGFloat)xs_height{
    return self.frame.size.height;
}
- (void)setXs_right:(CGFloat)xs_right{
    CGFloat delta = xs_right - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}
- (CGFloat)xs_right{
    return self.frame.origin.x + self.frame.size.width;
}
- (void)setXs_bottom:(CGFloat)xs_bottom{
    CGRect newframe = self.frame;
    newframe.origin.y = xs_bottom - self.frame.size.height;
    self.frame = newframe;
}
- (CGFloat)xs_bottom{
    return self.frame.origin.y + self.frame.size.height;
}


#pragma mark -

- (void)setFrameX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height{
    self.frame = CGRectMake(x, y, width, height);
}

 
+ (UIView *)viewWithFrame:(CGRect)rect backgroundColor:(UIColor *)backgroundColor{
    UIView *view = [[UIView alloc]initWithFrame:rect];
    view.backgroundColor = backgroundColor;
    return view;
}


- (UIView*)subViewOfClassName:(NSString*)className {
    for (UIView* subView in self.subviews) {
        if ([NSStringFromClass(subView.class) isEqualToString:className]) {
            return subView;
        }
        
        UIView* resultFound = [subView subViewOfClassName:className];
        if (resultFound) {
            return resultFound;
        }
    }
    return nil;
}


@end
