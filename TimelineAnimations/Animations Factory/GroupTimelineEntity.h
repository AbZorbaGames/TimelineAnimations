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

@interface GroupTimelineEntity : NSObject <NSCopying>
@property (nonatomic, strong) __kindof TimelineAnimation * __nullable timeline;

+ (instancetype)groupTimelineEntityWithTimeline:(nullable __kindof TimelineAnimation *)timeline;

- (instancetype)initWithTimeline:(nullable __kindof TimelineAnimation *)timeline NS_DESIGNATED_INITIALIZER;

- (void)playOnStart:(VoidBlock)onStart onComplete:(BoolBlock)complete;
- (void)pause;
- (void)resume;
- (void)reset;
- (void)clear;

- (instancetype)reversedCopyWithDuration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
