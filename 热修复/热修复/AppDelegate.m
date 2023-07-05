//
//  AppDelegate.m
//  热修复
//
//  Created by xueshan1 on 2018/9/12.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"


#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "JSFix.h"
#import "Aspects.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
  //1.初始化框架
  [JSFix initFix];
  //2.加载 js 脚本
  NSString *path = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"js"];
  NSString *jsString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  [JSFix evaluateJSString:jsString];
  
  return YES;
}






@end
