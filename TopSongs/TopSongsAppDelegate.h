//
//  TopSongsAppDelegate.h
//  TopSongs
//
//  Created by Hidayathulla on 9/25/13.
//  Copyright (c) 2013 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface TopSongsAppDelegate : UIResponder <UIApplicationDelegate>

    @property (strong, nonatomic) UIWindow *window;
    @property (strong, nonatomic) RootViewController *viewController;

    - (void)transitionToViewController:(UIViewController *)viewController
                        withTransition:(UIViewAnimationOptions)transition;

@end

