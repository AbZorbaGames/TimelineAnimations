//
//  TimelineAnimation.h
//  Baccarat
//
//  Created by Abzorba Games on 14/09/2015.
//  Copyright (c) 2015 Abzorba Games. All rights reserved.
//

@import Foundation;
@import UIKit;
@class TimelineEntity;

typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL result);
typedef void (^RepeatCompletionBlok)(BOOL result, NSUInteger iteration, BOOL * _Nonnull stop);


NS_ASSUME_NONNULL_BEGIN

@interface TimelineAnimation : NSObject <NSCopying>

@property (nonatomic, copy) BoolBlock __nullable completion;
@property (nonatomic, copy) VoidBlock __nullable onUpdate;
@property (nonatomic, copy) VoidBlock __nullable onStart;

@property (nonatomic, readonly, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign, readonly) NSTimeInterval endTime;

@property (nonatomic, readonly, assign, getter=isPaused) BOOL paused;
@property (nonatomic, readonly, assign, getter=hasStarted) BOOL started;
@property (nonatomic, readonly, assign, getter=hasFinished) BOOL finished;

@property (nonatomic, assign) BOOL setsModelValues;
@property (nonatomic, assign) float speed;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDictionary<id, id> *userInfo;

@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, copy) RepeatCompletionBlok __nullable repeatCompletion;

- (instancetype)initWithStart:(nullable VoidBlock)onStart
                       update:(nullable VoidBlock)onUpdate
                   completion:(nullable BoolBlock)completion NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCompletion:(nullable BoolBlock)completion;
- (instancetype)initWithStart:(nullable VoidBlock)onStart;
- (instancetype)initWithUpdate:(nullable VoidBlock)onUpdate;

- (instancetype)initWithStart:(nullable VoidBlock)onStart
                       update:(nullable VoidBlock)onUpdate;

- (instancetype)initWithStart:(nullable VoidBlock)onStart
                   completion:(nullable BoolBlock)completion;

- (instancetype)initWithUpdate:(nullable VoidBlock)onUpdate
                    completion:(nullable BoolBlock)completion;

+ (TimelineAnimation *)timelineAnimationWithCompletion:(BoolBlock)completion;
+ (TimelineAnimation *)timelineAnimation;
+ (TimelineAnimation *)timelineAnimationOnStart:(VoidBlock)onStart completion:(BoolBlock)completion;

#pragma mark - Timeline Adding Animations Methods -
/**
 * Appends the animation at the end of the timeline
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(nullable VoidBlock)onStart;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(nullable BoolBlock)complete;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(nullable VoidBlock)onStart
          onComplete:(nullable BoolBlock)complete;

/**
 * Appends the animation at the end of the timeline, with an optional delay value;
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay
             onStart:(nullable VoidBlock)onStart;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay
          onComplete:(nullable BoolBlock)complete;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay
             onStart:(nullable VoidBlock)onStart
          onComplete:(nullable BoolBlock)complete;

/**
 * Iserts the animation at the given time.
 */
- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time
                onStart:(nullable VoidBlock)start;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time
             onComplete:(nullable BoolBlock)complete;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time
                onStart:(nullable VoidBlock)start
             onComplete:(nullable BoolBlock)complete;

#pragma mark - Timeline Control -
- (void)play;
- (void)replay;
- (void)pause;
- (void)resume;

- (void)clear;
- (void)delay:(NSTimeInterval)delay;

- (instancetype)reversed;

@end

NS_ASSUME_NONNULL_END
