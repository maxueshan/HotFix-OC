//改变参数
//调用者传入的参数,将失效,不在起作用
// 什么时候改变的??
//注意:                                       这里是0, 说明在执行原来实现的时候,改变了传进来的参数值了
FixMethod("ViewController", "changePrames:", 0, function(instance, invocation, arg) {
    var params = new Array();
    params[0] = 'newParams新参数'
    setInvocationArguments(invocation,params);
    });







