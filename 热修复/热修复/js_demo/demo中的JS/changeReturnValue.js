fixMethod("Test", "changeReturnValue:", 1, function(instance, invocation, arg) {
          runInvocation(invocation);
          setInvocationReturnValue(invocation,'new returnValue');
          });
