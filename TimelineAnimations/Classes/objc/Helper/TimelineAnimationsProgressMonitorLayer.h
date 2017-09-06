//
//  TimelineAnimationsProgressMonitorLayer.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//


@import Foundation;
@import QuartzCore;
#import "TimelineAnimationsBlankLayer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TimelineAnimationsProgressBlock)(float progress);

@interface TimelineAnimationsProgressMonitorLayer : TimelineAnimationsBlankLayer
@property (nonatomic, assign) float progress;
@property (nonatomic, copy) TimelineAnimationsProgressBlock progressBlock;
@end

NS_ASSUME_NONNULL_END
