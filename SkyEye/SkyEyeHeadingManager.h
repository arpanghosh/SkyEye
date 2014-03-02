//
//  SkyEyeHeadingManager.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//


@interface SkyEyeHeadingManager : NSObject <CLLocationManagerDelegate>

+ (id)sharedSkyEyeHeadingManager;

- (void)startTrackingHeadingWithDelegate:(id<SkyEyeMotionDelegate>)delegate;

- (void)stopTrackingHeading;

@end
