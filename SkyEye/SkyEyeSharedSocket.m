//
//  SkyEyeSharedSocket.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeSharedSocket.h"

@interface SkyEyeSharedSocket()

@property (nonatomic, strong) SocketIO *socket;

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
    }
    return self;
}

-(SocketIO *)socket{
    if (!_socket || !_socket.isConnected) {
        _socket = [[SocketIO alloc] initWithDelegate:Nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *nodeIP = [defaults objectForKey:@"sky_eye_node_ip"];
        [_socket connectToHost:nodeIP onPort:SKYEYE_NODE_CONTROLLER_PORT];
    }
    return _socket;
}

-(void)sendEvent:(NSString *)eventName withData:(NSDictionary *)data{
    [self.socket sendEvent:eventName withData:data];
}

-(void)disconnect{
    [self.socket disconnect];
}

@end
