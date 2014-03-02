//
//  SkyEyeHeadingManager.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeHeadingManager.h"

typedef enum{
    waitingForFirstHeading = 0,
    listeningForSignificantHeading = 1,
    foundSteadyHeading = 2
}SkyEyeHeadingDetectionState;


@interface SkyEyeHeadingManager()

@property (nonatomic, strong) CLLocationManager *headingManager;
@property (nonatomic) BOOL headingTrackingActive;
@property (nonatomic, weak) id<SkyEyeMotionDelegate> headingDelegate;
@property (atomic, strong) NSMutableArray *headingStream;
@property (nonatomic, strong) NSTimer *headingAverageTimer;
@property (nonatomic) SkyEyeHeadingDetectionState state;
@property (nonatomic) double significantHeading;
@property (nonatomic) double runningHeading;
@property (nonatomic) NSInteger steadyStateCounter;

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
        _headingManager.headingFilter = kCLHeadingFilterNone;
        _headingStream = [[NSMutableArray alloc] init];
        _state = waitingForFirstHeading;
        _steadyStateCounter = 0;
    }
    return self;
}

- (void)startTrackingHeadingWithDelegate:(id<SkyEyeMotionDelegate>)delegate{
    if (!self.headingTrackingActive){
        self.headingDelegate = delegate;
        [self.headingManager startUpdatingHeading];
        self.headingAverageTimer = [NSTimer timerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(processNewHeadingData:)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.headingAverageTimer forMode:NSDefaultRunLoopMode];
        self.headingTrackingActive = YES;
    }
}

-(void)processNewHeadingData:(NSTimer *)theTimer
{
    double averageHeading;
    @synchronized(self.headingStream){
        averageHeading = [self averageHeadingWindow];
    }
    /*
    NSLog(@"Avg. heading readings : %f", averageHeading);
    NSLog(@"Significant Heading : %f", self.significantHeading);
    NSLog(@"Running Heading : %f", self.runningHeading);
    NSLog(@"State : %d", self.state);
    */
    switch (self.state) {
        case waitingForFirstHeading:
            self.significantHeading = averageHeading;
            self.runningHeading = averageHeading;
            self.state = listeningForSignificantHeading;
            break;
        case listeningForSignificantHeading:
            self.runningHeading = averageHeading;
            if (fabs(averageHeading - self.runningHeading) < SKYEYE_HEADING_UPDATE_THRESHOLD) {
                self.steadyStateCounter++;
                if (self.steadyStateCounter > SKYEYE_HEADING_STEADY_STATE_WINDOW) {
                    self.state = foundSteadyHeading;
                    self.steadyStateCounter = 0;
                }
            }
            break;
        case foundSteadyHeading:
            if (fabs(self.significantHeading - self.runningHeading) > SKYEYE_HEADING_UPDATE_THRESHOLD) {
                [self.headingDelegate headingUpdated:self.runningHeading timestamp:[NSDate date]];
            }
            self.significantHeading = self.runningHeading;
            self.state = listeningForSignificantHeading;
            break;
        default:
            break;
    }
}


-(double)averageHeadingWindow{
    NSNumber *headingSum = Underscore.array(self.headingStream)
    .reduce([NSNumber numberWithDouble:0.0], ^(NSNumber *x, NSNumber *y) {
        return @(x.doubleValue + y.doubleValue);
    });
    double averageHeading = [headingSum doubleValue]/[self.headingStream count];
    
    [self.headingStream removeAllObjects];
    return averageHeading;
}


- (void)stopTrackingHeading{
    if (self.headingTrackingActive){
        [self.headingAverageTimer invalidate];
        [self.headingManager stopUpdatingHeading];
        self.headingTrackingActive = NO;
    }
}


# pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.headingDelegate errorFetchingHeading:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    @synchronized(self.headingStream){
        [self.headingStream addObject:[NSNumber numberWithDouble:newHeading.magneticHeading]];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    return YES;
}


@end
