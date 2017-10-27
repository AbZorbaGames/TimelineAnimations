//
//  TimelineAnimation+Audio.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 15/12/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

@import Foundation;
#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @public
 * @protocol TimelineAudio
 * @abstract A protocol that a class needs to conform to be used as an 
 * associated audio to a TimelineAnimation.
 */
@protocol TimelineAudio <NSObject>
/// The duration of the audio
@property (nonatomic, readonly) NSTimeInterval duration;

/*!
 * @public
 * Starts playing the audio
 */
- (void)play;

/*!
 * @public
 * Stops playing the audio
 * @param fadeOut wether a fade out of the audio is requested or not.
 */
- (void)stop:(BOOL)fadeOut;

@end

NS_ASSUME_NONNULL_END
