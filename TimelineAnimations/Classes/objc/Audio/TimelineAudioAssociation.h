//
//  TimelineAudioAssociation.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 15/12/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 @public
 An Audio Association in a TimelineAnimation
 */
NS_REFINED_FOR_SWIFT
@interface TimelineAudioAssociation : NSObject<NSCopying>


/// associated with the start of the timeline
@property (nonatomic, class, readonly) TimelineAudioAssociation *onStart;
/// associated with the middle of the timeline
@property (nonatomic, class, readonly) TimelineAudioAssociation *onMid;
/// associated with the end of the timeline
@property (nonatomic, class, readonly) TimelineAudioAssociation *onCompletion;

/**
 Associated at an arbitrary time, it should be less than the
 `.endTime` of the TimelineAnimation.
 */
+ (instancetype)atTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
