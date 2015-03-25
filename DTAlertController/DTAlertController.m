//
//  DTAlertController.m
//
// Copyright (c) 2015 Darktt
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "DTAlertController.h"
#import "DTAnimatedTransitioning.h"

#define DEBUG_MODE 0

NSString *const KVOTitleKeyPath = @"title";
NSString *const KVOMessageKeyPath = @"message";

// Tags
enum {
    kAlertTopViewTag = 2000,
    kTitleLableTag = 2100,
    kMessageLabelTag,
    kScrollViewTag,
};

// Message Limit Height
CGFloat const kMessageLabelLimitHight = 400.0f;

#pragma mark CGRect extension

CG_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

#pragma mark DTAlertAction Category

@interface DTAlertAction (Category)

@property (nonatomic, readonly) DTAlertActionHandler handler;

- (UIButton *)button;

@end

#pragma mark - DTAlertController

@interface DTAlertController () <UIViewControllerTransitioningDelegate>
{
    DTAlertControllerStyle _preferredMode;
    
    NSMutableArray *_actions;
    
    UIView *_alertView;
    
    NSUInteger _lastViewTag;
}

@end

@implementation DTAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(DTAlertControllerStyle)preferredMode
{
    DTAlertController *alertController = [[DTAlertController alloc] initWithTitle:title message:message preferredStyle:preferredMode];
    
    return [alertController autorelease];
}

#pragma mark Instance Method -
#pragma mark View Live Cycle

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(DTAlertControllerStyle)preferredMode
{
    self = [super init];
    if (self == nil) return nil;
    
    _actions = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self setTransitioningDelegate:self];
    
    [self setTitle:title];
    [self setMessage:message];
    [self setEnableTapBackgroundDismiss:YES];
    [self setUseBlurBackground:YES];
    [self setBlurStyle:UIBlurEffectStyleDark];
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    [self setBackgroundColor:backgroundColor];
    
    [self registerKVO];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.useBlurBackground) {
        UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:self.blurStyle];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [blurView setAutoresizingMask:autoresizingMask];
        
        [self setView:blurView];
        [blurView release];
    } else {
        [self.view setBackgroundColor:self.backgroundColor];
    }
    
    if (self.enableTapBackgroundDismiss) {
        UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        
        [self.view addGestureRecognizer:tapToDismiss];
        [tapToDismiss release];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat width = MIN(CGRectGetWidth(screenRect), CGRectGetHeight(screenRect)) - 20.0f;
    
    CGRect alertViewFrame = (CGRect) {
        .size = CGSizeMake(width, width)
    };
    
    UIMotionEffect *motionEffect = [self motionEffectWithKeyPath:@"center" relativeValue:20.0f];
    
    _alertView = [[UIView alloc] initWithFrame:alertViewFrame];
    [_alertView setBackgroundColor:[UIColor clearColor]];
    [_alertView setMotionEffects:@[motionEffect]];
    
    [self.view addSubview:_alertView];
    
    [self setupSubview];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGPoint center = CGRectGetCenter(screenRect);
    
    [_alertView setCenter:center];
    
    UIView *alertTopView = [_alertView viewWithTag:kAlertTopViewTag];
    UIView *lastView = [alertTopView viewWithTag:_lastViewTag];
    
    CGRect adjustFrame = alertTopView.frame;
    adjustFrame.size.height = CGRectGetMaxY(lastView.frame);
    
    [alertTopView setFrame:adjustFrame];
    [alertTopView setCenter:CGRectGetCenter(_alertView.bounds)];
    
    [self setCornerWithView:alertTopView byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIView *alertTopView = [_alertView viewWithTag:kAlertTopViewTag];
    
    NSLog(@"**** %@", alertTopView);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    
    if (self.blurStyle == UIBlurEffectStyleDark) {
        style = UIStatusBarStyleLightContent;
    }
    
    return style;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)modalPresentationCapturesStatusBarAppearance
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeKVO];
    
    [_alertView release];
    [_actions release];
    
    [self setTitle:nil];
    [self setMessage:nil];
    
    [self setBackgroundColor:nil];
    
    [super dealloc];
}

#pragma mark Other Method

- (void)addAction:(DTAlertAction *)action
{
    [_actions addObject:action];
}

- (void)setProgressStatus:(DTProgressStatus)status
{
    
}

- (void)setPercentage:(CGFloat)percentage
{
    
}

- (void)shakeAlertView
{
    
}

#pragma mark - Rotate View Controller

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    void (^transitionBlock) (id<UIViewControllerTransitionCoordinatorContext> context) = ^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        CGRect rect = (CGRect) {
            .size = size
        };
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGPoint center = CGRectGetCenter(rect);
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
//            center.y -= 100.0f;
        }
        
        [_alertView setCenter:center];
    };
    
    [coordinator animateAlongsideTransition:transitionBlock completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    }];
}

#pragma mark - Setup Views

- (UIMotionEffect *)motionEffectWithKeyPath:(NSString *)keyPath relativeValue:(CGFloat)relativeValue
{
    NSString *xAxisKeyPath = [NSString stringWithFormat:@"%@.x", keyPath];
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:xAxisKeyPath
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    [xAxis setMinimumRelativeValue:@(-relativeValue)];
    [xAxis setMaximumRelativeValue:@(relativeValue)];
    
    NSString *yAxisKeyPath = [NSString stringWithFormat:@"%@.y", keyPath];
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:yAxisKeyPath
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    [yAxis setMinimumRelativeValue:@(-relativeValue)];
    [yAxis setMaximumRelativeValue:@(relativeValue)];
    
    UIMotionEffectGroup *effect = [UIMotionEffectGroup new];
    [effect setMotionEffects:@[xAxis, yAxis]];
    
    [xAxis release];
    [yAxis release];
    
    return [effect autorelease];
}

- (void)setupSubview
{
    //MARK: Setup View Container
    
    CGFloat alertHeight = 250.0f;
    CGRect alertFrame = (CGRect){
        .size = CGSizeMake(250.0f, alertHeight)
    };
    
    UIView *alertTopView = [[UIView alloc] initWithFrame:alertFrame];
    [alertTopView setBackgroundColor:[UIColor whiteColor]];
    [alertTopView setTag:kAlertTopViewTag];
    
    [_alertView addSubview:alertTopView];
    
    CGRect bounds = alertTopView.bounds;
    
    //MARK: Labels
    
    // Label default value.
    CGFloat labelMaxWidth = CGRectGetWidth(alertTopView.frame) - 10.0f;
    CGRect labelDefaultRect = CGRectMake(0.0f, 0.0f, labelMaxWidth, labelMaxWidth);
    UIColor *textColor = [UIColor blackColor];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:labelDefaultRect];
    [titleLabel setText:self.title];
    [titleLabel setTextColor:textColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [titleLabel setTag:kTitleLableTag];
    
    // Set lines of title text.
    [titleLabel setNumberOfLines:0];
    
    // Set title label position and size.
    [titleLabel sizeToFit];
    
    [titleLabel setCenter:CGPointMake(CGRectGetMidX(bounds), titleLabel.center.y + 20.0f)];
    
    [alertTopView addSubview:titleLabel];
    
#if DEBUG_MODE
    
    [titleLabel setBackgroundColor:[UIColor yellowColor]];
    NSLog(@"Title Label Frame: %@", NSStringFromCGRect(titleLabel.frame));
    
#endif
    
    CGRect messageFrame = (CGRect) {
        .origin = (CGPoint) {
            .y = CGRectGetMaxY(titleLabel.frame) + 5.0f
        },
        .size = labelDefaultRect.size
    };
    
    // Message
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:messageFrame];
    [messageLabel setText:self.message];
    [messageLabel setTextColor:textColor];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [messageLabel setTag:kMessageLabelTag];
    
    // Set lines of message text.
    [messageLabel setNumberOfLines:0];
    
    // Set message label position and size.
    [messageLabel sizeToFit];
    
    CGPoint centerOfMessageLabel = (CGPoint) {
        .x = CGRectGetMidX(bounds),
        .y = CGRectGetMidY(messageLabel.frame)
    };
    
    [messageLabel setCenter:centerOfMessageLabel];
    
    _lastViewTag = kMessageLabelTag;
    
    CGFloat messageMaxYPosition = 0.0f;
    
    if (CGRectGetHeight(messageLabel.frame) > kMessageLabelLimitHight) {
        
        messageMaxYPosition = [self setupScrollViewToContainMessage:messageLabel];
        
    } else {
        
        [alertTopView addSubview:messageLabel];
        
        messageMaxYPosition = CGRectGetMaxY(messageLabel.frame);
    }
    
#if DEBUG_MODE
    
    [messageLabel setBackgroundColor:[UIColor greenColor]];
    NSLog(@"Message Label Frame: %@", NSStringFromCGRect(messageLabel.frame));
    NSLog(@"Message Max Y Positiopn: %.1f", messageMaxYPosition);
    
#endif
}

- (CGFloat)setupScrollViewToContainMessage:(UILabel *)messageLabel
{
    UIView *alertTopView = [_alertView viewWithTag:kAlertTopViewTag];
    
    // Prepare scroll view rect
    CGFloat labelWidth = CGRectGetWidth(messageLabel.frame);
    
    CGRect scrollViewRect = (CGRect) {
        .origin = messageLabel.frame.origin,
        .size = CGSizeMake(labelWidth, labelWidth),
    };
    
    // Adjust message postition to (0, 0)
    CGRect messageLabelRect = messageLabel.frame;
    messageLabelRect.origin = CGPointZero;
    
    [messageLabel setFrame:messageLabelRect];
    
    // Setup scroll view
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    [scrollView setContentSize:messageLabel.frame.size];
    [scrollView setTag:kScrollViewTag];
    
    [scrollView addSubview:messageLabel];
    
    [alertTopView addSubview:scrollView];
    
    _lastViewTag = kScrollViewTag;
    
#if DEBUG_MODE
    
    [scrollView setBackgroundColor:[UIColor magentaColor]];
    NSLog(@"Scroll View Frame: %@", NSStringFromCGRect(scrollView.frame));
    
#endif
    
    return CGRectGetMaxY(scrollView.frame);
}

- (void)setCornerWithView:(UIView *)view byRoundingCorners:(UIRectCorner)corners
{
    CGFloat cornerRedius = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRedius, cornerRedius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:path.CGPath];
    
    [view.layer setMask:maskLayer];
}

#pragma mark Default Views Setting

- (UIProgressView *)setProgressViewWithFrame:(CGRect)frame
{
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [progress setFrame:frame];
    [progress setProgressTintColor:self.view.tintColor];
    
    return [progress autorelease];
}

#pragma mark - Actions

- (void)dismiss:(UIGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Key Value Observer

- (void)registerKVO
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
    
    [self addObserver:self forKeyPath:KVOTitleKeyPath options:options context:nil];
    [self addObserver:self forKeyPath:KVOMessageKeyPath options:options context:nil];
}

- (void)removeKVO
{
    [self removeObserver:self forKeyPath:KVOTitleKeyPath];
    [self removeObserver:self forKeyPath:KVOMessageKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KVOTitleKeyPath]) {
        
    }
    
    if (![keyPath isEqualToString:KVOMessageKeyPath]) {
        return;
    }
    
    
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    DTAnimatedTransitioning *animatedTransitioning = [DTAnimatedTransitioning animateWithDuration:0.25f];
    [animatedTransitioning setPresent:YES];
    
    return animatedTransitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    DTAnimatedTransitioning *animatedTransitioning = [DTAnimatedTransitioning animateWithDuration:0.25f];
    [animatedTransitioning setPresent:NO];
    
    return animatedTransitioning;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

@end
