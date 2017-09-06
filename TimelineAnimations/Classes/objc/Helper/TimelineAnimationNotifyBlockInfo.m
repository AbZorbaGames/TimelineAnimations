//
// TimelineAnimationNotifyBlockInfo.m
// TimelineAnimations
//
// Created by Georges Boumis on 15/12/2016.
// Copyright (c) 2016-2017 AbZorba Games. All rights reserved.
//

#import "TimelineAnimationNotifyBlockInfo.h"
#import "TimelineAudio.h"
#import "Types.h"

@implementation TimelineAnimationNotifyBlockInfo

+ (instancetype)infoWithBlock:(TimelineAnimationNotifyBlock)block isSoundNotification:(BOOL)isSound {
    return [[TimelineAnimationNotifyBlockInfo alloc] initWithBlock:block isSoundNotification:isSound];
}

- (instancetype)initWithBlock:(TimelineAnimationNotifyBlock)block isSoundNotification:(BOOL)isSound {
    self = [super init];
    if (self) {
        _block = [block copy];
        _soundNotification = isSound;
    }
    return self;
}

- (void)call:(BOOL)mute {
    if (self.isSoundNotification && mute) {
        return;
    }

    self.block();
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p; ", NSStringFromClass([self class]), self];
    [description appendFormat:@"isSoundNotification = %@; ", @(self.soundNotification).stringValue];
    [description appendFormat:@"sound = %@; ", self.sound.description];
    [description appendString:@">"];
    return description;
}

@end
