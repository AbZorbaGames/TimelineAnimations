#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AnimationsFactory.h"
#import "AnimationsKeyPath.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "EasingTimingHandler.h"
#import "GroupTimelineAnimation.h"
#import "KeyValueBlockObservation.h"
#import "TimelineAnimation.h"
#import "TimelineAnimations.h"
#import "TimelineAudio.h"
#import "TimelineAudioAssociation.h"
#import "Types.h"
#import "easing.h"
#import "TimelineAnimationDescription.h"

FOUNDATION_EXPORT double TimelineAnimationsVersionNumber;
FOUNDATION_EXPORT const unsigned char TimelineAnimationsVersionString[];

