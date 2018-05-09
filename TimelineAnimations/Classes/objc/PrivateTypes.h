//
//  PrivateTypes.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 04/07/2017.
//
//

#ifndef guard
#define guard(cond) if ((cond)) {}
#endif /* guard */

#ifndef not
#define not(expression) (!(expression))
#endif /* not */

#ifndef Round
#define Round(t) ((double)((unsigned long long)round((double)t * 1000.0)) / 1000.0)
#endif /* Round */


#define TIMELINE_ANIMATION_NO_RETURN __attribute__ ((noreturn));
#define SortKey(s) (NSStringFromSelector(@selector((s))))

@class TimelineAnimationNotifyBlockInfo;
#import "Types.h"

typedef NSNumber ProgressNumber; // float
typedef NSMutableDictionary<ProgressNumber *, TimelineAnimationNotifyBlock> ProgressNotificationAssociations; // [Float<0..1>: TimelineAnimationNotifyBlock]
typedef NSNumber RelativeTimeNumber;// relative time -> double
typedef NSMutableDictionary<RelativeTimeNumber *, NSMutableArray<TimelineAnimationNotifyBlockInfo *> *> NotificationAssociations; // [RelativeTime: [NotifyInfoBlock]]

typedef RelativeTimeNumber *_Nonnull (^TimeNotificationCalculation)(RelativeTimeNumber *_Nonnull);

typedef CFTimeInterval(^TimelineAnimationCurrentMediaTimeBlock)(void);
