/*!
 *  @file CAPropertyAnimation+TimelineEntity.h
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 08/06/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

@import QuartzCore;

/*!
 *  @public
 *  @category TimelineEntity
 *  @brief A class.
 *  @details Some details.
 *  @related CAPropertyAnimation
 */
@interface CAPropertyAnimation (TimelineEntity)

@property (nonatomic, readonly, getter=isSpecial) BOOL special;
@property (nonatomic, readonly) NSTimeInterval realDuration;

@property (nonatomic, readonly, getter=isConsistent) BOOL consistent;

@end
