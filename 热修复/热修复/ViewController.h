//
//  ViewController.h
//  热修复
//
//  Created by xueshan1 on 2018/9/12.
//  Copyright © 2018年 xueshan1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(nonatomic,strong)UITableView *tableView;

- (void)testblockParameter:(void(^)(void))block;

@end

