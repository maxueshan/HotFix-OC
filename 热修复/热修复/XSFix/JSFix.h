//
//  JSFix.h
//  热修复
//
//  Created by xueshan1 on 2018/9/12.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "ViewController.h"


@interface JSFix : NSObject

+ (JSContext *)context;

+ (void)initFix;


/**
 执行 js 中的函数function

 @param jsFunction 方法名
 */
+ (void)contextEvaluateJsScript:(NSString *)jsScript JsFunction:(NSString *)jsFunction;

+ (id)evaluateJSString:(NSString *)jsString;


@end
