//
//  TimelineAudioAssociation.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 15/12/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "TimelineAudioAssociation.h"
#import "TimelineAnimation.h"
#import "TimelineAnimationProtected.h"
#import "TimelineAudioAssociation_Internal.h"


typedef NS_ENUM(NSUInteger, AudioAssociationType) {
    AudioAssociationTypeOnStart,
    AudioAssociationTypeOnMid,
    AudioAssociationTypeOnCompletion,
    AudioAssociationTypeAtTime
};

@interface TimelineAudioAssociation ()
@property (nonatomic, readwrite) AudioAssociationType type;
@property (nonatomic, readwrite) NSTimeInterval time;

- (instancetype)initWithType:(AudioAssociationType)type
                        time:(NSTimeInterval)time NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end

@implementation TimelineAudioAssociation

- (instancetype)init {
    [NSException raise:@"UnsupportedMessage"
                format:@"TimelineAnimations: Use %@ instead.",
     NSStringFromSelector(@selector(initWithType:time:))];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    [NSException raise:@"UnsupportedMessage"
                format:@"TimelineAnimations: Use %@ instead.",
     NSStringFromSelector(@selector(initWithType:time:))];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [NSException raise:@"UnsupportedMessage"
                format:@"TimelineAnimations: Use %@ instead.",
     NSStringFromSelector(@selector(initWithType:time:))];
}


- (instancetype)initWithType:(AudioAssociationType)type
                        time:(NSTimeInterval)time {
    self = [super init];
    if (self) {
        self.type = type;
        self.time = Round(time);
    }
    return self;
}

+ (instancetype)onStart {
    return [[TimelineAudioAssociation alloc] initWithType:AudioAssociationTypeOnStart
                                                     time:0.0];
}

+ (instancetype)onMid {
    return [[TimelineAudioAssociation alloc] initWithType:AudioAssociationTypeOnMid
                                                     time:0.0];
}

+ (instancetype)onCompletion {
    return [[TimelineAudioAssociation alloc] initWithType:AudioAssociationTypeOnCompletion
                                                     time:0.0];
}

+ (instancetype)atTime:(NSTimeInterval)time {
    return [[TimelineAudioAssociation alloc] initWithType:AudioAssociationTypeAtTime
                                                     time:time];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TimelineAudioAssociation *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.type = self.type;
        copy.time = self.time;
    }
    
    return copy;
}

#pragma mark - Hashable

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (other == nil) {
        return NO;
    }
    
    if (![other isKindOfClass:self.class]) {
        return NO;
    }
    
    return [self isEqualToAssociation:other];
}

- (BOOL)isEqualToAssociation:(TimelineAudioAssociation *)association {
    if (self == association) {
        return YES;
    }
    if (association == nil) {
        return NO;
    }
    if (self.type != association.type) {
        return NO;
    }
    if (self.time != association.time) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    return self.type;
}


@end

@implementation TimelineAudioAssociation (Internal)

- (BOOL)isOnStart {
    return (self.type == AudioAssociationTypeOnStart);
}

- (BOOL)isOnCompletion {
    return (self.type == AudioAssociationTypeOnCompletion);
}

- (BOOL)isOnMiddle {
    return (self.type == AudioAssociationTypeOnMid);
}

- (BOOL)isTimeBased {
    return (self.type == AudioAssociationTypeAtTime);
}

- (RelativeTime)timeInTimelineAnimation:(__kindof TimelineAnimation *)timeline {
    RelativeTime time = TimelineAnimationMillisecond;
    switch (self.type) {
        case AudioAssociationTypeOnStart:
            time = timeline.beginTime + TimelineAnimationMillisecond;
            break;
        case AudioAssociationTypeOnMid:
            time = (RelativeTime)Round((timeline.duration * 0.5));
            break;
        case AudioAssociationTypeOnCompletion:
            time = Round(timeline.endTimeWithNoRepeating - TimelineAnimationOneFrame);
            break;
        case AudioAssociationTypeAtTime:
            time = self.time;
            break;
    }
    if (time < TimelineAnimationMillisecond) {
        time = timeline.beginTime + TimelineAnimationMillisecond;
    }
    return time;
}

@end
