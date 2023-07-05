fixMethod('Test','runWithParams:',1,function(instance,invocation,arg){
          var array = new Array('123');
          var arr = new Array(array);
          setInvocationArguments(invocation,arr);
          runInvocation(invocation);
          });
