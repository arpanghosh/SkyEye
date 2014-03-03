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
#import "FiniteStateMachine.h"



enum
{
    MENU_FF_STATE_HOME,
    MENU_FF_STATE_HUD,
    MENU_FF_STATE_GUEST_SPACE,
    MENU_FF_STATE_UPDATER,
    MENU_AA_NAVIGATION_CONTROLLER,
    MENU_FF_STATE_GAMES,
    MENU_FF_STATE_MEDIA,
    MENU_FF_STATE_SETTINGS,
	MENU_STATES_COUNT
};

enum
{
    MENU_FF_ACTION_JUMP_TO_HUD,
    MENU_FF_ACTION_JUMP_TO_GUEST_SPACE,
    MENU_FF_ACTION_JUMP_TO_UPDATER,
    MENU_FF_ACTION_JUMP_TO_ARDRONE_ACADEMY,
    MENU_FF_ACTION_JUMP_TO_GAMES,
    MENU_FF_ACTION_JUMP_TO_MEDIA,
    MENU_FF_ACTION_JUMP_TO_PREFERENCES,
    MENU_FF_ACTION_JUMP_TO_HOME,
	MENU_FF_ACTIONS_COUNT
};

@interface SkyEyeDroneManager : NSObject <ARDroneProtocolIn, ARDroneProtocolOut, ARDroneAcademyDelegate>
@property (nonatomic, retain) FiniteStateMachine *fsm;

@property (nonatomic, assign) ARDrone *drone;
@property (nonatomic, assign) id<ARDroneProtocolIn> delegate;

@property ardrone_info_t *ardrone_info;

@end
