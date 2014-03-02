//
//  SkyEyeViewController.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "NSString+IPValidation.h"   

#import "SkyEyeSharedSocket.h"
#import "SkyEyeMotionDelegate.h"
#import "SkyEyeStepCountManager.h"
#import "SkyEyeDroneManager.h"

@interface SkyEyeViewController : UIViewController <FYXServiceDelegate, FYXVisitDelegate, SkyEyeMotionDelegateUIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *beaconReadings;
    UITextView *status;
    SkyEyeDroneManager *droneManager;
    
}
@property (weak, nonatomic) IBOutlet UITextView *status;
@property (weak, nonatomic) IBOutlet BButton *startButton;
@property (weak, nonatomic) IBOutlet UIPickerView *smoothingSelector;
@property (weak, nonatomic) IBOutlet UITextField *nodeIPAddress;
@property (weak, nonatomic) IBOutlet UITextView *status;
@property (weak, nonatomic) IBOutlet BButton *killSwitch;
@property (weak, nonatomic) IBOutlet UILabel *smoothingLabel;

@property (nonatomic) int beaconSmoothingMode;


@end
