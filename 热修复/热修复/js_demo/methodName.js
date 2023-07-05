
 
var obj;
var weakObj = getWeakObj(obj)
var strongObj = getStrongObj(weakObj)
var _memberVariable = runInstanceMethod(obj,'is_objectValueForKeyPath:','_memberVariable')  //kvc

var cls = GetClass(obj)
var clss = GetClassFromString('Model')
var point = GetCGPoint(0,0)
var size = GetCGSize(0,0)
var rect = GetCGRect(0,0,0,0)
var range = GetNSRange(0,1)
var inset = GetUIEdgeInsets(0,0,0,0)

//MARK: 简介
//1.改变参数
//2.改变返回值
//3.添加button, 响应方法
//4.给类 添加方法
//5. alert 弹框, 传递js作为 block
//6.GCD 相关
//7. super调用父类方法
//8. js调用block参数的函数

//1.改变参数
RestoreMethod("ViewController", "changePrames:", 0, 1, function(instance, invocation, arg) {
    var params = new Array();
    params[0] = 'newParams新参数'
    setInvocationArguments(invocation,params);
    });

 //2.改变返回值
RestoreMethod('ViewController','tableView:heightForRowAtIndexPath:',0 ,1 ,function(instance,invocation,arg){
    runInvocation(invocation);//要先调用原来实现
    runInvocationReturnValue(invocation,120);  //最后,设置返回值 (注意调用顺序)
    });


//3.添加button, 响应方法
//方式一
//3.1
RestoreMethod('ViewController','viewDidLoad',0, 2,function(instance,invocation,arg){
          var self = instance;
          var view = runInstanceMethod(self,'view')
          var color = HexColor('#508CEE')
          runInstanceMethod(view,'setBackgroundColor:',color)
          
          var color1 = runClassMethod('UIColor','redColor')
          var btn = runClassMethod('UIButton','new')
          runInstanceMethod(btn,'setFrameX:y:width:height:',new Array(0,200,300,80))
          runInstanceMethod(btn,'setBackgroundColor:',color1)
          runInstanceMethod(view,'addSubview:',btn)
          runInstanceMethod(btn,'setTitle:forState:',new Array('i am btn',0))
          runInstanceMethod(btn,'setTitleColor:forState:',color)
           //1.add方法,使用NSObject 中预置的方法  然后2
          runInstanceMethod(btn,'addTouchupInsideSelector:target:',new Array('fixMethod',instance))
          
          })
//3.2用新实现 替换添加的预置方法
RestoreMethod('ViewController','fixMethod',0, 1,function(instance,invocation,arg){
            runLog('哈哈哈')
          
          })

//方式二: 优化了selector
RestoreMethod('ViewController','viewDidLoad',0,2,function(instance,invocation,arg){
             var self = instance;
            
               var view = runInstanceMethod(self,'view')
               var btn = runClassMethod('UIButton','buttonWithFrame:title:superV:',[GetCGRect(0,100,150,80),'嘿嘿',view])
               addMethodToClass('ViewController','btnclicked','fixMethod')
               runInstanceMethod(btn,'addTarget:action:forControlEvents:',[self,'btnclicked',1 << 6])
               RestoreMethod('ViewController','btnclicked',0,2,function(instance,invocation,arg){
                   runLog('车里乘客 btn')

               })


         })



//4.给类 添加方法
//4.1.给某类 新添加方法(不存在的), 使用NSObject内置的fixMethod的方法实现
addMethodToClass('ViewController','scrollViewDidScroll:','fixMethod:');

//4.2.替换新添加方法的实现(新增实现)
FixMethod('ViewController','scrollViewDidScroll:',2,function(instance,invocation,arg){
          //          var offsetY = runInstanceMethod(arg[0],'valueForKeyPath:','contentOffset')  //valueForKeyPath: 返回的是id
         var offset = runInstanceMethod(arg[0],'contentOffset') ; //注意 arg是数组类型,arg[0] 需要去第一个
          // var point = GetCGPoint(offsetY);
          runLog(offset.y);
          
          })



//5. alert 弹框, 传递js作为 block
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
 
 //6.GCD 相关
RestoreMethod('ViewController','viewDidLoad',0,2,function(instance,invocation,arg){
          var self = instance;
          var view = runInstanceMethod(self,'view')
          var color = HexColor('#508CEE')
          runInstanceMethod(view,'setBackgroundColor:',color)
          
          runInvocation_dispatch_after(2,function(){
                                       var color1 = runClassMethod('UIColor','redColor')
                                       var btn = runClassMethod('UIButton','new')
                                       runInstanceMethod(btn,'setFrameX:y:width:height:',new Array(0,200,300,80))
                                       runInstanceMethod(btn,'setBackgroundColor:',color1)
                                       runInstanceMethod(view,'addSubview:',btn)
                                        
                                       })
          
          runInvocation_dispatch_async_main(function(){
                                            var color1 = runClassMethod('UIColor','redColor')
                                            var btn = runClassMethod('UIButton','new')
                                            runInstanceMethod(btn,'setFrameX:y:width:height:',new Array(0,300,300,80))
                                            runInstanceMethod(btn,'setBackgroundColor:',color1)
                                            runInstanceMethod(view,'addSubview:',btn)
                                            
                                            })
          
          
          runInvocation_UIView_animation(1.0,0,0,function(){
                                         runInstanceMethod(view,'setWidth:',100);
                                         },function(){
                                         
                                         })
          
          
          })

//7. super调用父类方法
RestoreMethod('TestModelSubclass','testModelsubclassMethod',1,2,function(instance,invocation,arg){
             var self = instance;
 			
 			 runInvocation_sendSuper(self,'testModelMethod',[])             
              
          })
 
//8. js调用block参数的函数
//testblck
var cancelFunction = function (a,b){
    runLog(a);
    runLog(b);
    runLog('i am cancelFunction');
}
 

RestoreMethod('ViewController','viewDidLoad',0,2,function(instance,invocation,arg){
              var self = instance;
 
              var obj = genCallbackBlock(cancelFunction,[1,0]) //1 代表是对象, 

              runLog(obj);
              
              runInstanceMethod(self,'testblockParameter_2:',[obj])
          })
 

//MARK: ......以上......
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
RestoreMethod('ViewController','viewDidLoad',0,2,function(instance,invocation,arg){
              var self = instance;
  				
  				var tb = runInstanceMethod(self,'tableView')
  				runInstanceMethod(tb,'setXs_height:',[1])
              runLog(tb)
              runLog(runInstanceMethod(tb,'isHidden'))

  				var view = runInstanceMethod(self,'view')
                var btn = runClassMethod('UIButton','buttonWithFrame:title:superV:',[GetCGRect(0,100,150,80),'嘿嘿',view])
 			
                addMethodToClass('ViewController','btnclicked','fixMethod')
                runInstanceMethod(btn,'addTarget:action:forControlEvents:',[self,'btnclicked',1 <<  6])
                RestoreMethod('ViewController','btnclicked',0,2,function(instance,invocation,arg){
                	runLog('车里乘客 btn')

                })

 				

          })

 
              
        

























































