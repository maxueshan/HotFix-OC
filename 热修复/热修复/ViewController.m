//
//  ViewController.m
//  热修复
//
//  Created by xueshan1 on 2018/9/12.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSFix.h"

//
#import "UIView+xsfix.h"
#import "NSInvocation+LYAddtion.h"
#import "NSInvocation+Block.h"
#import "TestModelSubclass.h"
#import "TwoViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)NSString *name;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
 
    [self testMethod];
  
}


-(void)testMethod {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.view.backgroundColor = [UIColor redColor];
  });
  
}
 


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  NSLog(@"name: %@", self.name);
 
}

- (void)addddd {
  [self.dataArray addObject:@"sdd"];

}

- (void)changePrames:(NSString *) str {
  NSLog(@"changePrames: %@", str);
  
//  if (str == nil) {
//    return;
//  }

//  [self.dataArray addObject:str];
}

- (void)testblockParameter_2:(void(^)(int a, int b))block{
    
  block(1,2);

}
- (void)testblockp1:(NSString *)str Parameter_2:(void(^)(id obj, NSString *s1, NSInteger a))block{
     
    NSLog(@"--%@",str);
    block(self, @"1111", 1314);

}

+ (void)replacedMethod{
    NSLog(@"class - replacedMethod, %d, %d",object_isClass(self),class_isMetaClass(object_getClass(self)));
}
+ (void)replacedMethodWithArgs:(NSString *)str two:(NSInteger)two{
    NSLog(@"class - replacedMethodWithArgs: %@ two:%ld",str , two);
}

- (void)replacedMethod{
    NSLog(@"instance - replacedMethod  %d",object_isClass(self));
}

+ (void)testContext{
       JSContext *context = [[JSContext alloc]init];
       context[@"runLog"] = ^(id logContent){
           NSLog(@"aaajs调用打印:%@",logContent);
       };
       context[@"GetPoint"] = ^(id logContent){
           return CGPointMake(22, 33);
       };
       
       NSString *js = @"var p = GetPoint(); runLog(p); runLog(p.x)";

       [context evaluateScript:js];
 
}
 
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 222) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
 
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    return footerView;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//}
 

@end





