//!!!
//弹框,有问题  如何传block
//参考 https://segmentfault.com/a/1190000004141249

//var actBlock = function(action){
//    runLog('abc');
//}
//FixMethod('ViewController','replacedMethod',1,function(instance,invocation,arg){
//
//              var alertC = runClassMethod('UIAlertController','alertControllerWithTitle:message:preferredStyle:',new Array('titleeeeeee','messsssage',1));
//              var action = runClassMethod('UIAlertAction','actionWithTitle:style:handler:',new Array('Cancle',1));
//              var action1 = runClassMethod('UIAlertAction','actionWithTitle:style:handler:',new Array('Sure',2,actBlock));
//
//              runInstanceMethod(alertC,'addAction:',[action1]);
//              runInstanceMethod(alertC,'addAction:',[action]);
//
//              var app = runClassMethod('UIApplication','sharedApplication');
//              var keyw = runInstanceMethod(app,'keyWindow');
//              var rootC = runInstanceMethod(keyw,'rootViewController');
//              runInstanceMethod(rootC,'presentViewController:animated:completion:',new Array(alertC,true));
//
//              });




var cancelFunction = function Function_Name_UIAlertView_cancelAction(){
    runLog('i am cancel');
}

var sureFunction = function Function_Name_UIAlertView_sureAction(){
    runLog('i am sure');
    
    var vc = runClassMethod('UIViewController','new')
    var view = runInstanceMethod(vc,'view')
    var green = runClassMethod('UIColor','greenColor');
    runInstanceMethod(view,'setBackgroundColor:',[green]);
    runInstanceMethod(vc,'setModalPresentationStyle:',[0])
    
    var  app = runClassMethod('UIApplication','sharedApplication')
    var delegate = runInstanceMethod(app,'delegate')
    var window = runInstanceMethod(delegate,'window')
    var rootViewController = runInstanceMethod(window,'rootViewController')
    runInstanceMethod(rootViewController,'presentViewController:animated:completion:',[vc,true])
    
}

RestoreMethod('ViewController','replacedMethod',0,2,function(instance,invocation,arg){
              var self = instance;
              var cancelActionjs = toOCString(cancelFunction)
              var sureActionjs   = toOCString(sureFunction)
              runClassMethod('UIAlertView','showWithTitle:message:cancleTitle:sureTitle:cancelJsScript:sureJsScript:',['i am title','i am message','cancel','sure',cancelActionjs,sureActionjs])
              
 
          })
 
