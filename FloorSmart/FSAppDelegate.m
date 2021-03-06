//
//  FSAppDelegate.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSMainViewController.h"
#import "Global.h"
#import <AudioToolbox/AudioToolbox.h>
#import "iVersion.h"

@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TESTFLIGHT_ENABLED
    [TestFlight takeOff:@"f5bf72b9-aacc-4d6f-91dc-e2325536c1be"];
#endif
    
    //------ google analytics ---------------------
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize a tracker using a Google Analytics property ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-4856475-4"];
    
    
    [[GlobalData sharedData] loadInitData];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [FSMainViewController sharedController];
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    //UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
    //AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
    AudioSessionSetActive (true);
    
    return YES;
}

+ (void) initialize
{
	// check app version
	[iVersion sharedInstance].applicationBundleID = [[NSBundle mainBundle] bundleIdentifier];
    
	[iVersion sharedInstance].checkAtLaunch = YES;
	[iVersion sharedInstance].checkPeriod = 0;
	[iVersion sharedInstance].remindPeriod = 0;
    
	[[iVersion sharedInstance] checkIfNewVersion];
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
