# HotFix-OC
Objective-C 热修复

玩一下 Objective - C 的热修复

支持的能力
● 支持在原方法实现之前、后插入新实现，或者替换
● 支持修改原方法的参数、返回值（支持 block 作为参数的方法）
● 支持给已有类添加新的方法和实现（开发 UI 以及需求逻辑等）
● 支持 GCD，UIView.animation 等 block 方法调用（但需要提前预埋这些方法）

1. 案例效果
首先介绍一个热修复的例子，然后再去看具体的实现原理，从而再去一层层的剥开那些并不神秘的面纱。
例1：修复方法 crash, 如在异步线程调用 UI 的刷新，导致的 crash，可通过下发脚本对该方法进行实现的替换，使其在主线程执行。
效果：
 
JS 代码：
RestoreMethod('ViewController','testMethod',0,1,function(instance,invocation,arg){
  runInvocation_dispatch_async_main(function(){
    var self = instance;
    var view = runInstanceMethod(self,'view')
    var redColor = runClassMethod('UIColor','redColor')
    runInstanceMethod(view,'setBackgroundColor:',redColor)
  })
})

例2：通过脚本下发一些简单 UI 需求，如在控制器的 viewDidLoad 方法中创建一个 UIButton，并实现点击事件
效果：
 
JS 代码：
RestoreMethod('ViewController','viewDidLoad',0, 2,function(instance,invocation,arg){
  var self = instance;
  var view = runInstanceMethod(self,'view')
  var color = HexColor('#508CEE')
  runInstanceMethod(view,'setBackgroundColor:',color)
  
  var redColor = runClassMethod('UIColor','redColor')
  var btn = runClassMethod('UIButton','new')
  runInstanceMethod(btn,'setFrameX:y:width:height:',new Array(50,200,300,60))
  runInstanceMethod(btn,'setBackgroundColor:',redColor)
  var layer = runInstanceMethod(btn,'layer')
  runInstanceMethod(layer,'setCornerRadius:',10)
  runInstanceMethod(layer, 'setMasksToBounds:', 1)
  runInstanceMethod(view,'addSubview:',btn)
  runInstanceMethod(btn,'setTitle:forState:',new Array('This is a Btn',0))
  var yellowColor = runClassMethod('UIColor','yellowColor')
  runInstanceMethod(btn,'setTitleColor:forState:',yellowColor)
  runInstanceMethod(btn,'addTouchupInsideSelector:target:',new Array('fixMethod',instance))

})

RestoreMethod('ViewController','fixMethod',0, 1,function(instance,invocation,arg){
  runLog('新增 button 的点击事件')
          
})

2.技术背景介绍
2.1 JavaScriptCore
JavaScriptCore 是 WebKit 默认内嵌的 JS 引擎（简称 JSCore），iOS7 之后苹果对 WebKit 中的 JSCore 进行了 Objective-C 的封装。改框架给 iOS 开发者提供了调用 JS 的能力，可实现 OC 和 JS 代码的相互调用。

本文并不对 JSCore 框架展开介绍，只是简单介绍一下本热修复功能主要用到的两个核心类：JSContext 和 JSValue，从而能快速理解热修功能底层核心原理。
JSContext
	JSContext 是我们再实际使用 JSCore时，用到最多的概念。
JSContext 上下文对象可以理解为是 JS 的运行环境，同一个JSVirtualMachine对象可以关联多个JSContext对象，一个 JSContext 表示了一次 JS 的执行环境。我们可以通过创建一个 JSContext 去调用JS 脚本，访问一些 JS 定义的值和函数，同时也提供了让 JS 访问 Native 对象，方法的接口。
JSValue
	JavaScript 和 Objective-C虽然都是面向对象语言，但其实现机制完全不同，OC 是基于类的，JS 是基于原型的，并且他们的数据类型间也存在很大的差异。因此若要在 Native 和JS间无障碍的进行数据的传递，就需要一个中间对象做桥接，这个对象就是JSValue。JSValue 是不能独立存在，它必须存在与某一个 JSContext 中。

如何使用呢？下面举几个简单的列子
OC 中调用 JS 脚本代码
- (void)OC_Call_JS {
    // 创建一个JSContext对象
    JSContext *jsContext = [[JSContext alloc] init];
    
    // 1.执行JS代码 计算js变量a和b之和
    [jsContext evaluateScript:@"var a = 1; var b = 2;"];
  	// 返回值是 JSValue 类型的对象
    JSValue *result = [jsContext evaluateScript:@"a + b"];
  	// 将 JSValue 类型转换成 OC 中的类型
    NSInteger sum = [result toInt32];
    NSLog(@"%ld", (long)sum);    // 3
     
    // 2.定义方法并调用
    [jsContext evaluateScript:@"var addFunc = function(a, b) { return a + b }"];
    JSValue *result = [jsContext evaluateScript:@"addFunc(a, b)"];
    NSLog(@"%@", result.toNumber);  // 3
    
    // 3.也可以OC传参
    JSValue *addFunc = jsContext[@"addFunc"];
  	// 在 OC 侧可以通过 callWithArguments：方法调用 js 的方法实现
    JSValue *addResult = [addFunc callWithArguments:@[@20, @30]];
    NSLog(@"%d", addResult.toInt32);    // 50
}

JS 脚本中调用 OC 代码
- (void)js_Call_OC {
    JSContext *jsContext = [[JSContext alloc] init];
  	// 向 JS 上下文中注入一个 addFunc 方法
    jsContext[@"addFunc"] = ^(NSInteger a, NSInteger b) {
        return a + b;
    };
  	// 调用 JS 脚本执行 OC 中的方法
    JSValue *addResult = [jsContext evaluateScript:@"addFunc(2, 4)"];
    NSLog(@"%@", addResult.toNumber);  // 6
}

通过以上的例子，简要介绍了一下 OC与 JS 之间交互的基本方式，而本热修复功能也正式利用了这些基本方式，实现了通过下发的 JS 脚本来达到调用到 OC 方法的目的。

2.2 OC 反射
在这里用到的主要是通过字符串反射到对应的类或SEL
通过字符串创建类：Class
//
NSClassFromString(@"NSObject");
//
objc_getClass("NSObject");
通过字符串创建方法：selector
//
NSSelectorFromString(@"init");
//
NSStringFromSelector(selector)
其他反射方法：
//
NSStringFromCGRect(rect);
//
NSStringFromRange(range);
...等等

2.3 Runtime
在这里并不展开介绍 Runtime 的细节，简要介绍一下所用到的方法，主要用到了如下几个：
//获取元类
Class objc_getMetaClass(const char *name)
//向类中添加方法
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types);
//替换方法的实现
BOOL class_replaceMethod(Class cls, SEL name, IMP imp, const char *types);
//返回方法的实现
IMP method_getImplementation ( Method m );
//获取描述方法参数和返回值类型的字符串
const char * method_getTypeEncoding ( Method m );
//获取实例方法的 Method
Method class_getInstanceMethod(Class cls, SEL name);
//获取类方法的 Method
Method class_getClassMethod(Class cls, SEL name);


2.4 消息转发
当给一个对象发送消息的时候， 如果在其方法列表或父类方法列表中都没有找方法实现，那么就会进入到消息转发流程，整体来看主要有三个步骤， 如下图所示：
 

转发流程涉及到的方法主要有：
// 1.运行时动态添加方法
+ (BOOL)resolveInstanceMethod:(SEL)sel 

// 2.快速转发
- (id)forwardingTargetForSelector:(SEL)aSelector

// 3.构建方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector

// 4.消息转发
- (void)forwardInvocation:(NSInvocation *)anInvocation
我们正是利用了最后的 forwardInvocation：这个方法，其参数是一个 NSInvocation 对象。NSInvocation 对象包含了这个方法调用的所有信息，如：target、selector、参数、返回值类型等，并且你还可以更改这些信息。
当然，除了上面这些正常的转发流程，我们可以通过一个神奇的指针 _objc_msgForward 来强制触发消息转发。我们下面将要介绍的热修复原理正式利用了这个指针，但是并没有显示的指定这个指针，而是通过 Runtime 获取一个不存在的方法实现时，其返回值就是这个指针了，已经验证过了。
	
3.热修复原理（流程）
上面对热修复所用到的一些知识简单的介绍了一下，下面来详细的介绍一下热修复框架的原理，首先通过一张图来看下整体的流程：
 
● 通过JS脚本通过 JSCore 调用到 OC 代码
● 在 OC 代码中，通过 NSInvocation 可实现对实例方法或类方法的调用
● 在 OC 代码中，通过 Runtime 实现的对 OC 类中方法实现的替换，以及增加方法操作
下面将针对这些流程进行详细的展开解释。

3.1 JS 对 OC 代码的调用
方法的预埋，基于以上对 JSCore 使用背景的介绍，看到这些方法就一目了然了。同样也得益于 OC 支持的映射机制，从而， JS 传递到 OC 的字符串能够容易的映射出对应的类名、方法名等。
例如下面一段代码：初始化一个 JSContext 对象，然后向 JS 上下文注入 OC 的方法实现，回调的参数有：实例对象（or 类名）、方法名、参数，以及回调的返回值。
+ (void)initFix{
    JSContext *context = [JSFix context]; 
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
        [JSFix restoreMethodWithClassName:className selector:selectorName isClassMethod:isClassMethod fixType:fixType fixImp:fixImp];
    };
  
		//调用类方法:通过类名即可调用 任意方法, 有返回值
    context[@"runClassMethod"] = ^id(NSString *className,NSString *selectorName,id arguments){
        id obj = [JSFix runWithClassName:className selectorName:selectorName arguments:arguments];
        return obj;
    };

    //调用实例方法, 有返回值
    context[@"runInstanceMethod"] = ^(id instatnce,NSString *selectorName,id arguments){
        id obj = [JSFix runWithInstance:instatnce selectorName:selectorName arguments:arguments];
        return obj;
    };

		//...等等还有一些其他方法，暂不一一列举了。
}
 

3.2 NSInvocation 的使用
上述预埋方法的回调中，调用到了如下这个方法。
JS 可将实例对象，以及 selector、参数等传递到 OC, 通过反射机制转换成所需要的类型， 最终通过 NSInvocation 对象实现的对实例方法或类方法的调用。

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

3.3 Runtime 的使用
主要是通过 Runtime 相关方法来触发 OC 方法的消息转发机制。我们知道，在运行期间调用的 OC 方法的实现不存在时，会走到消息转发机制，正是利用转发机制中最后一步的 forwardInvocation  方法，并从该方法参数中能够获取到方法的原始实现，也就是 NSInvocation 对象，然后在指定的位置插入自定义的代码实现。
	1. 方法替换
主要操作有：
1. 通过 Runtime 替换目标方法的实现为_objc_msgForward，以便触发消息转发机制
2. 将目标方法的原来的实现，保存在一个别名方法中，以便对原实现的调用
3. 通过 Runtime 替换消息转发中的 forwardInvocation 方法实现，替换为自定义的实现
4. 在 forwardInvocation 自定义实现中，可对 JS 的脚本实现的调用，以及对目标方法原实现的调用
如图：
 
核心代码如下：
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
        class_addMethod(curClass, NSSelectorFromString(@"alias_forwardInvocation:"), oriFowardIMP, "v@:@");//保存原来的实现
      }
    }
    //2.替换目标方法的实现为 _objc_msgForward, 从而能触发消息转发
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


2.添加方法

以上是对目标方法热修复做的准备工作，接下来我们看下目标方法被实际调用后，具体是怎样运行的吧！

3.4 方法实际调用过程
	当程序运行中，真正调用到目标方法时，经过我们上述对其实现的替换，那么它的主要流程将是这样的：
1. 程序调用对象的目标方法
2. 找到目标方法的实现，由于实现已经被替换成 _objc_msgForward 指针，故走到消息转发流程
3. 来到消息转发的 forwardInvocation 方法中，由于该方法的实现被替换成自定义的实现
4. 来到自定义的 forwardInvocation 方法实现中，在这里，可调用在准备工作中保存下来的 JS 脚本
5. 以及根据需要决定是否用目标方法的原始实现（前、后插入），如果不调用原实现，就相当于方法实现的完全替换操作

如图：
 

自定义的 -forwardInvocation 方法代码如下：static void swizzle_forwardInvocation(__unsafe_unretained NSObject *target, SEL selector, NSInvocation *invocation){
  
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

4.使用
4.1 框架初始化
可以在应用启动阶段对框架进行初始化，以及对 JS 脚本的加载和执行。
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
  //1.初始化框架
  [JSFix initFix];
  //2.加载 js 脚本
  NSString *path = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"js"];
  NSString *jsString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  [JSFix evaluateJSString:jsString];
  
  return YES;
}

4.2 如何写JS 脚本
JS 脚本中是如何写修复的代码呢，下面通过对文章开头的例子中的代码进行一下解析。
test.js 脚本中的代码：
//调用热修方法
RestoreMethod('ViewController','testMethod',0,1,function(instance,invocation,arg){
	//JS实现
  runInvocation_dispatch_async_main(function(){
    var self = instance;
    var view = runInstanceMethod(self,'view')
    var redColor = runClassMethod('UIColor','redColor')
    runInstanceMethod(view,'setBackgroundColor:',redColor)
  })
})
其中：
1. 调用 RestoreMethod 方法，其参数：用于指定修复ViewController 类的 testMethod 方法，0 表示实例方法，1 表示方法替换（而非插入，0 前插入，1 替换，2 后插入），最后的参数就是 JS 的代码实现。
2. 实现中的 runInvocation_dispatch_async_main 表示在 Native 中 GCD 方法的 dispatch_async_main 的回调中执行。
3. 回调中的参数 instance 就相当于 Native 方法中使用的 self 实例
4. 回调中用到的 runInstanceMethod 方法，表示调用实例方法，如：调用 self 实例的 view 方法，等价于 Native 方法中 self.view 语句（getter 方法），其他调用原理类似。

5.注意事项
1. 在 JS 调用 OC 的方法时候， 方法字符串中不能出现空格。
2. 注意方法的大小写等，建议copy方法名，否则很容易出错，不易排查。

Demo 源码

后记
由于水平有限，如有不对之处，欢迎大家批评指正。

参考:
JavaScriptCore框架详解
https://zhuanlan.zhihu.com/p/150596680
消息机制 https://juejin.cn/post/6844903600968171533
Aspect https://github.com/steipete/Aspects
JSPatch实现原理详解  http://blog.cnbang.net/tech/2855/



