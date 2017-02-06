//
// Created by Georges Boumis on 15/12/2016.
// Copyright (c) 2016 AbZorba Games. All rights reserved.
//

@import Foundation;
@class TimelineAnimation;
#import "TimelineAudioAssociation.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineAudioAssociation (Internal)
- (RelativeTime)timeInTimelineAnimation:(__kindof TimelineAnimation *)timeline;
@end

NS_ASSUME_NONNULL_END
