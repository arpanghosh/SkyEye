//
//  SkyEyeGimbalManager.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//


@interface SkyEyeGimbalManager : NSObject <FYXServiceDelegate, FYXVisitDelegate>

+(instancetype)sharedSkyEyeGimbalManager;

-(void)startSightingGimbalBeaconsWithDelagate:(id<SkyEyeBeaconDelegate>)delegate
                             andSmoothingMode:(int)smoothingMode;

-(void)stopSightingGimbalBeacons;

@end
