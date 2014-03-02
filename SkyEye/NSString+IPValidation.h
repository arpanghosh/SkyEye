//
//  NSString+IPValidation.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/2/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import <arpa/inet.h>

@interface NSString (IPValidation)

- (BOOL)isValidIPAddress;

@end
