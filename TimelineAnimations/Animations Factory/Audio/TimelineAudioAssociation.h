//
// Created by Georges Boumis on 15/12/2016.
// Copyright (c) 2016 AbZorba Games. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface TimelineAudioAssociation : NSObject<NSCopying>
+ (instancetype)onStart;
+ (instancetype)onMid;
+ (instancetype)onCompletion;
+ (instancetype)atTime:(NSTimeInterval)time;
@end

NS_ASSUME_NONNULL_END
