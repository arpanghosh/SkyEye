//
//  SkyEyeHeadingManager.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeHeadingManager.h"

@interface SkyEyeHeadingManager()

@property (nonatomic, strong) CLLocationManager *headingManager;
@property (nonatomic) BOOL headingTrackingActive;
@property (nonatomic, weak) id<SkyEyeMotionDelegate> headingDelegate;

@end


@implementation SkyEyeHeadingManager

+ (id)sharedSkyEyeHeadingManager {
    static SkyEyeHeadingManager *sharedSkyEyeHeadingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSkyEyeHeadingManager = [[self alloc] init];
    });
    return sharedSkyEyeHeadingManager;
}

- (id)init {
    if (self = [super init]) {
        _headingTrackingActive = NO;
        _headingManager = [[CLLocationManager alloc] init];
        _headingManager.delegate = self;
        _headingManager.activityType = CLActivityTypeFitness;
        _headingManager.headingFilter = SKYEYE_HEADING_UPDATE_THRESHOLD;
    }
    return self;
}

- (void)startTrackingHeadingWithDelegate:(id<SkyEyeMotionDelegate>)delegate{
    if (!self.headingTrackingActive){
        self.headingDelegate = delegate;
        [self.headingManager startUpdatingHeading];
        self.headingTrackingActive = YES;
    }
}

- (void)stopTrackingHeading{
    if (self.headingTrackingActive){
        [self.headingManager stopUpdatingHeading];
        self.headingTrackingActive = NO;
    }
}


# pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.headingDelegate errorFetchingHeading:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    NSLog(@"Heading updated");
    [self.headingDelegate headingUpdated:newHeading timestamp:newHeading.timestamp];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    return YES;
}


@end
