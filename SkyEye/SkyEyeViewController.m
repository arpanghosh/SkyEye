//
//  SkyEyeViewController.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeViewController.h"
#import <FYX/FYXTransmitter.h>
#import "BeaconReading.h"

@implementation SkyEyeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    beaconReadings = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
     [FYX startService:self];
    [[SkyEyeStepCountManager sharedSkyEyeStepCountManager] startTrackingUserStepCountWithDelegate:self];
    droneManager = [[SkyEyeDroneManager alloc] init];

- (BOOL)isValidIpAddress:(NSString *)ip {
    const char *utf8 = [ip UTF8String];
    
    // Check valid IPv4.
    struct in_addr dst;
    int success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    if (success != 1) {
        // Check valid IPv6.
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    return (success == 1);

}



- (IBAction)startDrone {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([self.nodeIPAddress.text isValidIPAddress]) {
        [defaults setValue:self.nodeIPAddress.text forKey:@"sky_eye_node_ip"];
        [self updateUIForPilotingDrone];
        [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"startDrone" withData:nil];
        [[SkyEyeGimbalManager sharedSkyEyeGimbalManager] startSightingGimbalBeaconsWithDelagate:self
                                                                               andSmoothingMode:self.beaconSmoothingMode];
        //[[SkyEyeStepCountManager sharedSkyEyeStepCountManager] startTrackingUserStepCountWithDelegate:self];
        //[[SkyEyeHeadingManager sharedSkyEyeHeadingManager] startTrackingHeadingWithDelegate:self];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nodeIPAddress.text = @"Invalid IP Address";
            self.nodeIPAddress.textColor = [UIColor redColor];
        });
    }
}

- (IBAction)stopDrone {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[SkyEyeGimbalManager sharedSkyEyeGimbalManager] stopSightingGimbalBeacons];
    });
    
    //[[SkyEyeStepCountManager sharedSkyEyeStepCountManager] stopTrackingUserStepCount];
    //[[SkyEyeHeadingManager sharedSkyEyeHeadingManager] stopTrackingHeading];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"stopDrone" withData:nil];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] disconnect];
    [self updateUIForConfig];
}


- (void)updateUIForPilotingDrone{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nodeIPAddress.hidden = YES;
        self.smoothingSelector.hidden = YES;
        self.startButton.hidden = YES;
        self.smoothingLabel.hidden = YES;
        self.status.hidden = NO;
        self.killSwitch.hidden = NO;
        [self.killSwitch setType:BButtonTypeDanger];
    });
}


- (void)updateUIForConfig{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *nodeIP = [defaults objectForKey:@"sky_eye_node_ip"];
    if (nodeIP) {
        self.nodeIPAddress.text = nodeIP;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.nodeIPAddress.hidden = NO;
        self.smoothingSelector.hidden = NO;
        self.startButton.hidden = NO;
        self.smoothingLabel.hidden = NO;
        [self.startButton setType:BButtonTypePrimary];
        self.status.hidden = YES;
        self.killSwitch.hidden = YES;
    });
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateUIForConfig];
    self.smoothingSelector.delegate = self;
    self.smoothingSelector.dataSource = self;
    self.nodeIPAddress.delegate = self;
}

- (double) calculateMean:(NSArray *)readings offset:(unsigned long)offset count:(int)count;
{
    double mean = 0;
    if([readings count] < count) {
        return 0;
    }
    for(unsigned long i = [readings count] - count; i < [readings count]; i++) {
        BeaconReading *currentReading = [readings objectAtIndex:i];
        mean += currentReading.signalStrength;
    }
    return mean/count;
}



-(void)updateStatusWithMessage:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.status.text = [self.status.text stringByAppendingFormat:@"\n%@",message];
        [self.status scrollRangeToVisible:NSMakeRange(self.status.text.length, 0)];
    });
}


#pragma mark - SkyEyeBeaconDelegate methods

-(void)sightedBeacon:(NSString *)transmitterName RSSI:(NSNumber *)rssi timestamp:(NSDate *)timestamp{
    

    
    BeaconReading *r = [[BeaconReading alloc] init];
    [r setBeaconName:visit.transmitter.name];
    [r setSignalStrength:[RSSI doubleValue]];
    [r setTimestamp:updateTime];
    
    [beaconReadings addObject:r];
    
    double mean = [self calculateMean:beaconReadings offset:[beaconReadings count] - 10 count:10];
    [self updateStatusWithMessage:[NSString stringWithFormat:@"Beacon sighting: %@ RSSI %@, mean: %@", transmitterName, rssi, mean]];
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[rssi stringValue] forKey:@"beaconData"];
    [dict setObject:transmitterName forKey:@"beaconID"];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"beaconData" withData:dict];

}

-(void)errorSightingBeacons:(NSError *)error{
    [self updateStatusWithMessage:[NSString stringWithFormat:@"Error sighting beacons : %@", error.localizedDescription]];
}


#pragma mark - SkyEyeMotionDelegate methods

-(void)stepCountUpdated:(NSInteger)stepCount timestamp:(NSDate *)timestamp{
    [self updateStatusWithMessage:[NSString stringWithFormat:@"Step count updated : %ld", (long)stepCount]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSNumber numberWithInteger:stepCount] stringValue] forKey:@"stepCount"];
    [dict setObject:[[NSNumber numberWithDouble:[timestamp timeIntervalSince1970]] stringValue] forKey:@"stepTimestamp"];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"stepData" withData:dict];
}

-(void)errorFetchingStepCount:(NSError *)error{
    [self updateStatusWithMessage:[NSString stringWithFormat:@"Error fetching step count : %@", error.localizedDescription]];
}

-(void)headingUpdated:(double )heading timestamp:(NSDate *)timestamp{
    //[self updateStatusWithMessage:[NSString stringWithFormat:@"heading updated : %f", heading]];
    
    /*
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[[NSNumber numberWithInteger:stepCount] stringValue] forKey:@"stepCount"];
    [dict setObject:[[NSNumber numberWithDouble:[timestamp timeIntervalSince1970]] stringValue] forKey:@"stepTimestamp"];
    [[SkyEyeSharedSocket getSharedSkyEyeSocket] sendEvent:@"stepData" withData:dict];
     */
}

-(void)errorFetchingHeading:(NSError *)error{
    //[self updateStatusWithMessage:[NSString stringWithFormat:@"Error fetching heading : %@", error.localizedDescription]];
}


#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 4;
}


#pragma mark - UIPickerViewDelegate methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 320.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (row) {
        case 0:
            return @"None";
            break;
        case 1:
            return @"Small";
            break;
        case 2:
            return @"Medium";
            break;
        case 3:
            return @"Large";
            break;
        default:
            return @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (row) {
        case 0:
            self.beaconSmoothingMode = FYXSightingOptionSignalStrengthWindowNone;
            break;
        case 1:
            self.beaconSmoothingMode = FYXSightingOptionSignalStrengthWindowSmall;
            break;
        case 2:
            self.beaconSmoothingMode = FYXSightingOptionSignalStrengthWindowMedium;
            break;
        case 3:
            self.beaconSmoothingMode = FYXSightingOptionSignalStrengthWindowLarge;
            break;
        default:
            self.beaconSmoothingMode = FYXSightingOptionSignalStrengthWindowNone;
            break;
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    dispatch_async(dispatch_get_main_queue(), ^{
        textField.text = @"";
        textField.textColor = [UIColor blackColor];
    });
    return YES;
}

@end
