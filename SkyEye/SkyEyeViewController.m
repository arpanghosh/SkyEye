//
//  SkyEyeViewController.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeViewController.h"
#import <FYX/FYXTransmitter.h>

@interface SkyEyeViewController ()
@property (nonatomic) FYXVisitManager *visitManager;

@end

@implementation SkyEyeViewController

@synthesize visitManager=_visitManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     [FYX startService:self];
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
- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI received a sighting!!! %@, RSSI:%@", visit.transmitter.name, RSSI];
}
- (void)didDepart:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name];
    self.status.text = [self.status.text stringByAppendingFormat:@"\nI was around the beacon for %f seconds", visit.dwellTime];
}


@end
