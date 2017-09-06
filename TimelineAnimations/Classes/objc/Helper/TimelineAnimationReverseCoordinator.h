//
//  TimelineAnimationReverseCoordinator.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 22/06/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

@import Foundation;
#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@class TimelineAnimationReverseCoordinator;

typedef void (^TimelineAnimationReverseCoordinatorCompletionBlock)(__kindof TimelineAnimation *timeline);

@interface TimelineAnimationReverseCoordinator : NSObject
@property (nonatomic, strong, readonly) __kindof TimelineAnimation *timeline;

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timelineAnimation
                      completion:(TimelineAnimationReverseCoordinatorCompletionBlock)completion NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
