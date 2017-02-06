/*!
 *  @file UIView+TimelineAnimation.h
 *  @brief BlackJack
 *
 *  Created by @author Georges Boumis
 *  @date 24/08/2016.
 *  @copyright   Copyright © 2016 AbZorba Games. All rights reserved.
 */

@import UIKit;

@class TimelineAnimation;

/*!
 *  @public
 *  @category UIView_TimelineAnimation
 *  @brief A class.
 *  @details Some details.
 *  @related UIView
 */
@interface CALayer (TimelineAnimation)
@property (nonatomic, weak) __kindof TimelineAnimation * __nullable timelineAnimation;
@end
