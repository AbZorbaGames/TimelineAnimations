/*!
 *  @file TimelineAnimationDescription.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 23/05/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

#import "TimelineAnimationDescription.h"

@interface TimelineAnimationDescription ()

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAnimation:(__kindof CAPropertyAnimation *)animation
                         forLayer:(__kindof CALayer *)layer
                          onStart:(TimelineAnimationOnStartBlock)onStart
                       completion:(TimelineAnimationCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

@end

@implementation TimelineAnimationDescription

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithAnimation:(__kindof CAPropertyAnimation *)animation
                         forLayer:(__kindof CALayer *)layer
                          onStart:(TimelineAnimationOnStartBlock)onStart
                       completion:(TimelineAnimationCompletionBlock)completion {
    self = [super init];
    if (self) {
        _animation  = [animation copy];
        _layer = layer;
        _onStart    = [onStart copy];
        _completion = [completion copy];
    }
    return self;
}

+ (instancetype)descriptionWithAnimation:(__kindof CAPropertyAnimation *)animation
                                forLayer:(__kindof CALayer *)layer
                                 onStart:(TimelineAnimationOnStartBlock)onStart
                              completion:(TimelineAnimationCompletionBlock)completion {
    
    return [[self alloc] initWithAnimation:animation
                                  forLayer:layer
                                   onStart:onStart
                                completion:completion];
}

@end
