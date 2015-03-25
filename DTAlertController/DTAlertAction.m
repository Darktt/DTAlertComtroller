//
//  DTAlertAction.m
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

#import "DTAlertAction.h"

@interface DTAlertAction ()
{
    DTAlertActionHandler _handler;
}

@property (retain, nonatomic) NSString *title;
@property (assign, nonatomic) DTAlertActionStyle style;

@end

@implementation DTAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(DTAlertActionStyle)style handler:(DTAlertActionHandler)handler
{
    DTAlertAction *action = [[DTAlertAction alloc] initWithTitle:title style:style handler:handler];
    
    return [action autorelease];
}

- (instancetype)initWithTitle:(NSString *)title style:(DTAlertActionStyle)style handler:(DTAlertActionHandler)handler
{
    self = [super init];
    if (self == nil) return nil;
    
    [self setTitle:title];
    [self setStyle:style];
    [self setEnabled:YES];
    
    if (handler != nil) {
        _handler = Block_copy(handler);
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [self setTintColor:keyWindow.tintColor];
    
    return self;
}

- (void)dealloc
{
    [self setTitle:nil];
    [self setTintColor:nil];
    
    if (_handler != nil) Block_release(_handler);
    
    [super dealloc];
}

#pragma mark - For Category

- (DTAlertActionHandler)handler
{
    return _handler;
}

- (UIButton *)button
{
    UIColor *buttonColor = [UIColor whiteColor];
    UIColor *textColor = self.tintColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:buttonColor];
    [button setTitle:self.title forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [button setClipsToBounds:YES];
    
    return button;
}

@end
