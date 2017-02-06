//
//  AnimationsKeyPath.m
//
//  Created by AbZorba Games on 08/09/2015.
//  Copyright (c) 2015-2016 AbZorba Games. All rights reserved.
//

#import "AnimationsKeyPath.h"

AnimationKeyPath kAnimationKeyPathPosition      = @"position"; // CGPoint
AnimationKeyPath kAnimationKeyPathPositionX     = @"position.x"; // CGFloat
AnimationKeyPath kAnimationKeyPathPositionY     = @"position.y"; // CGFloat
AnimationKeyPath kAnimationKeyPathWidth         = @"bounds.size.width"; // CGFloat
AnimationKeyPath kAnimationKeyPathHeight        = @"bounds.size.height"; // CGFloat
AnimationKeyPath kAnimationKeyPathFrame         = @"frame"; // CGRect

AnimationKeyPath kAnimationKeyPathTransform     = @"transform"; // CATransform3D

AnimationKeyPath kAnimationKeyPathRotation      = @"transform.rotation"; // CGFloat in radians

AnimationKeyPath kAnimationKeyPathScale         = @"transform.scale"; // CGFloat?
AnimationKeyPath kAnimationKeyPathScaleX        = @"transform.scale.x"; // CGFloat
AnimationKeyPath kAnimationKeyPathScaleY        = @"transform.scale.y"; // CGFloat

AnimationKeyPath kAnimationKeyPathOpacity       = @"opacity"; // CGFloat

AnimationKeyPath kAnimationKeyPathShadowOpacity = @"shadowOpacity"; // CGFloat
