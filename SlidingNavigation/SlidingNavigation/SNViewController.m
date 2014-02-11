//
//  SNViewController.m
//  SlidingNavigation
//
//  Created by Mofang on 14-2-10.
//  Copyright (c) 2014年 yaonphy. All rights reserved.
//

#import "SNViewController.h"
#import "SNPushedViewController.h"
#import "SNNavViewController.h"
@interface SNViewController ()

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor orangeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pushButtonTouched:(UIButton *)sender {
    NSLog(@"-----%p---\n",self.slidingNavController);
    SNPushedViewController * pushViewCtr = [self.storyboard instantiateViewControllerWithIdentifier:@"SNPUSHEDVC"];
    [self.slidingNavController pushViewController:pushViewCtr];
}

@end
