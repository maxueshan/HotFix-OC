

FixMethod('ViewController','viewDidLoad',2,function(instance,invocation,arg){
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
//2.用新实现 替换添加的预置方法
FixMethod('ViewController','fixMethod',1,function(instance,invocation,arg){
            runLog('哈哈哈')
          
          })
