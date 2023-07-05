//
//  UIAlertView+fix.h
//  热修复
//
//  Created by xueshan1 on 2019/4/2.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
NS_ASSUME_NONNULL_BEGIN

static NSString  *Function_Name_UIAlertView_sureAction = @"Function_Name_UIAlertView_sureAction";
static NSString  *Function_Name_UIAlertView_cancelAction = @"Function_Name_UIAlertView_cancelAction";

@interface UIAlertView (fix)<UIAlertViewDelegate>

//showWithTitle:message:cancleTitle:sureTitle:cancelJsScript:sureJsScript:
+ (void)showWithTitle:(NSString *)title message:(NSString *)message  cancleTitle:(NSString *)cancleTitle sureTitle:(NSString *)sureTitle cancelJsScript:(NSString *)cancelJsScript sureJsScript:(NSString *)sureJsScript;

@end

NS_ASSUME_NONNULL_END
