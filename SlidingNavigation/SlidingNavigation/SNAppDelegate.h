//
//  SNAppDelegate.h
//  SlidingNavigation
//
//  Created by Mofang on 14-2-10.
//  Copyright (c) 2014年 yaonphy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNavViewController.h"
@interface SNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SNNavViewController * navViewCtr;
@property (strong, nonatomic) UIViewController * rootViewCtr;
@end
