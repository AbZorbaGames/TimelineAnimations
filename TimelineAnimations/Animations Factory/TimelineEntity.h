//
//  TimelineEntity.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@import UIKit;
#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineEntity: NSObject

@property (nonatomic, readonly, weak) __kindof CALayer *layer;
@property (nonatomic, readonly, copy)   __kindof CAPropertyAnimation *animation;
@property (nonatomic, readonly, copy)   NSString *animationKey;

@property (nonatomic, readwrite, assign) RelativeTime beginTime;
@property (nonatomic, assign, readonly)  RelativeTime endTime;
@property (nonatomic, assign, readonly)  NSTimeInterval duration;

@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, assign, getter=isPaused)    BOOL paused;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float progress;

@property (nonatomic, weak) TimelineAnimation *timelineAnimation;

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                    beginTime:(RelativeTime)beginTime
                      onStart:(nullable VoidBlock)onStart
                   onComplete:(nullable BoolBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation;

@end

@interface TimelineEntity (Control)

- (void)playOnStart:(VoidBlock)onStart
         onComplete:(BoolBlock)comlete
     setModelValues:(BOOL)setsModelVaules;

- (void)pause;
- (void)resume;
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
