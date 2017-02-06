//
//  GroupTimelineEntity.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//
@import Foundation;
@class TimelineAnimation;
#import "TimelineAnimations.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupTimelineEntity : NSObject
@property (nonatomic, strong) __kindof TimelineAnimation *timeline;

+ (instancetype)groupTimelineEntityWithTimeline:(__kindof TimelineAnimation *)timeline;

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timeline NS_DESIGNATED_INITIALIZER;

@end


@interface GroupTimelineEntity (Control)

- (void)playAfterReverse:(nullable __kindof TimelineAnimation *)timeline
                 onStart:(VoidBlock)onStart
              onComplete:(BoolBlock)complete;
- (void)playOnStart:(VoidBlock)onStart
         onComplete:(BoolBlock)complete;
- (void)pause;
- (void)resume;
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
