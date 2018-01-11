//
//  ViewController.m
//  AR--太阳系
//
//  Created by gz on 2018/1/10.
//  Copyright © 2018年 gz. All rights reserved.
//

#import "ViewController.h"
#import "ARSceneViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickBtn:(UIButton *)sender {
    ARSceneViewController *arSceneVC = [[ARSceneViewController alloc] init];
    [self presentViewController:arSceneVC animated:YES completion:nil];
}

@end
