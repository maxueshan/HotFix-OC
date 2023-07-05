//
//  UIView+xsfix.h
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (xsfix)

@property (nonatomic, assign) CGFloat xs_x;
@property (nonatomic, assign) CGFloat xs_y;
@property (nonatomic, assign) CGFloat xs_centerX;
@property (nonatomic, assign) CGFloat xs_centerY;
@property (nonatomic, assign) CGFloat xs_width;
@property (nonatomic, assign) CGFloat xs_height;
@property (nonatomic, assign) CGFloat xs_right;
@property (nonatomic, assign) CGFloat xs_bottom;


//setFrameX:y:width:height:
- (void)setFrameX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

//viewWithFrame:backgroundColor:
+ (UIView *)viewWithFrame:(CGRect)rect backgroundColor:(UIColor *)backgroundColor;

//subViewOfClassName:
- (UIView*)subViewOfClassName:(NSString*)className;

@end

NS_ASSUME_NONNULL_END
