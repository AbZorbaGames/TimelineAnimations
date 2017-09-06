//
//  TimelineAnimationAudioExtension.swift
//  TimelineAnimations
//
//  Created by Georges Boumis on 11/01/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

import Foundation

public extension TimelineAnimation {
    
    /// An Audio Association in a TimelineAnimation
    public enum AudioAssociation {
        /// associated with the start of the timeline
        case start
        /// associated with the middle of the timeline
        case mid
        /// associated at an arbitrary time, it should be less than the 
        /// `.endTime` of the TimelineAnimation.
        case time(RelativeTime)
        /// associated with the end of the timeline
        case completion
    }

    /**
     Associate an audio to be played with the timeline animation.

     - Parameter audio: the sound to be play at the given association
     - Parameter association: how to associate the audio with the timeline animation.
     */
    final public func associate(timelineAudio audio: TimelineAudio,
                                at association: TimelineAnimation.AudioAssociation = TimelineAnimation.AudioAssociation.start) {
        self.__associateAudio(audio,
                              usingTime: association.objc)
    }
    
    final public func disassociateAudio(at association: TimelineAnimation.AudioAssociation) {
        self.__disassociateAudio(atTime: association.objc)
    }
    
    final public func disassociate(audio: TimelineAudio) {
        self.__disassociateAudio(audio)
    }
}

fileprivate extension TimelineAnimation.AudioAssociation {
    fileprivate var objc: __TimelineAudioAssociation {
        var assoc: __TimelineAudioAssociation!
        switch self {
        case TimelineAnimation.AudioAssociation.start:
            assoc = __TimelineAudioAssociation.onStart
        case TimelineAnimation.AudioAssociation.mid:
            assoc = __TimelineAudioAssociation.onMid
        case TimelineAnimation.AudioAssociation.completion:
            assoc = __TimelineAudioAssociation.onCompletion
        case TimelineAnimation.AudioAssociation.time(let t):
            assoc = __TimelineAudioAssociation.atTime(t)
        }
        return assoc
    }
}
