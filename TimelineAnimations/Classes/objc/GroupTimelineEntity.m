//
//  GroupTimelineEntity.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "GroupTimelineEntity.h"
#import "GroupTimelineAnimation.h"
#import "TimelineAnimationProtected.h"
#import "TimelineAnimationReverseCoordinator.h"
#import <objc/runtime.h>
#import "PrivateTypes.h"

@implementation TimelineAnimation (GroupTimelineEntity)

@dynamic groupTimelineEntity;

- (void)setGroupTimelineEntity:(GroupTimelineEntity *)groupTimelineEntity {
    objc_setAssociatedObject(self, @selector(groupTimelineEntity), groupTimelineEntity, OBJC_ASSOCIATION_ASSIGN);
}

- (GroupTimelineEntity *)groupTimelineEntity {
    return objc_getAssociatedObject(self, @selector(groupTimelineEntity));
}

@end

@interface GroupTimelineEntity () {
    RelativeTime __beginTime;
    RelativeTime __endTime;
}
@property (nonatomic, strong) TimelineAnimationReverseCoordinator *TimelineAnimationReverseCoordinator;
@property (nonatomic, readwrite) BOOL cleared;

@property (nonatomic, strong) __kindof TimelineAnimation *timeline;
#define NO_RETURN __attribute__ ((noreturn))
+ (void)_raiseEmptyTimelineAnimationException NO_RETURN;
#undef NO_RETURN
@end

@implementation GroupTimelineEntity

#pragma mark - Initilizers

- (instancetype)init {
    return [self initWithTimeline:[TimelineAnimation timelineAnimation]];
}

- (instancetype)initWithTimeline:(__kindof TimelineAnimation *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
        _timeline.groupTimelineEntity = self;
    }
    return self;
}

+ (instancetype)groupTimelineEntityWithTimeline:(__kindof  TimelineAnimation *)timeline {
    return [[self alloc] initWithTimeline:timeline];
}

- (void)dealloc {
    _timeline.groupTimelineEntity = nil;
}

#pragma mark - Properties Overrides

- (RelativeTime)beginTime {
    return _timeline.beginTime;
}

- (RelativeTime)endTime {
    return _timeline.endTime;
}

#pragma mark - NSObject overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[GroupTimelineEntity class]]) {
        return NO;
    }

    GroupTimelineEntity *other = (GroupTimelineEntity *)object;
    BOOL same = [self.timeline isEqual:other.timeline];
    return same;
}

- (NSUInteger)hash {
    return _timeline.hash;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:
            @"<%@: %p; "
            "animation: %@;"
            ">",
            NSStringFromClass(self.class),
            (void *)self,
            _timeline.debugDescription];
}

#pragma mark - Exceptions

+ (void)_raiseEmptyTimelineAnimationException {
    @throw [NSException exceptionWithName:EmptyTimelineAnimationException
                                   reason:@""
                                 userInfo:nil];
}

@end

#pragma mark - NSCopying

@implementation GroupTimelineEntity (Copying)

- (id)copyWithZone:(NSZone *)zone {
    GroupTimelineEntity *const copy = [[GroupTimelineEntity alloc] initWithTimeline:[_timeline copy]];
    return copy;
}

- (instancetype)copyWithDuration:(NSTimeInterval)newDuration
           shouldAdjustBeginTime:(BOOL)adjust
             usingTotalBeginTime:(RelativeTime)totalBeginTime {

    const NSTimeInterval oldDuration = self.timeline.duration;
    const NSTimeInterval factor      = newDuration / oldDuration;

    __kindof TimelineAnimation *const timelineAnimation = [self.timeline timelineWithDuration:newDuration];

    GroupTimelineEntity *const entity = [[GroupTimelineEntity alloc] initWithTimeline:timelineAnimation];
    if (adjust) {
        entity.timeline.beginTime = totalBeginTime + ((self.timeline.beginTime - totalBeginTime) * factor);
    }
    if (newDuration < TimelineAnimationMillisecond) {
        NSAssert((NSInteger)Round(entity.timeline.duration) == (NSInteger)Round(TimelineAnimationMillisecond),
                 @"TimelineAnimations: Something is wrong with the timeline's duration.");
        entity.timeline.beginTime = MAX(entity.beginTime - TimelineAnimationMillisecond, 0);
    }
    return entity;
}

@end

#pragma mark - Reverse

@implementation GroupTimelineEntity (Reverse)

- (instancetype)reversedCopyWithDuration:(NSTimeInterval)duration {
    GroupTimelineEntity *const reversedCopy = [self copy];
    NSTimeInterval newDuration = duration;
    if ([_timeline isKindOfClass:[GroupTimelineAnimation class]]) {
        newDuration = _timeline.duration;
    }
    reversedCopy.timeline = [_timeline reversedWithDuration:newDuration];
    reversedCopy.timeline.groupTimelineEntity = reversedCopy;
    return reversedCopy;
}

@end

#pragma mark - Public methods

@implementation GroupTimelineEntity (Control)

#ifdef DEBUG
#define _raise(e) ([GroupTimelineEntity _raiseEmptyTimelineAnimationException])
#else
#define _raise(e) {}
#endif

- (void)playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
               afterReverse:(nullable __kindof TimelineAnimation *)revereseTimeline
                    onStart:(TimelineAnimationOnStartBlock)callerOnStart
                 onComplete:(TimelineAnimationCompletionBlock)callerCompletion {

    NSParameterAssert(callerOnStart);
    NSParameterAssert(callerCompletion);

    if (_cleared) {
        _raise(EmptyTimelineAnimationException);
        return; // do not replay clear entities
    }

    {
        TimelineAnimationOnStartBlock userOnStart = [_timeline.onStart copy];
        
        __weak typeof(self) welf           = self;
        __weak typeof(_timeline) wtimeline = _timeline;
        
        
        
        [_timeline _setOnStart:^{
            __strong typeof(welf) strelf = welf;
            __strong typeof(wtimeline) stimeline = wtimeline;
            guard (strelf != nil) else { _raise(EmptyTimelineAnimationException); return; }
            guard (stimeline != nil) else { _raise(EmptyTimelineAnimationException); return; }
            guard (strelf.cleared == NO) else { _raise(EmptyTimelineAnimationException); return; }
            
            if (callerOnStart) {
                callerOnStart();
            }
            
            if (userOnStart) {
                userOnStart();
            }
            
            [stimeline _setOnStart:userOnStart];
        }];
    }

    {
        __weak typeof(self) welf           = self;
        __weak typeof(_timeline) wtimeline = _timeline;
        
        TimelineAnimationCompletionBlock userCompletion = [_timeline.completion copy];
        [_timeline _setCompletion:^(BOOL result) {
            __strong typeof(wtimeline) stimeline = wtimeline;
            __strong typeof(welf) strelf = welf;
            guard (strelf != nil) else { _raise(EmptyTimelineAnimationException); return; }
            guard (stimeline != nil) else { _raise(EmptyTimelineAnimationException); return; }
            guard (strelf.cleared == NO) else { _raise(EmptyTimelineAnimationException); return; }
            
            if (userCompletion) {
                userCompletion(result);
            }
            
            if (callerCompletion) {
                callerCompletion(result);
            }
            
            [stimeline _setCompletion:userCompletion];
        }];
    }

    if (revereseTimeline) {

        {
            __weak typeof(self) welf           = self;
            __weak typeof(_timeline) wtimeline = _timeline;
            TimelineAnimationReverseCoordinator *coordinator = [[TimelineAnimationReverseCoordinator alloc] initWithTimeline:revereseTimeline
                                                                                completion:^(__kindof TimelineAnimation * _Nonnull timeline) {
                                                                                    __strong typeof(self) strelf = welf;
                                                                                    __strong typeof(wtimeline) stimeline = wtimeline;
                                                                                    [stimeline play];
                                                                                    strelf.TimelineAnimationReverseCoordinator = nil;
                                                                                }];
            self.TimelineAnimationReverseCoordinator = coordinator;
        }
    } else {
        [_timeline _playWithCurrentTime:currentTime];
    }
}

- (void)playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
                    onStart:(TimelineAnimationOnStartBlock)onStart
                 onComplete:(TimelineAnimationCompletionBlock)complete {
    [self playWithCurrentTime:currentTime
                 afterReverse:nil
                      onStart:onStart
                   onComplete:complete];
}

- (void)reset {
    [_timeline reset];
}

- (void)pauseWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyPausedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)pausedLayers {
    [_timeline pauseWithCurrentTime:currentTime
                alreadyPausedLayers:pausedLayers];
}

- (void)resumeWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyResumedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)resumedLayers {
    [_timeline resumeWithCurrentTime:currentTime
                alreadyResumedLayers:resumedLayers];
}

- (void)clear {
    _cleared = YES;

    [_timeline clear];
}

@end
