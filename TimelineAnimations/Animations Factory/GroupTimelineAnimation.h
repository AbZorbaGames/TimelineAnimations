//
//  GroupTimelineAnimation.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupTimelineAnimation : TimelineAnimation
@property (nonatomic, strong, readonly) NSArray<__kindof TimelineAnimation *> *timelineAnimations;

- (instancetype)initWithTimelines:(nullable NSSet<__kindof TimelineAnimation *> *)timelines NS_DESIGNATED_INITIALIZER;
+ (instancetype)groupTimelineAnimation;
+ (instancetype)groupTimelineAnimationWithCompletion:(BoolBlock)completion;
+ (instancetype)groupTimelineAnimationOnStart:(VoidBlock)onStart completion:(BoolBlock)completion;

// manage timelines
- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation;
- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation withDelay:(NSTimeInterval)delay;
- (BOOL)containsTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation;
- (void)removeTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation;

- (void)insertTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                         atTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END

