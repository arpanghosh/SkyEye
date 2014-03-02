//
//  SkyEyeSharedSocket.h
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//



@interface SkyEyeSharedSocket : NSObject

+(instancetype)getSharedSkyEyeSocket;

-(void)sendEvent:(NSString *)eventName withData:(NSDictionary *)data;

-(void)disconnect;

@end
