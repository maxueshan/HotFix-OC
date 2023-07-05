fixMethod('Test', 'calssMethodCrash:', 1,
          function(className, originInvocation, originArguments) {
          if (originArguments[0] == null) {
          runError('Test', 'calssMethodCrash');
          } else {
          runInvocation(originInvocation);
          }
          });
