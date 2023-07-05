
// JSPatch实现原理详解
// http://blog.cnbang.net/tech/2808/
//

/*
 原理:
 1.替换原方法的实现, 通过 _objc_msgForward, 从而触发消息转发机制
 2.替换消息转发中的 -forwardInvocation 方法实现, 在这个方法中调用新的实现(js实现)
 3.具体细节:
    3-1.将所需要修复的方法, 转换成 FixObject 关联到对应的Class上, key是对应方法的selector
    3-2.在-forwardInvocation中取出selector对应的FixObject,并执行新实现
    3-3.在-forwardInvocation中可以拿到原方法 invocation, 可以根据需要调用
       (注意: 步骤1 已经替换了原方法实现,此时,应该是新的selector),若调用, 则新的实现是'插入';若不调用,则新实现就是'替换'

 4.注意:
 4-1方法字符串中不能出现空格
 4-2方法的大小写
 4-3建议copy方法名字,否则很容易出错的
 

 
 5.将js 方法---传到--> oc方法中
 例子:
 - (void)runwithValue:(NSString *)jsValueString{
 JSContext *context = [JSFix context];
 [context evaluateScript:jsValueString];
 
 JSValue *value =  context[@"hello"];
 [value callWithArguments:nil];
 
 }
 
 
 待解决:
 1. 区分类方法 & 实例方法------已支持,通过object_getClass(self)获取到类对象
 2.(已解决)前插入,替换, 后插入(需要将原来的实现imp保存下来)
 
 3. UIAlertView 参数个数错误问题
 
 4.js调用的 OC方法的参数是block 怎么办? 如UIAlertAction
    即,NSInvocation 的参数是block
 
 5. (已解决)替换有返回值的方法, 返回另一个值 如:cell的高度  如何替换 -tableView:heightForRowAtIndexPath:

 */


