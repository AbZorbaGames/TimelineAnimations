//
//  CAKeyframeAnimationAHEasingExtensions.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 05/12/2017.
//

import Foundation

public extension CAKeyframeAnimation {
    
    final public class func animation(keyPath: AnimationKeyPath,
                                      function: AHEasingFunction,
                                      from: AnimationsFactory.TypedValue,
                                      to: AnimationsFactory.TypedValue,
                                      delegate: CAAnimationDelegate? = nil,
                                      keyframeCount: size_t = size_t(60)) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath.rawValue)
        animation.values = self.values(from: from,
                                       to: to,
                                       function: function,
                                       keyframeCount: keyframeCount)
        animation.delegate = delegate
        return animation
    }
    
    final private class func values(from: AnimationsFactory.TypedValue,
                                    to: AnimationsFactory.TypedValue,
                                    function: AHEasingFunction,
                                    keyframeCount: size_t) -> [Any] {
        switch (from, to) {
        case (AnimationsFactory.TypedValue.point(let f), AnimationsFactory.TypedValue.point(let t)):
            return self.values(from: f, to: t, function: function, keyframeCount: keyframeCount)
            
        case (AnimationsFactory.TypedValue.value(let f), AnimationsFactory.TypedValue.value(let t)):
            return self.values(from: f, to: t, function: function, keyframeCount: keyframeCount)
            
        case (AnimationsFactory.TypedValue.float(let f), AnimationsFactory.TypedValue.float(let t)):
            return self.values(from: CGFloat(f), to: CGFloat(t), function: function, keyframeCount: keyframeCount)
            
        case (AnimationsFactory.TypedValue.size(let f), AnimationsFactory.TypedValue.size(let t)):
            return self.values(from: f, to: t, function: function, keyframeCount: keyframeCount)
            
        case (AnimationsFactory.TypedValue.transform(let f), AnimationsFactory.TypedValue.transform(let t)):
            return self.values(from: f, to: t, function: function, keyframeCount: keyframeCount)
            
        case (AnimationsFactory.TypedValue.frame(let f), AnimationsFactory.TypedValue.frame(let t)):
            return self.values(from: f, to: t, function: function, keyframeCount: keyframeCount)
            
        default: return []
        }
    }
    
    final private class func values(from: CGFloat,
                                    to: CGFloat,
                                    function: AHEasingFunction,
                                    keyframeCount: size_t) -> [Any] {
        var t = CGFloat(0.0)
        let dt = CGFloat(1.0)/CGFloat((keyframeCount-1))
        let diff = to - from
        
        var values: [CGFloat] = Array()
        values.reserveCapacity(Int(keyframeCount))
        for _ in stride(from: 0, to: keyframeCount, by: 1) {
            let value = from + CGFloat(function(Double(t))) * diff
            values.append(value)
            t += dt
        }
        return values
    }
    
    final private class func values(from: CGPoint,
                                    to: CGPoint,
                                    function: AHEasingFunction,
                                    keyframeCount: size_t) -> [Any] {
        var t = CGFloat(0.0)
        let dt = CGFloat(1.0)/CGFloat((keyframeCount-1))
        let xDiff = to.x - from.x
        let yDiff = to.y - from.y
        
        var values: [NSValue] = Array()
        values.reserveCapacity(Int(keyframeCount))
        for _ in stride(from: 0, to: keyframeCount, by: 1) {
            let value = CGFloat(function(Double(t)))
            let x = from.x + value * xDiff
            let y = from.y + value * yDiff
            values.append(NSValue(cgPoint: CGPoint(x: x, y: y)))
            t += dt
        }
        return values
    }
    
    final private class func values(from: CGSize,
                                    to: CGSize,
                                    function: AHEasingFunction,
                                    keyframeCount: size_t) -> [Any] {
        var t = CGFloat(0.0)
        let dt = CGFloat(1.0)/CGFloat((keyframeCount-1))
        let widthDiff  = to.width - from.width
        let heightDiff = to.height - from.height
        
        var values: [NSValue] = Array()
        values.reserveCapacity(Int(keyframeCount))
        for _ in stride(from: 0, to: keyframeCount, by: 1) {
            let value = CGFloat(function(Double(t)))
            let width = from.width + value * widthDiff
            let height = from.height + value * heightDiff
            values.append(NSValue(cgSize: CGSize(width: width, height: height)))
            t += dt
        }
        return values
    }
    
    final private class func values(from f: CATransform3D,
                                    to t : CATransform3D,
                                    function: AHEasingFunction,
                                    keyframeCount: size_t) -> [Any] {
        
        let from = CATransform3DGetAffineTransform(f)
        let to   = CATransform3DGetAffineTransform(t)
        
        let fromTranslation = CGPoint(x: from.tx, y: from.ty)
        let toTranslation   = CGPoint(x: to.tx, y: to.ty)
        
        let xTranslationDiff = toTranslation.x - fromTranslation.x
        let yTranslationDiff = toTranslation.y - fromTranslation.y
        
        let fromScale = CGFloat(hypot(Double(from.a), Double(from.c)))
        let toScale   = CGFloat(hypot(Double(to.a), Double(to.c)))
        let scaleDiff = toScale - fromScale
        
        let fromRotation = CGFloat(atan2(Double(from.c), Double(from.a)))
        let toRotation   = CGFloat(atan2(Double(to.c), Double(to.a)))
        
        var deltaRotation = toRotation - fromRotation
        if deltaRotation < -CGFloat.pi {
            deltaRotation += CGFloat.pi * 2
        }
        else if deltaRotation > CGFloat.pi {
            deltaRotation -= CGFloat.pi * 2
        }
        
        var t = CGFloat(0.0)
        let dt = CGFloat(1.0)/CGFloat((keyframeCount-1))
        
        var values: [NSValue] = Array()
        values.reserveCapacity(Int(keyframeCount))
        for _ in stride(from: 0, to: keyframeCount, by: 1) {
            let interp = CGFloat(function(Double(t)))
            let scale  = fromScale + interp * scaleDiff
            let rotate = fromRotation + interp * deltaRotation
            
            let translateX = fromTranslation.x + interp * xTranslationDiff
            let translateY = fromTranslation.y + interp * yTranslationDiff
            
            let transform = CGAffineTransform(a: scale * cos(rotate),
                                              b: -scale * sin(rotate),
                                              c: scale * sin(rotate),
                                              d: scale * cos(rotate),
                                              tx: translateX,
                                              ty: translateY)
            let transform3D = CATransform3DMakeAffineTransform(transform)
            values.append(NSValue(caTransform3D: transform3D))
            t += dt
        }
        return values
    }
    
    
    final private class func values(from: CGRect,
                                    to: CGRect,
                                    function: AHEasingFunction,
                                    keyframeCount: size_t) -> [Any] {
        var t = CGFloat(0.0)
        let dt = CGFloat(1.0)/CGFloat((keyframeCount-1))
        
        let widthDiff  = to.size.width - from.size.width
        let heightDiff = to.size.height - from.size.height
        
        let xDiff = to.origin.x - from.origin.x
        let yDiff = to.origin.y - from.origin.y
        
        var values: [NSValue] = Array()
        values.reserveCapacity(Int(keyframeCount))
        for _ in stride(from: 0, to: keyframeCount, by: 1) {
            let value = CGFloat(function(Double(t)))
            let x = from.origin.x + value * xDiff
            let y = from.origin.y + value * yDiff
            let width = from.size.width + value * widthDiff
            let height = from.size.height + value * heightDiff
            values.append(NSValue(cgRect: CGRect(x: x, y: y, width: width, height: height)))
            t += dt
        }
        return values
    }
}
