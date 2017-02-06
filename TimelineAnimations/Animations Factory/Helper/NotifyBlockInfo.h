//
// Created by Georges Boumis on 15/12/2016.
// Copyright (c) 2016 AbZorba Games. All rights reserved.
//

@import Foundation;
#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotifyBlockInfo : NSObject

@property (nonatomic, readonly, getter=isSoundNotification) BOOL soundNotification;
@property (nonatomic, nullable, weak) id<TimelineAudio> sound;
@property (nonatomic, copy, readonly) NotifyBlock block;
@property (nonatomic, strong) NotifyBlockInfo *_Nullable previous;

+ (instancetype)infoWithBlock:(NotifyBlock)block
          isSoundNotification:(BOOL)isSound;

- (void)call:(BOOL)mute;

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
