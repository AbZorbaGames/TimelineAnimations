//
//  TimelineAnimationProtected.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@class ProgressMonitorLayer;
@class TimelineEntity;
@class BlankLayer;
@class NotifyBlockInfo;

typedef NSNumber ProgressNumber; // float
typedef NSMutableDictionary<ProgressNumber *, NotifyBlock> ProgressNotificationAssociations; // [Float<0..1>: NotifyBlock]
typedef NSNumber RelativeTimeNumber;// relative time -> double
typedef NSMutableDictionary<RelativeTimeNumber *, NotifyBlockInfo *> NotificationAssociations; // [RelativeTime: NotifyInfoBlock]

@interface TimelineAnimation () {
    @protected
    float _speed;
    float _progress;
    NSTimeInterval _duration;
    
    
    struct {
        NSUInteger count;
        NSUInteger iteration;
        BOOL isRepeating;
        BOOL onStartCalled;
    } _repeat;
}
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign, getter=hasStarted) BOOL started;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, readwrite, strong, nonnull) NSMutableArray<TimelineEntity *> *animations;
@property (nonatomic, assign) NSUInteger repeatCounter;
@property (nonatomic, assign, getter=wasOnStartCalled) BOOL onStartCalled;
@property (nonatomic, readwrite, getter=isReversed) BOOL reversed;
@property (nonatomic, readwrite, getter=isCleared) BOOL cleared;
@property (nonatomic, strong, nonnull) NSMutableArray<BlankLayer *> *blankLayers;

@property (nonatomic, readwrite) float progress;
@property (nonatomic, strong, nullable) ProgressMonitorLayer *progressLayer;

@property (nonatomic, strong, nonnull) ProgressNotificationAssociations *progressNotificationAssociations;
@property (nonatomic, strong, nonnull) NotificationAssociations *timeNotificationAssociations;

@property (nonatomic, weak, readwrite, nullable) __kindof TimelineAnimation *originate;
@property (nonatomic, weak, readwrite, nullable) __kindof TimelineAnimation *parent;

- (void)reset;
- (void)prepareForReplay;
- (void)_replay;
- (void)callOnStart;
- (void)callOnComplete:(BOOL)result;

- (void)_setupTimeNotifications;
- (void)_setupProgressNotifications;
- (void)_setupProgressMonitoring;

- (void)_cleanUp;

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(nullable VoidBlock)start
                        onComplete:(nullable BoolBlock)complete
                      withDuration:(NSTimeInterval)duration;

@end

@interface TimelineAnimation (ReverseProtected)

- (nonnull instancetype)reversedWithDuration:(NSTimeInterval)duration;

@end

