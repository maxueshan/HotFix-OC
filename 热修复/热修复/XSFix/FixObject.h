//
//  FixObject.h
//  热修复
//
//  Created by xueshan1 on 2018/11/22.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef NS_ENUM(NSUInteger, XSFixType) {
    JSFixType_Before = 0,
    JSFixType_Instead,
    JSFixType_After,
};

@interface FixObject : NSObject

+ (instancetype)shareInstance;

@property(nonatomic,assign)XSFixType fixType;
@property(nonatomic,weak)id object; //调用方法的对象(实例 or Class)
@property(nonatomic,assign)SEL selector;
@property(nonatomic,assign)BOOL isClassMethod;
@property(nonatomic,strong)NSInvocation *originInvocation;
@property(nonatomic,strong)NSArray *arguments;
@property(nonatomic,strong)JSValue *jsValue_IMP;

//- (void)callJsIMP; //执行
- (void)callJsValue_withOriginInvocation:(NSInvocation *)originInvocation;


@end


