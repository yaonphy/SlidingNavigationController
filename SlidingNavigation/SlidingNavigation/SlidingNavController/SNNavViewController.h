//
//  SNNavViewController.h
//  SlidingNavigation
//
//  Created by Mofang on 14-2-10.
//  Copyright (c) 2014年 yaonphy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void (^SlidingNavigationControllerCompletionBlock)(void);

@interface SNNavViewController : UIViewController
@property(nonatomic,strong) NSMutableArray * viewControllers;

-(instancetype) initWithRootViewController:(UIViewController *) rootViewController;
-(void)pushViewController:(UIViewController *) viewController;
-(void)pushViewController:(UIViewController *) viewController withCompletionBlock:(SlidingNavigationControllerCompletionBlock) completionHandler;
-(void)popViewController;
-(void)popViewControllerWithCompletionBlock:(SlidingNavigationControllerCompletionBlock) completionHandler;
@end


@interface UIViewController (SNNavViewController)
@property(nonatomic,strong) SNNavViewController * slidingNavController;
@end