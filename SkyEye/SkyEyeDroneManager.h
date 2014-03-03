//
//  SkyEyeDroneManager.h
//  SkyEye
//
//  Created by Charlie Federspiel on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARDrone.h"
#import "ARDroneProtocols.h"
#import "ARDroneAcademy.h"

@interface SkyEyeDroneManager : NSObject <ARDroneProtocolIn, ARDroneProtocolOut, ARDroneAcademyDelegate>
//@property (nonatomic, retain) FiniteStateMachine *fsm;

@property (nonatomic, assign) ARDrone *drone;
@property (nonatomic, assign) id<ARDroneProtocolIn> delegate;

@property ardrone_info_t *ardrone_info;
@end
