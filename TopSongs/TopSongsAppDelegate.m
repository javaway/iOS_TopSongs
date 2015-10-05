//
//  AppDelegate.m
//  TopSongs
//
//  Created by Hidayathulla on 9/25/13.
//  Copyright (c) 2013 Individual. All rights reserved.
//

#import "TopSongsAppDelegate.h"
#import "RootViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "ParseOperation.h"
#import "TopSongsConstant.h"
#import "TopSongsUtil.h"
#import "AppRecord.h"

@interface TopSongsAppDelegate ()

    // the queue to run our "ParseOperation"
    @property (nonatomic, strong) NSOperationQueue *queue;
    // RSS feed network connection to the App Store
    @property (nonatomic, strong) NSURLConnection *appListFeedConnection;
    @property (nonatomic, strong) NSMutableData *appListData;

@end

@implementation TopSongsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.viewController = [[RootViewController alloc]init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
   
  /*  UIImageView*imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:SPLASH_SCREEN]];
    [[self.viewController view] addSubview:imageView];
    [[self.viewController view] bringSubviewToFront:imageView];
    // now fade out splash image
    [UIView transitionWithView:self.window duration:3.0f options:UIViewAnimationOptionTransitionNone animations:^(void){imageView.alpha=0.0f;} completion:^(BOOL finished){[imageView removeFromSuperview];}];*/
   // [self setup];
    
    return YES;
}

- (void)removeSplash:(UIImageView *)imageView
{
    [imageView removeFromSuperview];
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
    // Saves changes in the application's managed object context before the application terminates.
}


/* Transition of a UIViewController with transition effects */
- (void)transitionToViewController:(UIViewController *)viewController
                    withTransition:(UIViewAnimationOptions)transition
{
     [UIView transitionFromView:self.window.rootViewController.view
                        toView:viewController.view
                      duration:0.3f
                       options:transition
                    completion:^(BOOL finished){
                        self.window.rootViewController = viewController;
                    }];
   
    
}


@end
