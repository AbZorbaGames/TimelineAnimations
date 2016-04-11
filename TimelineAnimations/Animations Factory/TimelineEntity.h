//
//  TimelineEntity.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@import UIKit;
#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineEntity : NSObject <NSCopying>
@property (nonatomic, readonly, strong) __kindof CALayer *layer;
@property (nonatomic, readonly, copy) __kindof CAPropertyAnimation *animation;
@property (nonatomic, readonly, copy) NSString *animationKey;
@property (nonatomic, readwrite, assign) NSTimeInterval beginTime;
@property (nonatomic, assign, readonly) NSTimeInterval endTime;
@property (nonatomic, copy) BoolBlock completion;
@property (nonatomic, copy) VoidBlock onStart;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign) float speed;

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                 animationKey:(NSString *)key
                    beginTime:(NSTimeInterval)beginTime
                      onStart:(nullable VoidBlock)onStart
                   onComplete:(nullable BoolBlock)completion NS_DESIGNATED_INITIALIZER;

- (void)playOnStart:(VoidBlock)onStart
         onComplete:(BoolBlock)comlete
     setModelValues:(BOOL)setsModelVaules;
- (void)pause;
- (void)resume;
- (void)reset;

- (void)clearEntity;

- (void)callOnStartIfNeeded;
- (void)callCompletionIfNeededWithResult:(BOOL)result;

- (instancetype)reversedCopy;

@end

NS_ASSUME_NONNULL_END
