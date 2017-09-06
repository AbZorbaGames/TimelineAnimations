//
//  TimelineEntity.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

@import UIKit;
#import "TimelineAnimation.h"
#import "PrivateTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineEntity: NSObject

@property (nonatomic, readonly, weak, nullable) __kindof CALayer *layer;
@property (nonatomic, readonly, copy) __kindof CAPropertyAnimation *animation;
@property (nonatomic, readonly, copy) __kindof CAPropertyAnimation *initialAnimation;
@property (nonatomic, readonly, copy) NSString *animationKey;

@property (nonatomic, readwrite, assign) RelativeTime beginTime;
@property (nonatomic, assign, readonly)  RelativeTime endTime;
@property (nonatomic, assign, readonly)  NSTimeInterval duration;

@property (nonatomic, copy, readonly, nullable) TimelineAnimationOnStartBlock onStart;
@property (nonatomic, copy, readonly, nullable) TimelineAnimationCompletionBlock completion;

@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, assign, getter=isPaused)    BOOL paused;

/** 
 The speed of the animation.
 @throws EmptyTimelineAnimationException if the layer was deallocated.
 */
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float progress;

@property (nonatomic, weak) TimelineAnimation *timelineAnimation;

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                    beginTime:(RelativeTime)beginTime
                      onStart:(nullable TimelineAnimationOnStartBlock)onStart
                   onComplete:(nullable TimelineAnimationCompletionBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation;

@end

@interface TimelineEntity (Control)

- (void)playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
                    onStart:(TimelineAnimationOnStartBlock)callerOnStart
                 onComplete:(TimelineAnimationCompletionBlock)comlete
             setModelValues:(BOOL)setsModelVaules;

- (void)pauseWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime;
- (void)resumeWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime;
- (void)reset;

- (void)clear;

@end

@interface TimelineEntity (Reverse)

- (instancetype)reversedCopy;

@end

@interface TimelineEntity (Copying) <NSCopying>
@end

@interface TimelineEntity (Conflicts)
- (BOOL)conflictingWith:(TimelineEntity *)entity;
@end

@interface TimelineEntity (Duration)

- (instancetype)copyWithDuration:(NSTimeInterval)newDuration
           shouldAdjustBeginTime:(BOOL)adjust
             usingTotalBeginTime:(RelativeTime)totalBeginTime;


@end

NS_ASSUME_NONNULL_END
