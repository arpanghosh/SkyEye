//
//  SkyEyeViewController.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeViewController.h"
#import <FYX/FYXTransmitter.h>
#import "BeaconReading.h"

@interface SkyEyeViewController ()
@property (nonatomic) FYXVisitManager *visitManager;

@end

@implementation SkyEyeViewController

@synthesize visitManager=_visitManager;



- (void)viewDidLoad
{
    [super viewDidLoad];
    beaconReadings = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
     [FYX startService:self];
    [[SkyEyeStepCountManager sharedSkyEyeStepCountManager] startTrackingUserStepCountWithDelegate:self];
    droneManager = [[SkyEyeDroneManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gimbal service

- (void)serviceStarted
{
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    self.status.text = [self.status.text stringByAppendingString:@"FYX Service Successfully Started"];
    self.visitManager = [FYXVisitManager new];
    self.visitManager.delegate = self;
    [self.visitManager start];

}

- (void)startServiceFailed:(NSError *)error
{
    // this will be called if the service has failed to start
    self.status.text = [self.status.text stringByAppendingFormat:@"Error: %@", error];
}

#pragma mark - Gimbal bluetooth scan

- (void)didArrive:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI arrived at a Gimbal Beacon!!! %@", visit.transmitter.name];
}
- (double) calculateMean:(NSArray *)readings offset:(unsigned long)offset count:(int)count;
{
    double mean = 0;
    if([readings count] < count) {
        return 0;
    }
    for(unsigned long i = [readings count] - count; i < [readings count]; i++) {
        BeaconReading *currentReading = [readings objectAtIndex:i];
        mean += currentReading.signalStrength;
    }
    return mean/count;
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI received a sighting!!! %@ RSSI:%@", visit.transmitter.name, RSSI];
    
    BeaconReading *r = [[BeaconReading alloc] init];
    [r setBeaconName:visit.transmitter.name];
    [r setSignalStrength:[RSSI doubleValue]];
    [r setTimestamp:updateTime];
    
    [beaconReadings addObject:r];
    
    double mean = [self calculateMean:beaconReadings offset:[beaconReadings count] - 10 count:10];
    NSLog(@"Mean is: %f", mean);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:RSSI forKey:@"beaconData"];
    [dict setObject:visit.transmitter.name forKey:@"beaconID"];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"beaconData" withData:dict];
    
}
- (void)didDepart:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name];
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI was around the beacon for %f seconds", visit.dwellTime];
}

-(void)stepCountUpdated:(NSInteger)stepCount timestamp:(NSDate *)timestamp{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInteger:stepCount] forKey:@"stepCount"];
    [dict setObject:[NSNumber numberWithDouble:[timestamp timeIntervalSince1970]] forKey:@"stepTimestamp"];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"stepData" withData:dict];
}

-(void)errorFetchingStepCount:(NSError *)error{
    NSLog(@"Error getting step count : %@", error);
}




@end
