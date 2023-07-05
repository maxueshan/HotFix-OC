
FixMethod('ViewController','viewDidLoad',2,function(instance,invocation,arg){
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


