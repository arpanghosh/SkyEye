//
//  SkyEyeViewController.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>

#import "SkyEyeSharedSocket.h"
#import "SkyEyeMotionDelegate.h"
#import "SkyEyeStepCountManager.h"
#import "SkyEyeDroneManager.h"

@interface SkyEyeViewController : UIViewController <FYXServiceDelegate, FYXVisitDelegate, SkyEyeMotionDelegate>
{
    NSMutableArray *beaconReadings;
    UITextView *status;
    SkyEyeDroneManager *droneManager;
    
}
@property (weak, nonatomic) IBOutlet UITextView *status;


@end
