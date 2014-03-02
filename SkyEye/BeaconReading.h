//
//  BeaconReading.h
//  SkyEye
//
//  Created by Charlie Federspiel on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconReading : NSObject
{
    NSString *beaconName;
    double _signalStrength;
    NSDate *timestamp;
}
@property (strong, nonatomic) NSString *beaconName;
@property double signalStrength;
@property (strong, nonatomic) NSDate *timestamp;
@end
