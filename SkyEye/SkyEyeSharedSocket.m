//
//  SkyEyeSharedSocket.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeSharedSocket.h"

@interface SkyEyeSharedSocket()

@property (nonatomic, strong) SocketIO* socket;

@end


@implementation SkyEyeSharedSocket

+ (id)getSharedSkyEyeSocket {
    static SkyEyeSharedSocket *sharedSkyEyeSocket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSkyEyeSocket = [[self alloc] init];
    });
    return sharedSkyEyeSocket;
}

- (id)init {
    if (self = [super init]) {
        _socket = [[SocketIO alloc] initWithDelegate:Nil];
        [_socket connectToHost:@"192.168.1.2" onPort:9000];
    }
    return self;
}

-(void)sendEvent:(NSString *)eventName withData:(NSDictionary *)data{
    [self.socket sendEvent:eventName withData:data];
}

@end
