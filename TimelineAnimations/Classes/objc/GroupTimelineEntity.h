//
//  GroupTimelineEntity.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//
@import Foundation;
@class TimelineAnimation;
#import "TimelineAnimation.h"
#import "PrivateTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupTimelineEntity : NSObject
@property (nonatomic, strong, readonly) __kindof TimelineAnimation *timeline;

@property (nonatomic, assign, readonly) RelativeTime beginTime;
@property (nonatomic, assign, readonly) RelativeTime endTime;

+ (instancetype)groupTimelineEntityWithTimeline:(__kindof TimelineAnimation *)timeline;

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timeline NS_DESIGNATED_INITIALIZER;

@end


@interface GroupTimelineEntity (Control)

- (void)playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
               afterReverse:(nullable __kindof TimelineAnimation *)revereseTimeline
                    onStart:(TimelineAnimationOnStartBlock)onStart
                 onComplete:(TimelineAnimationCompletionBlock)complete;

- (void)playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
                    onStart:(TimelineAnimationOnStartBlock)onStart
                 onComplete:(TimelineAnimationCompletionBlock)complete;

- (void)pauseWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyPausedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)resumedLayers;

- (void)resumeWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyResumedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)pausedLayers;

- (void)reset;
- (void)clear;

@end

@interface GroupTimelineEntity (Reverse)

- (instancetype)reversedCopyWithDuration:(NSTimeInterval)duration;

@end

@interface GroupTimelineEntity (Copying)  <NSCopying>

- (instancetype)copyWithDuration:(NSTimeInterval)newDuration
           shouldAdjustBeginTime:(BOOL)adjust
             usingTotalBeginTime:(RelativeTime)totalBeginTime;

@end

// extension
@interface TimelineAnimation (GroupTimelineEntity)
@property (nonatomic, weak) GroupTimelineEntity *groupTimelineEntity;
@end



NS_ASSUME_NONNULL_END
