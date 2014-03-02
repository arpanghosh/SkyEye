//
//  SkyEyeMotionDelegate.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol SkyEyeMotionDelegate <NSObject>

-(void)stepCountUpdated:(NSInteger)stepCount timestamp:(NSDate *)timestamp;

-(void)errorFetchingStepCount:(NSError *)error;

@end
