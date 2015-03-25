//
//  DTAnimatedTransitioning.m
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

#import "DTAnimatedTransitioning.h"

typedef dispatch_block_t UIViewAnimateAnimationsBlock;
typedef void (^UIViewAnimateCompletionBlock) (BOOL finished);

@interface DTAnimatedTransitioning ()
{
    NSTimeInterval _duration;
}

@end

@implementation DTAnimatedTransitioning

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
{
    DTAnimatedTransitioning *amimatedTransitioning = [[DTAnimatedTransitioning alloc] initWithDuration:duration];
    
    return [amimatedTransitioning autorelease];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration
{
    self = [super init];
    if (self == nil) return nil;
    
    _duration = duration;
    
    [self setPresent:NO];
    
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *currentView = [transitionContext containerView];
    UIViewController *toViewComtroller = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewComtroller = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (self.present) {
        
        [currentView addSubview:toViewComtroller.view];
        [currentView bringSubviewToFront:toViewComtroller.view];
        
        [toViewComtroller.view setFrame:screenRect];
        [toViewComtroller.view setAlpha:0.0f];
        
        UIViewAnimateAnimationsBlock animations = ^{
            [toViewComtroller.view setAlpha:1.0f];
        };
        
        UIViewAnimateCompletionBlock completion = ^(BOOL finished) {
            [transitionContext completeTransition:YES];
        };
        
        [UIView animateWithDuration:_duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
        
        return;
    }
    
    [currentView addSubview:fromViewComtroller.view];
    [currentView bringSubviewToFront:fromViewComtroller.view];
    
    [fromViewComtroller.view setAlpha:1.0f];
    
    UIViewAnimateAnimationsBlock animations = ^{
        [fromViewComtroller.view setAlpha:0.0f];
    };
    
    UIViewAnimateCompletionBlock completion = ^(BOOL finished) {
        [fromViewComtroller.view removeFromSuperview];
        [transitionContext completeTransition:YES];
        
//        [toViewComtroller setNeedsStatusBarAppearanceUpdate];
    };
    
    [UIView animateWithDuration:_duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
}

@end
