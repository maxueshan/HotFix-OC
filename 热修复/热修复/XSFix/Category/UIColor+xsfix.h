//
//  UIColor+xsfix.h
//  热修复
//
//  Created by xueshan1 on 2019/7/23.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (xsfix)

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

@end

NS_ASSUME_NONNULL_END
