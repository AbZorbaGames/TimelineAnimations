//
//  AnimationsKeyPath.m
//  TimelineAnimations
//
//  Created by AbZorba Games on 08/09/2015.
//  Copyright (c) 2015-2016 AbZorba Games. All rights reserved.
//

#import "AnimationsKeyPath.h"

// CALayer
AnimationKeyPath kAnimationKeyPathPosition      = @"position"; // CGPoint
AnimationKeyPath kAnimationKeyPathPositionX     = @"position.x"; // CGFloat
AnimationKeyPath kAnimationKeyPathPositionY     = @"position.y"; // CGFloat
AnimationKeyPath kAnimationKeyPathZposition     = @"zPosition"; // CGFloat
AnimationKeyPath kAnimationKeyPathAnchorPoint   = @"anchorPoint"; // CGPoint
AnimationKeyPath kAnimationKeyPathAnchorPointZ  = @"anchorPointZ"; // CGPoint
AnimationKeyPath kAnimationKeyPathBounds        = @"bounds"; // CGRect
AnimationKeyPath kAnimationKeyPathWidth         = @"bounds.size.width"; // CGFloat
AnimationKeyPath kAnimationKeyPathHeight        = @"bounds.size.height"; // CGFloat
AnimationKeyPath kAnimationKeyPathFrame         = @"frame"; // CGRect
AnimationKeyPath kAnimationKeyPathFrameSize     = @"frame.size"; // CGSize

AnimationKeyPath kAnimationKeyPathTransform         = @"transform"; // CATransform3D
AnimationKeyPath kAnimationKeyPathSublayerTransform = @"sublayerTransform"; // CATransform3D

AnimationKeyPath kAnimationKeyPathRotation      = @"transform.rotation"; // CGFloat in radians
AnimationKeyPath kAnimationKeyPathRotationY     = @"transform.rotation.y"; // CGFloat in radians

AnimationKeyPath kAnimationKeyPathScale         = @"transform.scale"; // CGFloat?
AnimationKeyPath kAnimationKeyPathScaleX        = @"transform.scale.x"; // CGFloat
AnimationKeyPath kAnimationKeyPathScaleY        = @"transform.scale.y"; // CGFloat

AnimationKeyPath kAnimationKeyPathOpacity       = @"opacity"; // CGFloat

AnimationKeyPath kAnimationKeyPathShadowOpacity = @"shadowOpacity"; // CGFloat
AnimationKeyPath kAnimationKeyPathShadowRadius  = @"shadowRadius"; // CGFloat
AnimationKeyPath kAnimationKeyPathShadowOffset  = @"shadowOffset"; // CGSize
AnimationKeyPath kAnimationKeyPathShadowColor   = @"shadowColor"; // CGColor
AnimationKeyPath kAnimationKeyPathShadowPath    = @"shadowPath"; // CGPath

AnimationKeyPath kAnimationKeyPathContents          = @"contents"; // Any
AnimationKeyPath kAnimationKeyPathContentsRect      = @"contentsRect"; // CGRect
AnimationKeyPath kAnimationKeyPathContentsCenter    = @"contentsCenter"; // CGRect
AnimationKeyPath kAnimationKeyPathMasksToBounds     = @"masksToBounds"; // Bool
AnimationKeyPath kAnimationKeyPathIsDoubleSided     = @"isDoubleSided"; // Bool
AnimationKeyPath kAnimationKeyPathCornerRadius      = @"cornerRadius"; // CGFloat
AnimationKeyPath kAnimationKeyPathBorderWidth       = @"borderWidth"; // CGFloat
AnimationKeyPath kAnimationKeyPathBorderColor       = @"borderColor"; // CGColor
AnimationKeyPath kAnimationKeyPathIsHidden          = @"isHidden"; // CGColor
AnimationKeyPath kAnimationKeyPathBackgroundColor   = @"backgroundColor"; // CGColor

AnimationKeyPath kAnimationKeyPathFilters           = @"filters"; // [CIFilter]
AnimationKeyPath kAnimationKeyPathCompositingFilter = @"compositingFilter"; // CIFilter
AnimationKeyPath kAnimationKeyPathBackgroundFilters = @"backgroundFilters"; // [CIFilter]

AnimationKeyPath kAnimationKeyPathShouldRasterize   = @"shouldRasterize"; // Bool

// CAEmitterLayer
AnimationKeyPath kAnimationKeyPathEmitterPosition   = @"emitterPosition"; // CGPoint
AnimationKeyPath kAnimationKeyPathEmitterZposition  = @"emitterZPosition"; // CGFloat
AnimationKeyPath kAnimationKeyPathEmitterSize       = @"emitterSize"; // CGSize
AnimationKeyPath kAnimationKeyPathSpin              = @"spin"; // Float
AnimationKeyPath kAnimationKeyPathVelocity          = @"velocity"; // Float
AnimationKeyPath kAnimationKeyPathBirthRate         = @"birthRate"; // Float
AnimationKeyPath kAnimationKeyPathLifetime          = @"lifetime"; // Float

// CAShapeLayer
AnimationKeyPath kAnimationKeyPathFillColor         = @"fillColor"; // CGColor
AnimationKeyPath kAnimationKeyPathStrokeColor       = @"strokeColor"; // CGColor
AnimationKeyPath kAnimationKeyPathLineDashPhase     = @"lineDashPhase"; // CGFloat
AnimationKeyPath kAnimationKeyPathLineWidth         = @"lineWidth"; // CGFloat
AnimationKeyPath kAnimationKeyPathMisterLimit       = @"misterLimit"; // CGFloat
AnimationKeyPath kAnimationKeyPathStrokeEnd         = @"strokeEnd"; // CGFloat
AnimationKeyPath kAnimationKeyPathStrokeStart       = @"strokeStart"; // CGFloat
AnimationKeyPath kAnimationKeyPathPath              = @"path"; // CGPath

// CATextLayer
AnimationKeyPath kAnimationKeyPathFontSize          = @"fontSize"; // CGFloat
AnimationKeyPath kAnimationKeyPathForegroundColor   = @"foregroundColor"; // CGColor
