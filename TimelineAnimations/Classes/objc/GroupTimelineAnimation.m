//
//  GroupTimelineAnimation.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "GroupTimelineAnimation.h"
#import "TimelineAnimationProtected.h"
#import "GroupTimelineEntity.h"
#import "TimelineEntity.h"
#import "TimelineAnimationsBlankLayer.h"
#import "TimelineAnimationsProgressMonitorLayer.h"
#import "NSArray+TimelineSwiftyAdditions.h"
#import "NSSet+TimelineSwiftyAdditions.h"
#import "PrivateTypes.h"

@interface GroupTimelineAnimation ()
@property (nonatomic, strong) TimelineAnimation *helperTimeline;
@property (nonatomic, strong) NSMutableSet<GroupTimelineEntity *> *unfinishedEntities;
@property (nonatomic, strong) NSMutableSet<GroupTimelineEntity *> *timelinesEntities;
@property (nonatomic, strong, readonly) NSArray<GroupTimelineEntity *> *sortedEntities;

@property (nonatomic, strong, readonly) NSArray<__kindof TimelineAnimation *> *timelineAnimations;

- (void)_checkForConflictsWithEntity:(GroupTimelineEntity *)entity;

@end

@implementation GroupTimelineAnimation

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithTimelines:nil];
}

- (instancetype)initWithStart:(TimelineAnimationOnStartBlock)onStart
                       update:(TimelineAnimationOnUpdateBlock)onUpdate
                   completion:(TimelineAnimationCompletionBlock)completion {
    self = [self initWithTimelines:nil];
    if (self) {
        [self _setOnStart:onStart];
        self.onUpdate = onUpdate;
        [self _setCompletion:completion];
    }
    return self;
}

- (instancetype)initWithTimelines:(nullable NSSet<__kindof TimelineAnimation *> *)timelines {
    self = [super initWithStart:nil completion:nil];
    if (self) {
        _timelinesEntities = [[NSMutableSet alloc] init];
        if (timelines) {
            [timelines enumerateObjectsUsingBlock:^(__kindof TimelineAnimation * _Nonnull timeline, BOOL * _Nonnull stop) {
                GroupTimelineEntity *const entity = [GroupTimelineEntity groupTimelineEntityWithTimeline:timeline];
                [self _addEntity:entity];
            }];
        }
        _unfinishedEntities = [[NSMutableSet alloc] init];
        _speed = 1.0f;
    }
    return self;
}

+ (instancetype)groupTimelineAnimation {
    return [[GroupTimelineAnimation alloc] initWithTimelines:nil];
}

+ (instancetype)together:(NSArray<__kindof TimelineAnimation *> *)animations {
    NSParameterAssert(animations != nil);
    
    GroupTimelineAnimation *const group = [self groupTimelineAnimation];
    NSString *const name = [animations _reduce:[NSMutableString string]
                                     transform:^NSMutableString *_Nonnull(NSMutableString *_Nonnull partial, __kindof TimelineAnimation * _Nonnull animation) {
                                         if (partial.length > 0) {
                                             [partial appendString:@" || "];
                                         }
                                         [partial appendFormat:@"[%@]", animation.name];
                                         return partial;
                                     }];
    group.name = name;
    
    [animations enumerateObjectsUsingBlock:^(__kindof TimelineAnimation * _Nonnull timeline, NSUInteger idx, BOOL * _Nonnull stop) {
        [group insertTimelineAnimation:timeline atTime:(RelativeTime)0.0];
    }];
    
    return group;
}

+ (instancetype)sequentially:(NSArray<__kindof TimelineAnimation *> *)animations {
    NSParameterAssert(animations != nil);
    
    GroupTimelineAnimation *const group = [self groupTimelineAnimation];
    NSString *const name = [animations _reduce:[NSMutableString string]
                                     transform:^NSMutableString *_Nonnull(NSMutableString *_Nonnull partial, __kindof TimelineAnimation * _Nonnull animation) {
                                         if (partial.length > 0) {
                                             [partial appendString:@" ^ "];
                                         }
                                         [partial appendFormat:@"[%@]", animation.name];
                                         return partial;
                                     }];
    group.name = name;
    
    [animations enumerateObjectsUsingBlock:^(__kindof TimelineAnimation * _Nonnull timeline, NSUInteger idx, BOOL * _Nonnull stop) {
        [group addTimelineAnimation:timeline];
    }];
    
    return group;
}

+ (instancetype)groupTimelineAnimationWithCompletion:(TimelineAnimationCompletionBlock)completion {
    return [[GroupTimelineAnimation alloc] initWithStart:nil
                                                  update:nil
                                              completion:completion];
}

+ (instancetype)groupTimelineAnimationOnStart:(TimelineAnimationOnStartBlock)onStart
                                   completion:(TimelineAnimationCompletionBlock)completion {
    return [[GroupTimelineAnimation alloc] initWithStart:onStart
                                                  update:nil
                                              completion:completion];
}

- (void)dealloc {
    _unfinishedEntities = nil;
    _timelinesEntities = nil;
    [_helperTimeline clear];
    _helperTimeline = nil;
    [self.animations removeAllObjects];
    self.originate = nil;
    self.parent = nil;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isMemberOfClass:[GroupTimelineAnimation class]]) {
        return NO;
    }
    
    GroupTimelineAnimation *const other = (GroupTimelineAnimation *)object;
    const BOOL same = [other.timelinesEntities isEqualToSet:_timelinesEntities];
    return same;
}


#pragma mark - Properties

- (BOOL)isEmpty {
    return (_timelinesEntities.count == 0);
}

- (TimelineAnimation *)lastTimeline {
    __block TimelineAnimation *res = nil;
    __block RelativeTime maxTime = (RelativeTime)0.0;
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        RelativeTime endTime = entity.endTime;
        if (endTime >= maxTime) {
            maxTime = endTime;
            res = entity.timeline;
        }
    };
    return res;
}

- (RelativeTime)beginTime {
    GroupTimelineEntity *const first = self.sortedEntities.firstObject;
    return first.beginTime;
}

- (void)delay:(NSTimeInterval)delay {
    
    if (self.hasStarted) {
        [self __raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    
    guard (delay != (NSTimeInterval)0.0) else { return; }
    
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        entity.timeline.beginTime += delay;
    };
    
    RelativeTime newBeginTime = self.beginTime;
    // calculate notification time changes
    self.timeNotificationAssociations = [self timeNotificationConvertedUsing:^RelativeTimeNumber * _Nonnull(RelativeTimeNumber * _Nonnull key) {
        RelativeTime new = Round(key.doubleValue + delay);
        if (new <= newBeginTime) {
            new = newBeginTime + TimelineAnimationMillisecond;
        }
        return @(new);
    }];
}

- (void)setBeginTime:(RelativeTime)beginTime {
    [super setBeginTime:beginTime];
}

- (RelativeTime)endTime {
    
    GroupTimelineEntity *const lastEntity = [self _sortedEntitesUsingKey:@"endTime"].lastObject;
    const RelativeTime endTime = lastEntity.endTime;
    if (self.isRepeating && !self.isInfinitelyRepeating) {
        return (endTime - self.beginTime) * (RelativeTime)self.repeatCount + self.beginTime;
    }
    return endTime;
}

- (RelativeTime)endTimeWithNoRepeating {
    const RelativeTime endTime = [self _sortedEntitesUsingKey:@"endTime"].lastObject.endTime;
    return endTime;
}


- (void)setSpeed:(float)speed {
    if (speed < 0.0f) {
        speed = 0.0f;
    }
    float changePercentage = speed / _speed;
    guard (changePercentage != 1.0f) else { return; }
    
    _speed = speed;
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        entity.timeline.speed *= changePercentage;
    };
}

// protected

- (TimelineAnimation *)helperTimeline {
    if (_helperTimeline == nil) {
        _helperTimeline = [[TimelineAnimation alloc] init];
        _helperTimeline.name = @"GroupTimelineAnimation.helperTimelineAnimation";
    }
    return _helperTimeline;
}

- (NSTimeInterval)nonRepeatingDuration {
    const RelativeTime begin = [self _sortedEntitesUsingKey:@"beginTime"].firstObject.beginTime;
    const RelativeTime end = [self _sortedEntitesUsingKey:@"endTime"].lastObject.endTime;
    return (end - begin);
}

- (NSSet<__kindof CALayer *> *)affectedLayers {
    NSMutableSet<CALayer *> *const layers = [[NSMutableSet alloc] init];
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [layers unionSet:entity.timeline.affectedLayers];
    }];
    return [layers copy];
}

#pragma mark - Entities

- (NSArray<__kindof TimelineAnimation *> *)timelineAnimations {
    return [self.sortedEntities valueForKeyPath:@"timeline"];
}

- (NSArray<GroupTimelineEntity *> *)sortedEntities {
    return [self _sortedEntitesUsingKey:@"beginTime"];
}

- (NSArray<GroupTimelineEntity *> *)_sortedEntitesUsingKey:(NSString *)key {
    NSSortDescriptor *const sortUsingBeginTime = [NSSortDescriptor sortDescriptorWithKey:[@"timeline" stringByAppendingPathExtension:key]
                                                                               ascending:YES];
    NSArray<NSSortDescriptor *> *const descriptors = @[sortUsingBeginTime];
    NSArray<GroupTimelineEntity *> *const sortedEntities = [_timelinesEntities sortedArrayUsingDescriptors:descriptors];
    return sortedEntities;
}

- (nullable __kindof TimelineAnimation *)timelineAnimationSimilarToTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    if (![self containsTimelineAnimation:timelineAnimation]) {
        return nil;
    }
    
    __block __kindof TimelineAnimation *tl = nil;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity *_Nonnull entity, BOOL *_Nonnull stop) {
        if ([entity.timeline isEqual:timelineAnimation]) {
            tl = entity.timeline;
            *stop = YES;
        }
    }];
    return tl;
}

- (void)_checkForConflictsWithEntity:(GroupTimelineEntity *)entity {
    @autoreleasepool {
        NSArray<TimelineEntity *> *const myEntities = [self _entitiesOfTimelineAnimation:self];
        
        NSArray<TimelineEntity *> *const otherEntities = [self _entitiesOfTimelineAnimation:entity.timeline];
        [otherEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull otherEntity, NSUInteger idx, BOOL * _Nonnull stop) {
            [myEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull myEntity, NSUInteger idx2, BOOL * _Nonnull stop2) {
                BOOL conflicting = [otherEntity conflictingWith:myEntity];
                if (conflicting) {
                    *stop2 = YES;
                    [self __raiseConflictingAnimationExceptionBetweenEntity:otherEntity
                                                                  andEntity:myEntity];
                    return;
                }
            }];
        }];
    }
}

- (NSArray<TimelineEntity *> *)_entitiesOfTimelineAnimation:(__kindof TimelineAnimation *)timeline {
    if ([timeline isMemberOfClass:[TimelineAnimation class]]) {
        return [timeline.animations copy];
    }
    else if ([timeline isMemberOfClass:[GroupTimelineAnimation class]]) {
        GroupTimelineAnimation *const group = timeline;
        NSArray<__kindof TimelineAnimation *> *const timelines =
        [group.timelinesEntities _map:^id _Nonnull(GroupTimelineEntity * _Nonnull entity) {
            return entity.timeline;
        }];
        NSArray<TimelineEntity *> *const subEntities =
        [timelines _flatMap:^NSArray * _Nonnull(__kindof TimelineAnimation * _Nonnull tl) {
            return [self _entitiesOfTimelineAnimation:tl];
        }];
        return [subEntities copy];
    }
    return @[];
}

- (void)_addEntity:(GroupTimelineEntity *)entity {
    guard (entity.timeline.isEmpty == NO) else {
        NSParameterAssert(entity.timeline.isEmpty == NO);
//        NSLog(@"TimelineAnimations: Tried to add an empty timeline to \"%@\"",
//              self.name);
        return;
    }
    // check
    [self _checkForConflictsWithEntity:entity];
    
    [_timelinesEntities addObject:entity];
    entity.timeline.parent = self;
}

#pragma mark - 

- (void)_prepareForReplay {
    [super _prepareForReplay];
    
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        [entity.timeline _prepareForReplay];
    };
}

- (void)callOnComplete:(BOOL)result {
    guard (_unfinishedEntities.count == 0) else { return; }
    [self _callOnComplete:result];
}

- (void)_cleanUp {
    [super _cleanUp];
    
    if (_helperTimeline != nil) {
        GroupTimelineEntity *const gte = [GroupTimelineEntity groupTimelineEntityWithTimeline:_helperTimeline];
        [_timelinesEntities removeObject:gte];
    }
    _helperTimeline = nil;
}

- (void)pauseWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyPausedLayers:(NSMutableSet<__kindof CALayer *> *)pausedLayers {
    self.paused = YES;
    
    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities;
    
    [sortedEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        [entity pauseWithCurrentTime:currentTime
                 alreadyPausedLayers:pausedLayers];
    }];
}

- (void)resumeWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyResumedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)resumedLayers {
    
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [entity resumeWithCurrentTime:currentTime
                 alreadyResumedLayers:resumedLayers];
    }];
    
    self.paused = NO;
}

- (BOOL)_checkForOutOfHierarchyIssues {
    
    for (GroupTimelineEntity *const entity in self.timelinesEntities) {
        const BOOL outOfHierarchy = [entity.timeline _checkForOutOfHierarchyIssues];
        guard (not(outOfHierarchy)) else { return YES; }
    }
    return NO;
}

#pragma mark - Unsupported methods

- (void)setSetsModelValues:(BOOL)setsModelValues {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)setOnUpdate:(TimelineAnimationOnUpdateBlock)onUpdate {
    return;
}

- (void)__raiseImmutableGroupTimelineExceptionWithSelector:(SEL)sel {
    [self __raiseImmutableTimelineAnimationExceptionWithReason:
     @"Tried to modify %@.%@ in selector: \"%@\""
     "while the animation has already started.",
     NSStringFromClass(self.class),
     self.name,
     NSStringFromSelector(sel)];
}

- (void)__raiseUnsupportedMessageExceptionWithSelector:(SEL)sel {
    [self __raiseUnsupportedMessageExceptionWithReason:
     @"GroupTimelineAnimation does not respond to -%@. Use a TimelineAnimation instead.",
     NSStringFromSelector(sel)
     ];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(setSetsModelValues:)) {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}

- (void)__setupTimeNotifications {
    guard (self.timeNotificationAssociations.count > 0) else { return; }
    
    TimelineAnimation *helper = self.helperTimeline;
    
    if (self.name != nil) {
        NSString *const name = helper.name;
        helper.name = [NSString stringWithFormat:@"%@>>%@", self.name, name];
    }
    
    
    const RelativeTime beginTime = self.beginTime;
    const NSTimeInterval helperDuration = self.duration;
    [helper insertBlankAnimationAtTime:beginTime
                               onStart:nil
                            onComplete:nil
                          withDuration:helperDuration];
    {
        NSAssert(helper != nil && helper.isNonEmpty, @"TimelineAnimations: WTF?");
        
        {   /* fix out-of-hierarchy issues */
            __strong __kindof CALayer *const anyLayer = _timelinesEntities.anyObject.timeline.animations.firstObject.layer;
            NSAssert(anyLayer != nil, @"TimelineAnimations: Try to add blank animation but there is no layer to add it to.");
            for (TimelineAnimationsBlankLayer *const blankHelperLayer in helper.blankLayers) {
                guard (blankHelperLayer.superlayer == nil) else { continue; }
                [anyLayer addSublayer:blankHelperLayer];
            }
        }
        GroupTimelineEntity *const groupTimelineEntity = [GroupTimelineEntity groupTimelineEntityWithTimeline:helper];
        [_timelinesEntities addObject:groupTimelineEntity];
        
        groupTimelineEntity.timeline.parent = self;
    }
    [self _setupTimeNotifications];
}

- (void)_setupProgressMonitoring {
    self.progressLayer = [TimelineAnimationsProgressMonitorLayer layer];
    __weak typeof(self) welf = self;
    self.progressLayer.progressBlock = ^(float progress) {
        __strong typeof(self) strelf = welf;
        strelf.progress = progress;
    };
    
    __strong __kindof CALayer *const anyLayer = _timelinesEntities.anyObject.timeline.animations.firstObject.layer;
    NSAssert(anyLayer != nil, @"TimelineAnimations: Try to add blank animation but there is no layer to add it to.");
    [anyLayer addSublayer:self.progressLayer];
    
    CABasicAnimation *const anim = [CABasicAnimation animationWithKeyPath:@"progress"];
    anim.duration            = self.duration;
    anim.fromValue           = @(0.0);
    anim.toValue             = @(1.0);
    [self.progressLayer addAnimation:anim forKey:@"progress"];
}

@end

@implementation GroupTimelineAnimation (Populate)

#pragma mark - Overrides

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(TimelineAnimationOnStartBlock)onStart {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(TimelineAnimationCompletionBlock)complete {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(TimelineAnimationOnStartBlock)onStart
          onComplete:(TimelineAnimationCompletionBlock)complete {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(TimelineAnimationOnStartBlock)onStart {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
          onComplete:(TimelineAnimationCompletionBlock)complete {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(nullable TimelineAnimationOnStartBlock)onStart
          onComplete:(nullable TimelineAnimationCompletionBlock)complete  {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(TimelineAnimationOnStartBlock)start {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
             onComplete:(TimelineAnimationCompletionBlock)complete {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
};

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(nullable TimelineAnimationOnStartBlock)start
             onComplete:(nullable TimelineAnimationCompletionBlock)complete {
    [self __raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

#pragma mark - Group

- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    [self addTimelineAnimation:timelineAnimation withDelay:(NSTimeInterval)0.0];
}

- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                   withDelay:(NSTimeInterval)delay {
    
    NSParameterAssert(timelineAnimation != nil);
    
    if (self.hasStarted) {
        [self __raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (timelineAnimation == nil) {
        [self __raiseInvalidArgumentExceptionWithReason:
         @"TimelineAnimations: Tried to add a 'nil' TimelineAnimation to a %@",
         NSStringFromClass(self.class)];
        return;
    }
    
    __kindof TimelineAnimation *tl = timelineAnimation.copy;
    
    TimelineAnimation *const lastTimeline = [self lastTimeline];
    tl.beginTime += lastTimeline.endTime + delay;
    GroupTimelineEntity *const entity = [GroupTimelineEntity groupTimelineEntityWithTimeline:tl];
    [self _addEntity:entity];
}

- (void)removeTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    
    if (self.hasStarted) {
        [self __raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    
    if ([self containsTimelineAnimation:timelineAnimation]) {
        GroupTimelineEntity *const gte = [GroupTimelineEntity groupTimelineEntityWithTimeline:timelineAnimation];
        [_timelinesEntities removeObject:gte];
    }
}

- (void)insertTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                         atTime:(RelativeTime)time {
    
    
    NSParameterAssert(timelineAnimation != nil);
    
    if (self.hasStarted) {
        [self __raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    
    if (timelineAnimation == nil) {
        [self __raiseInvalidArgumentExceptionWithReason:
         @"Tried to add a 'nil' TimelineAnimation to a %@",
         NSStringFromClass(self.class)];
        return;
    }
    
    __kindof TimelineAnimation *const tl = timelineAnimation.copy;
    
    tl.beginTime = time;
    
    GroupTimelineEntity *const entity = [GroupTimelineEntity groupTimelineEntityWithTimeline:tl];
    [self _addEntity:entity];
}

- (void)addTimelineAnimations:(NSArray<__kindof TimelineAnimation *> *)animations
                    withDelay:(NSTimeInterval)delay {
    
    const RelativeTime time = self.duration + delay;
    [self insertTimelineAnimations:animations atTime:time];
    
}

- (void)insertTimelineAnimations:(NSArray<__kindof TimelineAnimation *> *)animations
                          atTime:(RelativeTime)time {
    
    NSParameterAssert(animations != nil);
    NSParameterAssert(animations.count > 0);
    
    [animations enumerateObjectsUsingBlock:^(__kindof TimelineAnimation * _Nonnull timeline, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertTimelineAnimation:timeline atTime:time];
    }];
}

- (BOOL)containsTimelineAnimation:(nullable __kindof TimelineAnimation *)timelineAnimation {
    if (timelineAnimation == nil) {
        return NO;
    }
    
    __kindof TimelineAnimation *const timeline = timelineAnimation;
    GroupTimelineEntity *const gte = [GroupTimelineEntity groupTimelineEntityWithTimeline:timeline];
    GroupTimelineEntity *const res = [_timelinesEntities member:gte];
    return (res != nil);
}

- (void)merge:(TimelineAnimation *)timeline {
    
    NSParameterAssert(timeline != nil);
    
    if (self.hasStarted) {
        [self __raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    
    guard ([timeline isMemberOfClass:[GroupTimelineAnimation class]]) else {
        NSAssert(false, @"TimelineAnimations: You should merge with same kinds of timelines.");
        return;
    }
    
    GroupTimelineAnimation *const group = (GroupTimelineAnimation *)timeline;
    
    // add only animations
    [group.timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [self _addEntity:[entity copy]];
    }];
}

@end

#pragma mark - Control

@implementation GroupTimelineAnimation (ProtectedControl)

- (void)_playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime {
    
    NSAssert(self.name != nil, @"TimelineAnimations: You should name your animations");
    NSAssert(self.isNonEmpty, @"TimelineAnimations: Why are you trying to play an empty %@?",
             NSStringFromClass(self.class));
    
    if (self.isPaused) {
        [self resume];
        return;
    }
    
    if (self.hasStarted) {
        [self __raiseOngoingTimelineAnimationWithReason:
         @"You tried to play an non paused or finished %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
        return;
    }
    
    if (self.isCleared) {
        [self __raiseClearedTimelineAnimationExceptionWithReason:
         @"You tried to play the cleared %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name
         ];
        return;
    }
    
    
    if (self.isEmpty) {
        if (self.onStart) {
            self.onStart();
        }
        if (self.completion) {
            self.completion(NO);
        }
        return;
    }
    
    [self __setupTimeNotifications];
    [self _setupProgressNotifications];
    
    if ([self _checkForOutOfHierarchyIssues]) {
        [self __raiseElementsNotInHierarchyExceptionWithReason:
         @"TimelineAnimations: You tried to play an animation with lost layers %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
    }
    
    self.started = YES;
    self.onStartCalled = NO;
    
    _unfinishedEntities = _timelinesEntities.mutableCopy;
    
    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities;
    NSMutableArray<GroupTimelineEntity *> *const reversedEntities = [[NSMutableArray alloc] init];
    NSMutableArray<GroupTimelineEntity *> *const normalEntities   = [[NSMutableArray alloc] initWithCapacity:sortedEntities.count];
    
    for (GroupTimelineEntity *const entity in sortedEntities) {
        // this does not work well if -delay or some other operation that changes the animations occurs
        __strong TimelineAnimation *const originate = entity.timeline.originate;
        if (entity.timeline.reversed && [self containsTimelineAnimation:originate]) {
            [reversedEntities addObject:entity];
        }
        else {
            [normalEntities addObject:entity];
        }
    };
    
    for (GroupTimelineEntity *const entity in normalEntities) {
        [entity playWithCurrentTime:currentTime
                            onStart:^{
                                [self callOnStart];
                            } onComplete:^(BOOL result) {
                                [self.unfinishedEntities removeObject:entity];
                                [self callOnComplete:result];
                            }];
    };
    
    for (GroupTimelineEntity *const entity in reversedEntities) {
        __strong TimelineAnimation *const originate = entity.timeline.originate;
        __kindof TimelineAnimation *const tl = [self timelineAnimationSimilarToTimelineAnimation:originate];
        
        [entity playWithCurrentTime:currentTime
                       afterReverse:tl
                            onStart:^{
                                [self callOnStart];
                            } onComplete:^(BOOL result) {
                                [self.unfinishedEntities removeObject:entity];
                                [self callOnComplete:result];
                            }];
    };
    
    self.paused = NO;
}

@end

@implementation GroupTimelineAnimation (Control)

- (void)play {
    [self _playWithCurrentTime:self.currentTime];
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }
    
    [self resumeWithCurrentTime:self.currentTime
           alreadyResumedLayers:[[NSMutableSet alloc] init]];
//    NSMutableSet<CALayer *> *const resumedLayers = [[NSMutableSet alloc] init];
//    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities;
//    for (GroupTimelineEntity *const groupEntity in sortedEntities) {
//        for (TimelineEntity *const entity in groupEntity.timeline.animations) {
//            __strong __kindof CALayer *const slayer = entity.layer;
//            if ([resumedLayers member:slayer]) {
//                return;
//            }
//            [entity resumeWithCurrentTime:currentTime];
//            [resumedLayers addObject:slayer];
//        }
//    }
//    self.paused = NO;
}

- (void)pause {
    if (!self.hasStarted) {
        return;
    }
    
    [self pauseWithCurrentTime:self.currentTime
           alreadyPausedLayers:[[NSMutableSet alloc] init]];
}

- (void)clear {
    for (GroupTimelineEntity *const entity in _timelinesEntities) {
        [entity clear];
    }
    
    for (GroupTimelineEntity *const entity in _unfinishedEntities) {
        [entity clear];
    }
    
    [_timelinesEntities removeAllObjects];
    [_unfinishedEntities removeAllObjects];
    
    self.paused = NO;
    self.started = NO;
    self.cleared = YES;
    
    
    self.onUpdate = nil;
    [self removeOnStartBlocks];
    [self removeCompletionBlocks];
}


- (void)_prepareForRepeat {
    [self reset];
    
    const RelativeTime begin = self.beginTime;
    if (begin != (RelativeTime)0.0) {
        self.beginTime = (RelativeTime)0.0;
    }
}

- (void)reset {
    
    if (self.hasStarted) {
        [self __raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    
    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities;
    for (GroupTimelineEntity *const entity in sortedEntities) {
        [entity reset];
    }
    
    _repeat.onStartCalled = NO;
    _repeat.onCompleteCalled = NO;
    
    
    self.onStartCalled = NO;
    self.onCompletionCalled = NO;
    
    self.finished = NO;
}

- (instancetype)timelineWithDuration:(NSTimeInterval)duration {
    NSParameterAssert(duration > 0.0);
    
    GroupTimelineAnimation *const updatedTimeline = [self copy];
    if ([updatedTimeline respondsToSelector:@selector(setSetsModelValues:)]) {
        updatedTimeline.setsModelValues = self.setsModelValues;
    }
    
    const NSTimeInterval currentDuration = self.nonRepeatingDuration;
    guard (duration != currentDuration) else { return updatedTimeline; }
    
    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities.copy;
    NSMutableArray<GroupTimelineEntity *> *const updatedEntities = [[NSMutableArray alloc] initWithCapacity:sortedEntities.count];
    const NSTimeInterval newTimelineDuration = duration;
    const NSTimeInterval oldTimelineDuration = currentDuration;
    for (GroupTimelineEntity *const entity in sortedEntities) {
        // adjust if the entity's .beginTime is not the same as the timeline's .beginTime
        BOOL adjust = fabs((double)(entity.beginTime - self.beginTime)) > TimelineAnimationMillisecond;
        const NSTimeInterval newDuration = newTimelineDuration * entity.timeline.duration / oldTimelineDuration;
        GroupTimelineEntity *const updatedEntity = [entity copyWithDuration:newDuration
                                                      shouldAdjustBeginTime:adjust
                                                        usingTotalBeginTime:self.beginTime];
        [updatedEntities addObject:updatedEntity];
    };
    
    
    NSMutableSet<GroupTimelineEntity *> *timelineEntities = [[NSMutableSet alloc] initWithArray:updatedEntities];
    [timelineEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.parent = updatedTimeline;
    }];
    updatedTimeline.timelinesEntities = timelineEntities;
    updatedTimeline.originate = self;
    updatedTimeline.duration = newTimelineDuration;
    
    
    // calculate notification time changes
    const double factor = duration / currentDuration;
    updatedTimeline.timeNotificationAssociations = [self timeNotificationConvertedUsing:^RelativeTimeNumber * _Nonnull(RelativeTimeNumber * _Nonnull key) {
        double value = key.doubleValue;
        if (value == TimelineAnimationMillisecond) {
            return @(TimelineAnimationMillisecond);
        }
        value *= factor;
        if (value < TimelineAnimationMillisecond) {
            value = TimelineAnimationMillisecond;
        }
        return @(Round(value));
    }];
    return updatedTimeline;
}

@end

@implementation GroupTimelineAnimation (Reverse)

- (instancetype)reversed {
    return [self reversedWithDuration:self.duration];
}

- (instancetype)reversedWithDuration:(NSTimeInterval)duration {
    NSParameterAssert(duration > 0.0);
    
    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities.copy;
    NSMutableArray<GroupTimelineEntity *> *const reversedEntities = [[NSMutableArray alloc] initWithCapacity:sortedEntities.count];
    const NSTimeInterval groupTimelineDuration = duration;
    
    for (GroupTimelineEntity *const entity in sortedEntities) {
        // reverse time
        GroupTimelineEntity *const reversedTimelineEntity = [entity reversedCopyWithDuration:groupTimelineDuration];
        [reversedEntities addObject:reversedTimelineEntity];
    }
    
    GroupTimelineAnimation *const reversed = [self copy];
    NSMutableSet<GroupTimelineEntity *> *const timelineEntities = [[NSMutableSet alloc] initWithArray:reversedEntities];
    [timelineEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.parent = reversed;
    }];
    reversed.timelinesEntities = timelineEntities;
    reversed.name = [reversed.name stringByAppendingPathExtension:@"reversed"];
    reversed.originate = self;
    return reversed;
}

@end

@implementation GroupTimelineAnimation (Notify)

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(nullable TimelineAnimationOnStartBlock)start
                        onComplete:(nullable TimelineAnimationCompletionBlock)complete
                      withDuration:(NSTimeInterval)duration {
    
    guard (self.isNonEmpty) else { return; }
    NSAssert(_helperTimeline != nil, @"TimelineAnimations: WTF?");
    NSParameterAssert(duration > 0.0);
    
    TimelineAnimationsBlankLayer *const blankLayer = [[TimelineAnimationsBlankLayer alloc] init];
    CABasicAnimation *const blankAnimation = [CABasicAnimation animationWithKeyPath:TimelineAnimationsBlankLayer.keyPath];
    blankAnimation.duration = duration;
    
    __strong __kindof CALayer *const anyLayer = _timelinesEntities.anyObject.timeline.animations.firstObject.layer;
    NSAssert(anyLayer != nil, @"TimelineAnimations: Try to add blank animation but there is no layer to add it to.");
    
    [anyLayer addSublayer:blankLayer];
    [self.blankLayers addObject:blankLayer];
    
    [_helperTimeline insertAnimation:blankAnimation
                            forLayer:blankLayer
                              atTime:time
                             onStart:start
                          onComplete:complete];
}

@end

#pragma mark - NSCopying

@implementation GroupTimelineAnimation (Copying)

- (id)copyWithZone:(NSZone *)zone {
    GroupTimelineAnimation *const copy = [[GroupTimelineAnimation alloc] initWithTimelines:nil];
    
    copy.timelinesEntities = [[NSMutableSet alloc] initWithSet:_timelinesEntities copyItems:YES];
    [copy.timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.parent = copy;
    }];
    
    copy.paused             = self.paused;
    copy.finished           = self.finished;
    
    copy.speed              = _speed;
    
    copy.beginTime          = self.beginTime;
    copy.repeatCount        = self.repeatCount;
    copy.repeatOnStart      = [self.repeatOnStart copy];
    copy.repeatCompletion   = [self.repeatCompletion copy];
    
    copy.name               = self.name.copy;
    copy.userInfo           = self.userInfo.copy;
    
    
    [copy _setOnStart:[self.onStart copy]];
    [copy _setCompletion:[self.completion copy]];
    copy.onUpdate           = [self.onUpdate copy];
    
    copy.reversed         = self.reversed;
    copy.originate        = self.originate;
    
    copy.muteAssociatedSounds = self.muteAssociatedSounds;
    
    copy.progressNotificationAssociations = self.progressNotificationAssociations.mutableCopy;
    copy.timeNotificationAssociations     = self.timeNotificationAssociations.mutableCopy;
    
    return copy;
}

@end

@implementation GroupTimelineAnimation (Debug)

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<%@: %p; "
            "name: \"%@\"; "
            "beginTime: \"%.3lf\"; "
            "endTime: \"%.3lf\"; "
            "duration: \"%.3lf\"; "
            "userInfo: %@;"
            ">",
            NSStringFromClass(self.class),
            self,
            self.name,
            self.beginTime,
            self.endTime,
            self.duration,
            self.userInfo];
}

- (NSString *)debugDescription {
    return [[NSString alloc] initWithFormat:
            @"<%@: %p; "
            "name: \"%@\"; "
            "beginTime: \"%.3lf\"; "
            "endTime: \"%.3lf\"; "
            "isRepeating(%@): %@; "
            "duration: \"%.3lf\", repeatingDuration: \"%.3lf\"; "
            "userInfo: %@; "
            "animations: %@; "
            "timeNotifications = %@; "
            "progressNotifications = %@;"
            ">",
            NSStringFromClass(self.class),
            self,
            self.name,
            self.beginTime,
            self.endTime,
            @(self.repeatCount),
            @(self.isRepeating).stringValue,
            self.nonRepeatingDuration,
            self.duration,
            self.userInfo,
            self.sortedEntities.debugDescription,
            self.timeNotificationAssociations.allKeys,
            self.progressNotificationAssociations.allKeys];
}

- (NSString *)summary {
    NSMutableString *const summary = [[NSMutableString alloc] initWithFormat:@"\"%@\": ", self.name];
    [summary appendFormat:@"duration: \"%.3lf\"; ", self.duration];
    [summary appendFormat:@"animations(%@) = [\n", @(_timelinesEntities.count)];
    
    NSArray<GroupTimelineEntity *> *const sorted = self.sortedEntities;
    [sorted enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        [summary appendFormat:@"\t%@: name: \"%@\", time: [%.3lf,%.3lf]\n",
         @(idx),
         entity.timeline.name,
         entity.beginTime,
         entity.endTime];
    }];
    [summary appendFormat:@"]"];
    
    return [summary copy];
}

- (NSSet<__kindof TimelineAnimation *> *)timelineAnimationsBeginingAtTime:(RelativeTime)time {
    NSSet<GroupTimelineEntity *> *const entities = [_timelinesEntities objectsPassingTest:^BOOL(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        return (entity.beginTime == time);
    }];
    
    NSMutableSet<__kindof TimelineAnimation *> *const timelines = [[NSMutableSet alloc] initWithCapacity:entities.count];
    [entities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [timelines addObject:[entity.timeline copy]];
    }];
    return [timelines copy];
}

- (NSSet<__kindof TimelineAnimation *> *)timelineAnimationsOngoingAtTime:(RelativeTime)time {
    NSSet<GroupTimelineEntity *> *const entities = [_timelinesEntities objectsPassingTest:^BOOL(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        return (time >= entity.beginTime) && (time <= entity.endTime);
    }];
    
    NSMutableSet<__kindof TimelineAnimation *> *const timelines = [[NSMutableSet alloc] initWithCapacity:entities.count];
    [entities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [timelines addObject:[entity.timeline copy]];
    }];
    return [timelines copy];
}

- (NSArray<CAPropertyAnimation *> *)allPropertyAnimations {
    return [_timelinesEntities _flatMap:^NSArray * _Nonnull(GroupTimelineEntity * _Nonnull entity) {
        return entity.timeline.allPropertyAnimations;
    }];
}

@end

