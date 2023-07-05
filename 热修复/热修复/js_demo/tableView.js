//创建tableView
FixMethod('ViewController','viewDidLoad',1,function(instance,invocation,arg){
              var table = runClassMethod('UITableView','alloc');
              runInstanceMethod(table,'initWithFrame:style:',['{{0,0}, {300,600}}',1]);
              var red = runClassMethod('UIColor','redColor');
              runInstanceMethod(table,'setBackgroundColor:',[red]);
              var view = runInstanceMethod(instance,'view');
              runInstanceMethod(view,'addSubview:',[table]);
              
              runInstanceMethod(table,'setDelegate:',[instance]);
              runInstanceMethod(table,'setDataSource:',[instance]);
              
              var array = ['one','two','three'];
              runInstanceMethod(instance,'setDataArray:',[array]);
              runInstanceMethod(table,'reloadData');
              
              });
