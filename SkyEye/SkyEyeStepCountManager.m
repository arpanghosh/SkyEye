//
//  SkyEyeStepCountManager.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeStepCountManager.h"

@interface SkyEyeStepCountManager()

@property (nonatomic, weak) id<SkyEyeMotionDelegate> motionDelegate;

@property (nonatomic, strong) CMStepCounter *skyEyeStepCounter;
@property (nonatomic) BOOL stepCountingActive;

@end


@implementation SkyEyeStepCountManager

+ (id)sharedSkyEyeStepCountManager {
    static SkyEyeStepCountManager *sharedMySkyEyeStepCountManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMySkyEyeStepCountManager = [[self alloc] init];
    });
    return sharedMySkyEyeStepCountManager;
}

- (id)init {
    if (self = [super init]) {
        _skyEyeStepCounter = [[CMStepCounter alloc] init];
        _stepCountingActive = NO;
    }
    return self;
}

- (void)startTrackingUserStepCountWithDelegate:(id<SkyEyeMotionDelegate>)delegate{
    if (!self.stepCountingActive){
        self.motionDelegate = delegate;
        
        [self.skyEyeStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                                       updateOn:1
                                                    withHandler:^(NSInteger numberOfSteps,
                                                                  NSDate *timestamp,
                                                                  NSError *error) {
            if (!error){
                [self processStepCount:numberOfSteps atTimestamp:timestamp];
            }else{
                [self.motionDelegate errorFetchingStepCount:error];
            }
        }];
    }
}


-(void)processStepCount:(NSInteger)steps atTimestamp:(NSDate *)timestamp{
    [self.motionDelegate stepCountUpdated:steps timestamp:timestamp];
}


- (void)stopTrackingUserStepCount{
    if (self.stepCountingActive){
        [self.skyEyeStepCounter stopStepCountingUpdates];
    }
}


@end
