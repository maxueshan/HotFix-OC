//
//  UIAlertView+fix.m
//  热修复
//
//  Created by xueshan1 on 2019/4/2.
//  Copyright © 2019 xueshan1. All rights reserved.
//

#import "UIAlertView+fix.h"
#import <objc/runtime.h>
#import "JSFix.h"


@implementation UIAlertView (fix)

+ (void)showWithTitle:(NSString *)title message:(NSString *)message  cancleTitle:(NSString *)cancleTitle sureTitle:(NSString *)sureTitle cancelJsScript:(NSString *)cancelJsScript sureJsScript:(NSString *)sureJsScript{
 
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancleTitle otherButtonTitles:sureTitle, nil];
    alertView.delegate = alertView;
    [alertView show];
    
    objc_setAssociatedObject(alertView, @"sureJsScript", sureJsScript?:@"", OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(alertView, @"cancelJsScript", cancelJsScript?:@"", OBJC_ASSOCIATION_RETAIN);

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *sureJsScript = objc_getAssociatedObject(alertView, @"sureJsScript");
        if (sureJsScript) {
            [JSFix contextEvaluateJsScript:sureJsScript JsFunction:Function_Name_UIAlertView_sureAction];
        }
        
    }else{
        NSString *cancelJsScript = objc_getAssociatedObject(alertView, @"cancelJsScript");
        if (cancelJsScript) {
            [JSFix contextEvaluateJsScript:cancelJsScript JsFunction:Function_Name_UIAlertView_cancelAction];
        }
    }
}


@end
