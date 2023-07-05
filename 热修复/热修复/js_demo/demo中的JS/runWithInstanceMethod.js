var self;
fixMethod('ViewController','viewDidLoad',1,function(instance,invocation,arg){
          var co = new Array(Math.random(),Math.random(),Math.random(),Math.random());
          var color = runMethod('UIColor','colorWithRed:green:blue:alpha:',co);
          var view = runInstanceMethod(instance,'view');
          self = instance;
          var view = runInstanceMethod(self,'view');
          runInstanceMethod(view,'setBackgroundColor:',new Array(color));
          var dataSource = new Array('instanceMethodCrash','calssMethodCrash','runBeforeClassMethod','runBeforeInstanceMethod','runAfterInstanceMethod','runAfterClassMethod','runInsteadClassMethod','runInsteadInstanceMethod','changePrames','changeReturnValue');
         var datas = runInstanceMethod(dataSource,'mutableCopy');
      

          for (var i = 0;i < dataSource.length;i ++) {
          var budle = runMethod('NSBundle','mainBundle');
          var jsPath = runInstanceMethod(budle,'pathForResource:ofType:',new Array(dataSource[i],'js'));
          var jsString = runMethod('NSString','stringWithContentsOfFile:encoding:error:',new Array(jsPath,'4'));
          runMethod('LYFix','evalString:',jsString);
          runLog(jsString);
          }
     datas.push('runClassMethod','runInstanceMethod','runWithInstanceMethod','runWithParams');
          runInstanceMethod(self,'setDataSource:',new Array(datas));
          var selfDataSource = runInstanceMethod(self,'dataSource');
          runLog(datas);
          runLog(selfDataSource);
          var tableView = runMethod('UITableView','alloc');
          var bounds = runInstanceMethod(view,'bounds');
        
          runInstanceMethod(tableView,'initWithFrame:style:',new Array(bounds,'0'));
          runInstanceMethod(tableView,'setDataSource:',self);
          runInstanceMethod(tableView,'setDelegate:',self);
          runInstanceMethod(tableView,'setFrame:',bounds);
          runInstanceMethod(view,'addSubview:',tableView);
          });


fixMethod('ViewController','tableView:didSelectRowAtIndexPath:',0,function(instance,invocation,arg){
          //          runError(self, 'calssMethodCrash');
          var co = new Array(Math.random(),Math.random(),Math.random(),Math.random());
          var color = runMethod('UIColor','colorWithRed:green:blue:alpha:',co);
          var view = runInstanceMethod(instance,'view');
          //          runError(view, 'viewaaa');
          var label = runMethod('UILabel','new');
//          var fra = runInstanceMethod(view,'frame');
          runInstanceMethod(label,'setFrame:',new Array('{{100, 100}, {100, 100}}'));
//          runInstanceMethod(label,'setFrame:',fra);
          runInstanceMethod(label,'setText:','test');
          runInstanceMethod(view,'addSubview:',label);
          runInstanceMethod(label,'setBackgroundColor:',new Array(color));
          
          
          runInstanceMethod(view,'setBackgroundColor:',new Array(color));
          });

