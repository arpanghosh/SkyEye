//
//  SkyEyeBeaconDelegate.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//


@protocol SkyEyeBeaconDelegate <NSObject>

-(void)sightedBeacon:(NSString *)transmitterName RSSI:(NSNumber *)rssi timestamp:(NSDate *)timestamp;

-(void)errorSightingBeacons:(NSError *)error;

@end
