//
//  FixObject.m
//  热修复
//
//  Created by xueshan1 on 2018/11/22.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import "FixObject.h"

@implementation FixObject

+ (instancetype)shareInstance{
  static FixObject *obj = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    obj = [FixObject new];
  });
  return obj;
}
- (void)callJsIMP{
  NSMutableArray *array = [NSMutableArray array];
  if (self.object) {
    [array addObject:self.object];
  }
  if (self.originInvocation) {
    [array addObject:self.originInvocation];
  }
  if (self.arguments) {
    [array addObject:self.arguments];
  }
  //调用js实现
  [self.jsValue_IMP callWithArguments: array];//JSValue调用
}

- (void)callJsValue_withOriginInvocation:(NSInvocation *)originInvocation{
  _originInvocation = originInvocation;
  
  if (self.fixType == JSFixType_Before) {
    
    [self callJsIMP];
    [originInvocation invoke];
  }else if (self.fixType == JSFixType_Instead) {
    
    [self callJsIMP];
  }else if (self.fixType == JSFixType_After) {
    
    [originInvocation invoke];
    [self callJsIMP];
  }
  
}



@end
