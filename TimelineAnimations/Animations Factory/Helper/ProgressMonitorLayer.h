//
//  ProgressMonitorLayer.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/06/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//


@import Foundation;
@import QuartzCore;
#import "BlankLayer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ProgressBlock)(float progress);

@interface ProgressMonitorLayer : BlankLayer
@property (nonatomic, assign) float progress;
@property (nonatomic, copy) ProgressBlock progressBlock;
@end

NS_ASSUME_NONNULL_END
