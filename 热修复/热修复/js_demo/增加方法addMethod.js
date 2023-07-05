

//1.给某类 新添加方法(不存在的), 使用NSObject内置的fixMethod的方法实现
addMethodToClass('ViewController','scrollViewDidScroll:','fixMethod:');

//2.替换新添加方法的实现(新增实现)
FixMethod('ViewController','scrollViewDidScroll:',2,function(instance,invocation,arg){
          //          var offsetY = runInstanceMethod(arg[0],'valueForKeyPath:','contentOffset')  //valueForKeyPath: 返回的是id
         var offsetY = runInstanceMethod(arg[0],'contentOffset') ; //注意 arg是数组类型,arg[0] 需要去第一个
          
          var point = NSValue_to_CGPoint(offsetY);
          runLog(point.y );
          
          })
