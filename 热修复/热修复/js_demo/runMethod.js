
FixMethod('ViewController','viewDidLoad',1,function(instance,invocation,arg){
              var view = runClassMethod('UIView','new');
              runInstanceMethod(view,'setFrame:',new Array('{{100, 100}, {100, 100}}'));
              var color = runClassMethod('UIColor','redColor');
              runInstanceMethod(view,'setBackgroundColor:',new Array(color));
              var bgView = runInstanceMethod(instance,'view');
              runInstanceMethod(bgView,'addSubview:',new Array(view));
              
              });

FixMethod('ViewController','replacedMethod',2,function(instance,invocation,arg){
              var alert = runClassMethod('UIAlertView','alloc');
              var delegate = runClassMethod('ViewController','new');
              var alertV = runInstanceMethod(alert,'initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:,nil',new Array('title','message',delegate,'replacedMethod_Sure','replacedMethod_Sure'));
              runInstanceMethod(alertV,'show');
              
              });


FixMethod('ViewController','replace_instanceMethod',1,function(instance,invocation,arg){
              
              runLog(instance + 'hello');
              });
