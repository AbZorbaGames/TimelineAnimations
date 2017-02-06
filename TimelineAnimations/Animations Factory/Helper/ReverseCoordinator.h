//
//  ReverseCoordinator.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 22/06/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//


@import Foundation;
#import "TimelineAnimations.h"

NS_ASSUME_NONNULL_BEGIN

@class ReverseCoordinator;

typedef void (^ReverseCoordinatorCompletionBlock)(__kindof TimelineAnimation *timeline);

@interface ReverseCoordinator : NSObject
@property (nonatomic, strong, readonly) __kindof TimelineAnimation *timeline;

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timelineAnimation
                      completion:(ReverseCoordinatorCompletionBlock)completion NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
