//
//  SNNavViewController.m
//  SlidingNavigation
//
//  Created by Mofang on 14-2-10.
//  Copyright (c) 2014年 yaonphy. All rights reserved.
//

#import "SNNavViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
static const CGFloat kAnimationDuration = 0.5f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.8f;

typedef enum
{
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
} PanDirection;
@interface SNNavViewController ()<UIGestureRecognizerDelegate>
{
    NSMutableArray * _gestures;
    UIView * _blackMask;
    CGPoint _panOrigin;
    BOOL _animationInProgress;
    CGFloat _percentageOffsetFromLeft;
}
-(void) addPanGestureToView:(UIView *) view;
-(void) rollBackViewController;

-(UIViewController *)currentViewConntroller;
-(UIViewController *)previousViewController;

-(void)transformAtPercentage:(CGFloat) percentage;
-(void)completeSlidingAnimationWithDirection:(PanDirection) direction;
-(void)completeSlidingAnimationWithOffset:(CGFloat) offset;
-(CGRect)getSlidingRectWithPercentageOffset:(CGFloat) percentage orientation:(UIInterfaceOrientation) orientation;
-(CGRect)viewBoundsWithOrientation:(UIInterfaceOrientation) orientation;

@end

@implementation SNNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}
-(instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super init]) {
        self.viewControllers = [NSMutableArray arrayWithObject:rootViewController];
    }
    
    return self;
}
#pragma mark -- Load View
-(void)loadView
{
    [super loadView];
    
    CGRect viewRect = [self viewBoundsWithOrientation:self.interfaceOrientation];
    UIViewController * rootViewController = self.viewControllers[0];
    [rootViewController willMoveToParentViewController:self];
    [self addChildViewController:rootViewController];
    
    UIView * rootView = rootViewController.view;
    rootView.frame = viewRect;
    [self.view addSubview:rootView];
    [rootViewController didMoveToParentViewController:self];
    
    _blackMask = [[UIView alloc]initWithFrame:viewRect];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0f;
    [self.view insertSubview:_blackMask atIndex:0];
}
#pragma mark -- end

#pragma mark --Push View Controller with Block
-(void)pushViewController:(UIViewController *)viewController withCompletionBlock:(SlidingNavigationControllerCompletionBlock)completionHandler
{
    _animationInProgress = YES;
    viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    _blackMask.alpha = 0.0f;
    
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:viewController.view];
    
    [UIView animateWithDuration:kAnimationDuration animations:^(){
        CGAffineTransform transf = CGAffineTransformIdentity;
        [self currentViewConntroller].view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        viewController.view.frame = self.view.bounds;
        _blackMask.alpha = kMaxBlackMaskAlpha;
        
    } completion:^(BOOL finish){
        if (finish) {
            [self.viewControllers addObject:viewController];
            [viewController didMoveToParentViewController:self];
            _animationInProgress = NO;
            _gestures = [[NSMutableArray alloc]init];
            [self addPanGestureToView:[self currentViewConntroller].view];
            completionHandler();
        }
    }];
    
}
-(void)pushViewController:(UIViewController *)viewController
{
    NSLog(@"--------\n");

    [self pushViewController:viewController withCompletionBlock:^{}];
}
#pragma mark -- end

#pragma mark -- Pop View Controller with Block
-(void)popViewControllerWithCompletionBlock:(SlidingNavigationControllerCompletionBlock)completionHandler
{
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController * currentViewCtr = [self currentViewConntroller];
    UIViewController * previousViewCtr = [self previousViewController];
    [previousViewCtr viewWillAppear:NO];
    
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^(){
    
        currentViewCtr.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousViewCtr.view.transform = CGAffineTransformScale(transf, 1.0f, 1.0f);
        previousViewCtr.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0f;
    } completion:^(BOOL finish){
        if (finish) {
            [currentViewCtr.view removeFromSuperview];
            [currentViewCtr willMoveToParentViewController:Nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentViewCtr removeFromParentViewController];
            [currentViewCtr didMoveToParentViewController:Nil];
            _animationInProgress = NO;
            [previousViewCtr viewDidAppear:NO];
            completionHandler();
        }
    }];
}
-(void)popViewController
{
    [self popViewControllerWithCompletionBlock:^{}];
}
#pragma mark -- end

#pragma mark -- Roll Back 
-(void)rollBackViewController
{
    UIViewController * vc = [self currentViewConntroller];
    UIViewController * nvc = [self previousViewController];
    
    CGRect rect = CGRectMake(0.0f,0.0f, vc.view.frame.size.width, vc.view.frame.size.height);
    
    [UIView animateWithDuration:0.3f delay:kAnimationDelay options:0 animations:^(void){
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        vc.view.frame = rect;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    } completion:^(BOOL finish){
        if (finish) {
            _animationInProgress = NO;
        }
    }];
}

#pragma mark -- end


#pragma mark -- Autorotate Delegate

#pragma mark -- end

#pragma mark -- Current ViewController
-(UIViewController *) currentViewConntroller
{
    UIViewController * result = Nil;
    if (self.viewControllers.count > 0) {
        result = [self.viewControllers lastObject];
    }
    
    return result;
}
#pragma mark -- end

#pragma mark -- Previous View Controller
-(UIViewController *)previousViewController
{
    UIViewController * result = Nil;
    if (self.viewControllers.count > 1) {
        result = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    
    return  result;
}
#pragma mark -- end
#pragma mark -- add Pan Gesture
-(void)addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [_gestures addObject:panGesture];
}

#pragma mark -- end

#pragma mark -- Avoid Unwanted Vertical Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    return fabs(translation.x) > fabs(translation.y) ;
}
#pragma mark -- end

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIViewController * vc =  [self.viewControllers lastObject];
    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
#pragma mark -- end

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(_animationInProgress) return;
    
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGesture velocityInView:self.view];
    
    if (vel.x > 0) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    CGFloat offset = 0;
    
    UIViewController * vc ;
    vc = [self currentViewConntroller];
    offset = CGRectGetWidth(vc.view.frame) - x;
    
    _percentageOffsetFromLeft = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    vc.view.frame = [self getSlidingRectWithPercentageOffset:_percentageOffsetFromLeft orientation:self.interfaceOrientation];
    [self transformAtPercentage:_percentageOffsetFromLeft];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        // If velocity is greater than 100 the Execute the Completion base on pan direction
        if(abs(vel.x) > 100) {
            [self completeSlidingAnimationWithDirection:panDirection];
        }else {
            [self completeSlidingAnimationWithOffset:offset];
        }
    }
}
#pragma mark -- end

#pragma mark - Set the required transformation based on percentage
- (void) transformAtPercentage:(CGFloat)percentage {
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    [self previousViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
}

#pragma mark - This will complete the animation base on pan direction
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - This will complete the animation base on offset
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset{
    
    if(offset<[self viewBoundsWithOrientation:self.interfaceOrientation].size.width/2) {
        [self popViewController];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - Get the origin and size of the visible viewcontrollers(child)
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation {
    CGRect viewRect = [self viewBoundsWithOrientation:orientation];
    CGRect rectToReturn = CGRectZero;
    UIViewController * vc;
    vc = [self currentViewConntroller];
    rectToReturn.size = viewRect.size;
    rectToReturn.origin = CGPointMake(MAX(0,(1-percentage)*viewRect.size.width), 0.0);
    return rectToReturn;
}

#pragma mark - Get the size of view in the main screen
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation{
	CGRect bounds = [UIScreen mainScreen].bounds;
    if([[UIApplication sharedApplication]isStatusBarHidden]){
        return bounds;
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height = width - 20;
        }else {
            bounds.size.height = width;
        }
        return bounds;
	}else{
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height-=20;
        }
        return bounds;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


#pragma mark - UIViewController Category
//For Global Access of flipViewController
@implementation UIViewController (SNNavViewController)
@dynamic slidingNavController;

- (SNNavViewController *) slidingNavController
{
    
    if([self.parentViewController isKindOfClass:[SNNavViewController class]]){
        return (SNNavViewController*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[SNNavViewController class]]){
        return (SNNavViewController*)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
    
}


@end
