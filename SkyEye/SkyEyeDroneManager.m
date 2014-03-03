//
//  SkyEyeDroneManager.m
//  SkyEye
//
//  Created by Charlie Federspiel on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeDroneManager.h"

@implementation SkyEyeDroneManager
@synthesize fsm;
@synthesize drone;
@synthesize delegate;
@synthesize ardrone_info;


// ARDrone protocols:
// ProtocolIn
- (void)changeState:(BOOL)inGame
{
	if(!inGame)
	{
        // If not in game, the MenuController removes the drone view, and adds a menu view.
		
	}
	else
	{
        // If in game, the MenuController removes the active menu view, and adds the drone view.
		
	}
}

- (void)ARDroneAcademyDidRespond:(ARDroneAcademy *)ARDroneAcademy
{
    //static int32_t time_to_process = 0;
    switch (ARDroneAcademy.result)
    {
        case ARDRONE_ACADEMY_RESULT_NONE:
            break;
            
        case ARDRONE_ACADEMY_RESULT_OK:
            /*printf("Synchronizing\n");
             time_to_process += ARDroneAcademy.time_in_ms;
             if (ARDroneAcademy.state == ARDRONE_ACADEMY_STATE_DRONE_DISCONNECTION)
             {
             printf("Synchronizing in %d ms\n", time_to_process);
             time_to_process = 0;
             }*/
            break;
            
        case ARDRONE_ACADEMY_RESULT_FAILED:
            /*if (ARDroneAcademy.state == ARDRONE_ACADEMY_STATE_DRONE_PREPARE_DOWNLOAD)
             time_to_process = 0;*/
            break;
    }
}
- (void) executeCommandIn:(ARDRONE_COMMAND_IN_WITH_PARAM)commandIn fromSender:(id)sender refreshSettings:(BOOL)refresh
{
}

- (void)executeCommandIn:(ARDRONE_COMMAND_IN)commandId withParameter:(void *)parameter fromSender:(id)sender
{
}

- (BOOL)checkState
{
	return YES;
}

- (void)setDefaultConfigurationForKey:(ARDRONE_CONFIG_KEYS)key withValue:(void *)value
{
    
}

// ProtocolOut
- (void)executeCommandOut:(ARDRONE_COMMAND_OUT)commandId withParameter:(void *)parameter fromSender:(id)sender
{
    switch(commandId)
	{
		case ARDRONE_COMMAND_RUN:
            ardrone_info = (ardrone_info_t*)parameter;
			break;
            
        case ARDRONE_COMMAND_PAUSE:
            ardrone_info = (ardrone_info_t*)parameter;
            [fsm doAction:MENU_FF_ACTION_JUMP_TO_HOME];
            break;
            
		default:
			break;
	}
    
	//if ((currentMenu) && [currentMenu respondsToSelector:@selector(executeCommandOut:withParameter:fromSender:)])
	//	[currentMenu executeCommandOut:commandId withParameter:parameter fromSender:sender];
}

-(BOOL)shouldAutorotate
{
        return NO;
}

-(NSInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
    
}

@end
