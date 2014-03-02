//
//  SkyEyeGimbalManager.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeGimbalManager.h"

@interface SkyEyeGimbalManager()

@property (nonatomic, strong) FYXVisitManager *gimbalVisitManager;
@property (nonatomic) BOOL gimbalServiceActive;
@property (nonatomic, weak) id<SkyEyeBeaconDelegate> beaconSightingDelegate;
@property (nonatomic) int smoothingMode;

@end


@implementation SkyEyeGimbalManager

+(instancetype)sharedSkyEyeGimbalManager{
    static SkyEyeGimbalManager *sharedSkyEyeGimbalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSkyEyeGimbalManager = [[self alloc] init];
    });
    return sharedSkyEyeGimbalManager;
}


- (id)init {
    if (self = [super init]) {
        [FYX setAppId:SKYEYE_GIMBAL_APP_ID
            appSecret:SKYEYE_GIMBAL_APP_SECRET
          callbackUrl:@"skyeye://authcode"];
        
        _gimbalVisitManager = [FYXVisitManager new];
        _gimbalVisitManager.delegate = self;
        _gimbalServiceActive = NO;
    }
    return self;
}

-(void)startSightingGimbalBeaconsWithDelagate:(id<SkyEyeBeaconDelegate>)delegate
                             andSmoothingMode:(int)smoothingMode{
    if (!self.gimbalServiceActive) {
        self.beaconSightingDelegate = delegate;
        self.smoothingMode = smoothingMode;
        [FYX startService:self];
    }
}

-(void)stopSightingGimbalBeacons{
    if (self.gimbalServiceActive) {
        [self.gimbalVisitManager stop];
        [FYX stopService];
        self.gimbalServiceActive = NO;
    }
}


#pragma mark - FYXServiceDelegate Methods

-(void)serviceStarted{
    self.gimbalServiceActive = YES;
    [self.gimbalVisitManager startWithOptions:@{FYXSightingOptionSignalStrengthWindowKey: [NSNumber numberWithInt:                      self.smoothingMode],
                                                FYXVisitOptionArrivalRSSIKey: [NSNumber numberWithInt:SKYEYE_GIMBAL_REGION_THRESHOLD_RSSI],
                                                FYXVisitOptionDepartureRSSIKey: [NSNumber numberWithInt:SKYEYE_GIMBAL_REGION_THRESHOLD_RSSI]}];
}

-(void)startServiceFailed:(NSError *)error{
    [self.beaconSightingDelegate errorSightingBeacons:error];
}

#pragma mark - FYXVisitDelegate Methods

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI {
    [self.beaconSightingDelegate sightedBeacon:visit.transmitter.name RSSI:RSSI timestamp:updateTime];
}
@end
