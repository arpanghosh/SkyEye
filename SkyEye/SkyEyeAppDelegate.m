//
//  SkyEyeAppDelegate.m
//  SkyEye
//
//  Created by Arpan Ghosh on 3/1/14.
//  Copyright (c) 2014 SkyEye. All rights reserved.
//

#import "SkyEyeAppDelegate.h"
#import <FYX/FYX.h>

@implementation SkyEyeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FYX setAppId:@"c504da86c837f025231cfa52e8e50a2047d721ed1f368269598b03791cb5aadc" appSecret:@"d8930921a00a7c4ad9b647357ce16b2c7c73ee2e6c874584a7f6f4916b7029d4" callbackUrl:@"skyeye://authcode"];    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
