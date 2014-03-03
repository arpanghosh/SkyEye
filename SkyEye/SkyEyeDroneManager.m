//
//  SkyEyeDroneManager.m
//  SkyEye
//
//  Created by Charlie Federspiel on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeDroneManager.h"

@implementation SkyEyeDroneManager
//@synthesize fsm;
@synthesize drone;
@synthesize delegate;
@synthesize ardrone_info;


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

@end
