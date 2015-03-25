//
//  DTAlertController.h
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "DTAlertAction.h"
#import "DTProgressStatus.h"

/** The mode of display to user. */
typedef NS_ENUM(NSInteger, DTAlertControllerStyle) {
    /** Normal alert view, it's dafult mode. */
    DTAlertControllerStyleNormal = 0,
    
    /** Alert view with UITextField. */
    DTAlertViewModeTextInput,
    
    /** Alert view with Single UIProgressView. */
    DTAlertControllerStyleProgress,
    
    /** Alert view with Two UIProgressView. */
    DTAlertControllerStyleDuoProgress,
};

NS_CLASS_AVAILABLE_IOS(8_0) @interface DTAlertController : UIViewController

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;

@property (readonly) NSArray *actions;

/// @brief Default is YES.
@property (assign, nonatomic, getter = isEnableTapBackgroundDismiss) BOOL enableTapBackgroundDismiss;

/* Background Settings */

/// @brief Default is YES.
@property (assign, nonatomic, getter = isUsingBlurBackground) BOOL useBlurBackground;
@property (assign, nonatomic) UIBlurEffectStyle blurStyle;

/** Default is black with 40% alpha.
 *
 * @brief When useBlurBackground is true, will ignore backgroundColor setting.
 */
@property (retain, nonatomic) UIColor *backgroundColor;

/* Progress Settings */

/** Default is blue (aka. iOS 7 default blue color).<br/>
 * Only can be set it when DTAlertViewMode is DTAlertViewModeProgress and DTAlertViewModeDuoProgress.
 *
 * @brief Set all of UIProgressView progress bar tint color.
 */
@property (nonatomic, retain) UIColor *progressBarColor;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(DTAlertControllerStyle)preferredMode;
- (void)addAction:(DTAlertAction *)action;

/** @brief Adjust the current progress status at DTAlertViewModeDuoProgress mode,<br/>
 * first (top) progress view's progress will adjust by this receiver at DTAlertViewModeDuoProgress mode.
 *
 * @param status The current status of the receiver.
 */
- (void)setProgressStatus:(DTProgressStatus)status;

/** @brief Adjust the current percentage at DTAlertViewModeNormal and DTAlertViewModeDuoProgress mode.<br/>
 * Percentage show under porgress view at DTAlertViewModeNormal or under second (bottom) progress view at DTAlertViewModeDuoProgress.<br/>
 * Progress view's (upper this percentage) progress will adjust by this receiver.
 *
 * @param percentage This value represented a floating-point value between 0.0 and 1.0, inclusive,<br/>
 * where 1.0 indicates the completion of the task. The default value is 0.0.<br/>
 * Values less than 0.0 and greater than 1.0 are pinned to those limits.
 */
- (void)setPercentage:(CGFloat)percentage;

/// @brief The shake animation, appearance like password error animation on OS X.
- (void)shakeAlertView;

@end
