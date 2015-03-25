//
//  DTAlertAction.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DTAlertActionStyle) {
    DTAlertActionStyleDefault = 0,
    DTAlertActionStyleCancel,
    DTAlertActionStyleDestructive
} NS_ENUM_AVAILABLE_IOS(8_0);

@class DTAlertController, DTAlertAction;

typedef void (^DTAlertActionHandler) (DTAlertController *alertController, DTAlertAction *action);

NS_CLASS_AVAILABLE_IOS(8_0) @interface DTAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(DTAlertActionStyle)style handler:(DTAlertActionHandler)handler;

// Button's title.
@property (nonatomic, readonly) NSString *title;

// Button's
@property (nonatomic, readonly) DTAlertActionStyle style;

/** Tint color will ignore when style is DTAlertActionStyleDestructive.
 *
 * @brief Button's title color, you can set different tint color for each button.
 *
 * @param tintColor The button tint color, default is key window's tint color.
 */
@property (retain, nonatomic) UIColor *tintColor;
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

@end
