//
//  JSFix.m
//  热修复
//
//  Created by xueshan1 on 2018/9/12.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import "JSFix.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSInvocation+LYAddtion.h"
#import "NSInvocation+Block.h"

#import "FixObject.h"
#import "UIColor+xsfix.h"
#import "NSObject+invocation.h"

@interface JSFix ()
@property(nonatomic,strong)NSMutableDictionary *fixObjs;

@end

@implementation JSFix

+ (instancetype)shareInstance{
  static JSFix *obj = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    obj = [JSFix new];
    obj.fixObjs = [NSMutableDictionary dictionaryWithCapacity:4];
  });
  return obj;
}

+ (JSContext *)context{
  static JSContext *context = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    context = [[JSContext alloc]init];
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
      NSLog(@"JSContext异常:%@",exception);
    };
    
  });
  return context;
}


+ (id)evaluateJSString:(NSString *)jsString{
  if (jsString == nil || jsString==(id)[NSNull null] || ![jsString isKindOfClass:[NSString class]]) return nil;
  
  JSValue *value = [[self context]evaluateScript:jsString];
  
  id object = [value toObject];
  if (object) {
    return object;
  }
  
  return nil;
}


///  执行jsScript 脚本,中的 function jsFunction() 方法
/// @param jsFunction js中的方法名
+ (void)contextEvaluateJsScript:(NSString *)jsScript JsFunction:(NSString *)jsFunction{
  if (!jsScript || !jsFunction) return;
  
  [[self context] evaluateScript:jsScript];
  JSValue *evaluateValue = [self context][jsFunction];
  [evaluateValue callWithArguments:nil];
}

#pragma mark -
#pragma mark - xs
+ (void)initFix{
  JSContext *context = [JSFix context];
  
  [self initOtherContext];
  
  context[@"getWeakObj"] = ^id(id obj){
    __weak typeof(obj) weakObj = obj;
    return weakObj;
  };
  context[@"getStrongObj"] = ^id(id obj){
    __strong typeof(obj) strongObj = obj;
    return strongObj;
  };
  //调用
  context[@"runInvocation"] = ^(NSInvocation *invocation){
    [invocation invoke];
  };
  //改变返回值
  context[@"runInvocationReturnValue"] = ^(NSInvocation *invocation,id newReturenValue){
    invocation.returnValue_obj = newReturenValue;
  };
  //改变参数
  context[@"setInvocationArguments"] = ^(NSInvocation *invocation,id arguments){
    if ([arguments isKindOfClass:[NSArray class]]) {
      invocation.arguments = arguments;
    }else{
      [invocation setMyArgument:arguments atIndex:0];//已经自动+2
    }
  };
  context[@"setInvocationArgumentsAtIndex"] = ^(NSInvocation *invocation,id arguments,NSInteger index){
    [invocation setMyArgument:arguments atIndex:index];//已经自动+2
  };
  
  //获取参数
  context[@"getInvocationArgumentsAtIndex"] = ^id(NSInvocation *invocation, NSInteger index){
    
    return [invocation myArgumentAtIndex:index];
  };
  
  //1.调用类方法:通过类名即可调用 任意方法, 有返回值
  context[@"runClassMethod"] = ^id(NSString *className,NSString *selectorName,id arguments){
    id obj = [JSFix runWithClassName:className selectorName:selectorName arguments:arguments];
    return obj;
  };
  //2.调用实例方法, 有返回值
  context[@"runInstanceMethod"] = ^(id instatnce,NSString *selectorName,id arguments){
    id obj = [JSFix runWithInstance:instatnce selectorName:selectorName arguments:arguments];
    return obj;
  };
  
  
  //3.替换
  //js实现 --> OC方法(用NSMethodSignature\NSInvocation实现) --> 替换(runtime实现)
  context[@"FixMethod"] = ^(NSString *className, NSString *selectorName, XSFixType fixType, JSValue *fixImp) {//方法实现
    NSLog(@"FixMethod %@ 类的 %@ 方法",className,selectorName);
    [JSFix replaceMethodWithClassName:className selector:selectorName fixType:fixType fixImp:fixImp];
  };
  
  //修复指定方法
  /*
   参数:
   1.类名
   2.方法名
   3.是否是类方法
   4.修复的方式（前、中、后）
   5.js 方法实现
   */
  context[@"RestoreMethod"] = ^(NSString *className, NSString *selectorName,BOOL isClassMethod,XSFixType fixType, JSValue *fixImp) {//方法实现
    NSLog(@"RestoreMethod %@ 类的 %@ 方法",className,selectorName);
    [JSFix restoreMethodWithClassName:className selector:selectorName isClassMethod:isClassMethod fixType:fixType fixImp:fixImp];
  };
  
  
  //4.向某个类添加方法
  context[@"addMethodToClass"] = ^(NSString *className,NSString *newSelectorName,NSString *existingSelectorName) {
    NSLog(@"给 %@ 类增加 %@ 方法",className,newSelectorName);
    
    [JSFix addMethodToClass:className newSelector:newSelectorName existingSelectorName:existingSelectorName];
  };
  
  //调用super 的方法
  context[@"runInvocation_sendSuper"] = ^(id target,NSString *selector,NSArray *args){
    [self sendSuperMsg:target methodName:selector arguments:args];
  };
  
  
  /*
   将 js 的方法 --> jsValues --> 字符串
   */
  context[@"toOCString"] = ^id(JSValue *fixImp) {//方法实现
    NSString *str = [fixImp toString];
    return str;
  };
  context[@"toOCObject"] = ^id(JSValue *fixImp) {//方法实现
    //        [fixImp callWithArguments:nil];
    
    [[ViewController new]testblockParameter:^{
      
      [fixImp callWithArguments:nil];
    }];
    
    return nil;
  };
  
  //将js 函数作为block参数 传给 oc
  //原理: "oc生成block" -> 返回给js -> js再传给oc作为函数的参数
  //argTypes: 1 是对象 0基本数据类型
  context[@"genCallbackBlock"] = ^id(JSValue *fixBlockImp,NSArray *argTypes){
    
#define Convert_Block_ARG(_idx,_para) \
if (_idx < argTypes.count) {\
NSInteger type = [argTypes[_idx] integerValue];\
if (type == 1) {\
[list addObject:(__bridge id)_para];\
}else{\
[list addObject:[NSNumber numberWithLongLong:(long long)_para]];\
}\
}\

    
    id block = ^id(void * p0, void * p1, void * p2, void * p3 ) {
      NSMutableArray *list = [NSMutableArray array];
      
      Convert_Block_ARG(0,p0);
      Convert_Block_ARG(1,p1);
      Convert_Block_ARG(2,p2);
      Convert_Block_ARG(3,p3);
      
      JSValue *result = [fixBlockImp callWithArguments:list];
      return [result toObject];
    };
    
    return block;
  };
  
}

+ (void)initOtherContext{
  JSContext *context = [JSFix context];
  
  context[@"runLog"] = ^(id logContent){
#ifdef DEBUG
    NSLog(@"js调用打印:%@",logContent);
#endif
  };
  context[@"ScreenWidth"] = ^CGFloat(){
    return [UIScreen mainScreen].bounds.size.width;
  };
  context[@"ScreenHeight"] = ^CGFloat(){
    return [UIScreen mainScreen].bounds.size.height;
  };
  context[@"HexColor"] = ^id(NSString *hexColor){
    UIColor *color = [UIColor colorWithHexString:hexColor];
    return color;
  };
  
  context[@"GetCGPoint"] = ^(double x,double y){
    CGPoint point =  CGPointMake(x, y);
    return NSStringFromCGPoint(point);
  };
  context[@"GetCGSize"] = ^(double width,double height){
    CGSize size = CGSizeMake(width, height);
    return NSStringFromCGSize(size);
  };
  context[@"GetCGRect"] = ^(double x,double y,double width,double height){
    CGRect rect =  CGRectMake(x, y, width, height);
    return NSStringFromCGRect(rect);
  };
  context[@"GetNSRange"] = ^(NSUInteger loc,NSUInteger len){
    NSRange range = NSMakeRange(loc , len);
    return NSStringFromRange(range);
  };
  context[@"GetUIEdgeInsets"] = ^(CGFloat top,CGFloat left,CGFloat bottom,CGFloat right){
    UIEdgeInsets inset =  UIEdgeInsetsMake(top, left, bottom, right);
    return NSStringFromUIEdgeInsets(inset);
  };
  //[obj class]
  context[@"GetClass"] = ^(id obj){
    Class cls = [obj class];
    return cls;
  };
  context[@"GetClassFromString"] = ^(NSString *className){
    Class cls = NSClassFromString(className);
    return cls;
  };
  
  
  
  //GCD
  context[@"runInvocation_dispatch_after"] = ^(CGFloat second,JSValue *value){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [value callWithArguments:nil];
    });
  };
  context[@"runInvocation_dispatch_async_main"] = ^(JSValue *value){
    dispatch_async(dispatch_get_main_queue(), ^{
      [value callWithArguments:nil];
    });
  };
  context[@"runInvocation_dispatch_sync_main"] = ^(JSValue *value){
    dispatch_sync(dispatch_get_main_queue(), ^{
      [value callWithArguments:nil];
    });
  };
  context[@"runInvocation_dispatch_sync_main"] = ^(JSValue *value){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [value callWithArguments:nil];
    });
  };
  
  //animation
  context[@"runInvocation_UIView_animation"] = ^(NSTimeInterval duration,NSTimeInterval delay,UIViewAnimationOptions option,JSValue *animationValue,JSValue *completionValue){
    [UIView animateWithDuration:duration delay:delay options:option animations:^{
      [animationValue callWithArguments:nil];
    } completion:^(BOOL finished) {
      [completionValue callWithArguments:nil];
    }];
    
  };
  
  
  
  
}

static SEL originIMPSelector_forSelector(SEL selector){
  NSCParameterAssert(selector);
  return NSSelectorFromString([NSString stringWithFormat:@"originIMP_%@",NSStringFromSelector(selector)]);
}
static NSString * key_classForSelector(Class cls,SEL selector){
  NSCParameterAssert(selector);
  return [NSString stringWithFormat:@"%@_%@",NSStringFromClass(cls),NSStringFromSelector(selector)];
}
static SEL alias_forwardInvocation_sel() {
  return NSSelectorFromString(@"alias_forwardInvocation:");
};


/*
 forwardInvocation 新的实现
 
 可以拿到原来方法 参数
 
 //是不是类方法, 要是类方法就获取metaClass
 Class curClass = isClassMethod?objc_getMetaClass(object_getClassName(class)):class;
 
 
 */
static void replace_forwardInvocation(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation){
  NSLog(@"来到新的 forwardInvocation:实现  self类:%@   object_getClass:%@  object_isClass:%d",self , object_getClass(self),object_isClass(self));
  //    NSLog(@"%@ %@ %@",self,NSStringFromSelector(selector), NSStringFromSelector(invocation.selector));
  NSLog(@"消息转发取出:%@",key_classForSelector([self class],invocation.selector));
  
  FixObject *fixObj = [[JSFix shareInstance].fixObjs objectForKey:key_classForSelector([self class],invocation.selector)];
  fixObj.object = self;
  fixObj.arguments = invocation.arguments;
  invocation.selector = originIMPSelector_forSelector(invocation.selector);
  fixObj.originInvocation = invocation;
  [fixObj callJsValue_withOriginInvocation:invocation];
  
}

+ (void)replaceMethodWithClassName:(NSString *)className selector:(NSString *)selector fixType:(XSFixType)fixType fixImp:(JSValue *)fixImp{
  Class cls = NSClassFromString(className);
  SEL sel = NSSelectorFromString(selector);
  if ([cls instancesRespondToSelector:sel]) {//实例方法
    
  }else if ([cls respondsToSelector:sel]){//类方法
    cls = object_getClass(cls); //cls 变为为元类
  }else{
    return ;
  }
  
  FixObject *fixObj = [FixObject new];
  fixObj.fixType = fixType;
  fixObj.selector = NSSelectorFromString(selector);
  fixObj.jsValue_IMP = fixImp;
  
  NSLog(@"保存--abc:%@   cls:%@",key_classForSelector(cls,sel),cls);
  //保存该对象
  [[JSFix shareInstance].fixObjs setObject:fixObj forKey:key_classForSelector(cls,sel)];
  
  Method origin_method = class_getInstanceMethod(cls, sel);
  const char *typeEncoding = method_getTypeEncoding(origin_method);
  SEL aliasSelector = originIMPSelector_forSelector(NSSelectorFromString(selector));
  //1.
  //+新方法名字 使用原来的方法实现
  class_addMethod(cls, aliasSelector, method_getImplementation(origin_method), typeEncoding);//原来的实现
  //2.替换两个
  //2.1替换该class的 -forwardInvocation的实现
  class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)replace_forwardInvocation, "v@:@");
  //2.2替换该class的 原方法实现 ->触发消息转发
  //    class_replaceMethod(cls, sel, _objc_msgForward, typeEncoding);//_objc_msgForward 需要改成runtime 返回的, 不要直接这样用
  IMP xs_objc_msgForward = class_getMethodImplementation(cls, NSSelectorFromString(@"xs_notExistMethod"));
  class_replaceMethod(cls, sel, xs_objc_msgForward, typeEncoding);
  
  
}

//MARK:优化的 replace
static void swizzle_forwardInvocation(__unsafe_unretained NSObject *target, SEL selector, NSInvocation *invocation){
  
  FixObject *fixObj = [[JSFix shareInstance].fixObjs objectForKey:key_classForSelector([target class],invocation.selector)];
  //1.检查走到转发的消息，是否是热修复的消息
  if (fixObj) {
    fixObj.object = target;
    fixObj.arguments = invocation.arguments;
    //修改selector 为目标方法的别名方法, 这里保存着原实现
    invocation.selector = originIMPSelector_forSelector(invocation.selector);
    fixObj.originInvocation = invocation;
    //触发调用 JS 脚本
    [fixObj callJsValue_withOriginInvocation:invocation];
  }else{
    //2.继续执行原来的实现
    SEL oriIMPSelector = originIMPSelector_forSelector(invocation.selector);
    if ([target respondsToSelector:oriIMPSelector]) {
      objc_msgSend(target, oriIMPSelector,invocation.arguments);
    }else{
      SEL oriForwarIMP_Selector = alias_forwardInvocation_sel();
      if ([target respondsToSelector:oriForwarIMP_Selector]) {
        objc_msgSend(target, oriForwarIMP_Selector ,invocation);
      }
    }
    
  }
}

/// 优化的 replace
/// - Parameters:
///   - className: 类名
///   - selector: 方法名
///   - isClassMethod: 是否是类方法
///   - fixType: 修复的方式（前、中、后）
///   - fixImp: js 方法实现
+ (void)restoreMethodWithClassName:(NSString *)className selector:(NSString *)selector isClassMethod:(BOOL)isClassMethod fixType:(XSFixType)fixType fixImp:(JSValue *)fixImp {
  if (className.length == 0 || selector.length == 0) {
    return;
  }
  Class curClass = NSClassFromString(className);
  if (isClassMethod) {
    curClass = objc_getMetaClass(object_getClassName(curClass));
  }
  
  //1.处理目标方法
  SEL oriSelector = NSSelectorFromString(selector);
  Method oriMethod;
  if (isClassMethod) {
    oriMethod = class_getClassMethod(curClass, oriSelector);
  }else{
    oriMethod = class_getInstanceMethod(curClass, oriSelector);
  }
  IMP oriIMP = class_getMethodImplementation(curClass, oriSelector);
  const char *methodTypes = method_getTypeEncoding(oriMethod);
  //优先尝试添加目标方法
  if (class_addMethod(curClass, oriSelector, oriIMP, methodTypes)) {
    //添加成功, 说明之前没有该方法, 需要重新获取 method/imp
    oriMethod = isClassMethod ? class_getClassMethod(curClass, oriSelector) : class_getInstanceMethod(curClass,oriSelector);
    oriIMP = class_getMethodImplementation(curClass, oriSelector);
  }
  
  //2.处理目标方法_的别名方法
  //目标方法的别名，用于保存目标方法的实现（因为目标方法的实现会被替换）
  SEL swizzleSelector = originIMPSelector_forSelector(NSSelectorFromString(selector));
  IMP swizzleIMP = class_getMethodImplementation(curClass, swizzleSelector);
  //保存目标方法的实现, 存在别名方法名下
  if (class_addMethod(curClass, swizzleSelector, oriIMP, methodTypes)) {
    //保存成功后
    //1.替换消息转发中的 forwardInvocation 方法实现，为自定义的实现：swizzle_forwardInvocation
    IMP oriFowardIMP = class_getMethodImplementation(curClass, @selector(forwardInvocation:));
    if (oriFowardIMP != (IMP)swizzle_forwardInvocation) {
      class_replaceMethod(curClass, @selector(forwardInvocation:), (IMP)swizzle_forwardInvocation, "v@:@");
      if (oriFowardIMP) {
        class_addMethod(curClass, alias_forwardInvocation_sel(), oriFowardIMP, "v@:@");//保存原来的实现
      }
    }
    //2.替换目标方法的实现为_objc_msgForward, 从而能触发消息转发
    method_setImplementation(oriMethod, swizzleIMP);
    //3.生成 FixObject 对象，将要修复的目标方法的信息保存下来，当程序运行调用到该方法时，再执行相关操作
    FixObject *fixObj = [FixObject new];
    fixObj.selector = oriSelector;
    fixObj.isClassMethod = isClassMethod;
    fixObj.fixType = fixType;
    fixObj.jsValue_IMP = fixImp;
    [[JSFix shareInstance].fixObjs setObject:fixObj forKey:key_classForSelector(curClass, oriSelector)];
  }
  
}

#pragma mark -- 调用 OC 任意方法
/*
 实例-->方法
 */
+ (id)runWithInstance:(id)instance selectorName:(NSString *)selectorName arguments:(NSArray *)arguments{
  if (!instance) {
    return nil;
  }
  if (arguments && ![arguments isKindOfClass:[NSArray class]]) {
    arguments = @[arguments];
  }
  if ([instance isKindOfClass:[JSValue class]]) {
    instance = [instance toObject];
  }
  SEL sel = NSSelectorFromString(selectorName);
  NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
  if (!signature) {
    return nil;
  }
  @try {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = sel;
    invocation.arguments = arguments;
    [invocation invokeWithTarget:instance];
    return invocation.returnValue_obj;
  } @catch (NSException *exception) {
    NSLog(@"runWithInstance 异常:%@",exception);
  }
}

/*
 通过类名--> 调用类方法or实例方法
 */
+ (id)runWithClassName:(NSString *)className selectorName:(NSString *)selectorName arguments:(NSArray *)arguments{
  Class cla = NSClassFromString(className);
  SEL sel = NSSelectorFromString(selectorName);
  if (arguments && ![arguments isKindOfClass:[NSArray class]]) {
    arguments = @[arguments];
  }
  
  @try {
    if ([cla instancesRespondToSelector:sel]) {//实例方法
      id instance = [[cla alloc]init];
      NSMethodSignature *signature = [instance methodSignatureForSelector:sel];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
      invocation.selector = sel;
      invocation.arguments = arguments;//category简化
      [invocation invokeWithTarget:instance];
      return invocation.returnValue_obj;
    }else if([cla respondsToSelector:sel]){//类方法
      NSMethodSignature *signature = [cla methodSignatureForSelector:sel];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
      invocation.selector = sel;
      invocation.arguments = arguments;
      [invocation invokeWithTarget:cla];
      return invocation.returnValue_obj;
    }
  } @catch (NSException *exception) {
    NSLog(@"runWithClassName 异常:%@",exception);
  }
  
  return nil;
}


#pragma mark - 给某个类添加方法
+ (void)addMethodToClass:(NSString *)className newSelector:(NSString *)newSelectorName existingSelectorName:(NSString *)existingSelectorName {
  Class cls = NSClassFromString(className);
  SEL newSel = NSSelectorFromString(newSelectorName);
  SEL existSel = NSSelectorFromString(existingSelectorName);
  Method existMethod = class_getInstanceMethod(cls, existSel);
  IMP existIMP =  method_getImplementation(existMethod);
  const char *type = method_getTypeEncoding(existMethod);
  
  BOOL isAdd = class_addMethod(cls , newSel, existIMP, type);
  if (isAdd) {
    NSLog(@"add %@",isAdd?@"success":@"fail");
  }
  
}

#pragma mark - super
+ (id)sendSuperMsg:(id)obj methodName:(NSString *)methodName arguments:(NSArray *)arguments{
  if (!obj || !methodName) {
    return nil;
  }
  BOOL isClassMethod = NO;
  if (object_isClass(obj)) {
    isClassMethod = YES;
  }
  NSString *superMethodName = [NSString stringWithFormat:@"add_super_%@",methodName];
  SEL superMethodSEL = NSSelectorFromString(superMethodName);
  BOOL canInvoke = NO;
  if ([obj respondsToSelector:superMethodSEL]) {//添加过
    canInvoke = YES;
  }else{
    //        id invokeTarget = isClassMethod ? nsclassfrom
    Class objClass = isClassMethod ? objc_getMetaClass(object_getClassName(obj)) : object_getClass(obj);
    Class objSuperClass = [objClass superclass];
    SEL methodSEL = NSSelectorFromString(methodName);
    if (class_respondsToSelector(objSuperClass, methodSEL)) {
      Method objSuperMethod = isClassMethod ? class_getClassMethod(objSuperClass, methodSEL) : class_getInstanceMethod(objSuperClass, methodSEL);
      IMP objSuperMethodIMP = method_getImplementation(objSuperMethod);
      if (class_addMethod(objClass, superMethodSEL, objSuperMethodIMP, method_getTypeEncoding(objSuperMethod))) {
        canInvoke = YES;
      }
    }
  }
  
  if (canInvoke) {
    [self runWithClassName:NSStringFromClass([obj class]) selectorName:superMethodName arguments:arguments];
  }
  
  
  return nil;
}




@end






