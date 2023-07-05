fixMethod('Test', 'instanceMethodCrash:', 1,
          function(instance, originInvocation, originArguments) {
          if (originArguments[0] == null) {
          runError('Test', 'instanceMethodCrash');
          } else {
          runInvocation(originInvocation);
          }
          });
