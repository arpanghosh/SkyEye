//
//  SkyEyeStepCountManager.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#import "SkyEyeMotionDelegate.h"

@interface SkyEyeStepCountManager : NSObject

+ (id)sharedSkyEyeStepCountManager;

- (void)startTrackingUserStepCountWithDelegate:(id<SkyEyeMotionDelegate>)delegate;

- (void)stopTrackingUserStepCount;

@end
