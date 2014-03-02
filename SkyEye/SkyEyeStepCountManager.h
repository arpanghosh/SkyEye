//
//  SkyEyeStepCountManager.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//


@interface SkyEyeStepCountManager : NSObject

+ (id)sharedSkyEyeStepCountManager;

- (void)startTrackingUserStepCountWithDelegate:(id<SkyEyeMotionDelegate>)delegate;

- (void)stopTrackingUserStepCount;

@end
