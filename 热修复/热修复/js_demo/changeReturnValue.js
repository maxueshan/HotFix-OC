//改变返回值
FixMethod('ViewController','tableView:heightForRowAtIndexPath:',1,function(instance,invocation,arg){
    
    runInvocation(invocation);//要先调用原来实现
    runInvocationReturnValue(invocation,120);  //最后,设置返回值 (注意调用顺序)
    
    });

