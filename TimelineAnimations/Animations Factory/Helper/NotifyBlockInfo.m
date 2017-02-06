//
// Created by Georges Boumis on 15/12/2016.
// Copyright (c) 2016 AbZorba Games. All rights reserved.
//

#import "NotifyBlockInfo.h"
#import "TimelineAudio.h"

@implementation NotifyBlockInfo

+ (instancetype)infoWithBlock:(NotifyBlock)block isSoundNotification:(BOOL)isSound {
    return [[NotifyBlockInfo alloc] initWithBlock:block isSoundNotification:isSound];
}

- (instancetype)initWithBlock:(NotifyBlock)block isSoundNotification:(BOOL)isSound {
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
    [self.previous call:mute];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p; ", NSStringFromClass([self class]), self];
    [description appendFormat:@"self.soundNotification = %d; ", self.soundNotification];
    [description appendFormat:@"self.sound = %@; ", self.sound.description];
    [description appendFormat:@"self.previous = %@;", self.previous];
    [description appendString:@">"];
    return description;
}

@end
