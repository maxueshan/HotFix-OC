
var actBlock = function(action){
    runLog('abc');
}
FixMethod('ViewController','replacedMethod',1,function(instance,invocation,arg){
              
              var alertC = runClassMethod('UIAlertController','alertControllerWithTitle:message:preferredStyle:',new Array('titleeeeeee','messsssage',1));
              var action = runClassMethod('UIAlertAction','actionWithTitle:style:handler:',new Array('Cancle',1));
              var action1 = runClassMethod('UIAlertAction','actionWithTitle:style:handler:',new Array('Sure',2,actBlock));
              
              runInstanceMethod(alertC,'addAction:',[action1]);
              runInstanceMethod(alertC,'addAction:',[action]);
              
              
              var app = runClassMethod('UIApplication','sharedApplication');
              var keyw = runInstanceMethod(app,'keyWindow');
              var rootC = runInstanceMethod(keyw,'rootViewController');
              runInstanceMethod(rootC,'presentViewController:animated:completion:',new Array(alertC,true));
              
              });
