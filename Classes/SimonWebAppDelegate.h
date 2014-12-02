//
//  SimonWebAppDelegate.h
//  SimonWeb
//
//  Created by Evan Schoenberg on 12/17/08.
//  Copyright Adium X / Saltatory Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimonWebViewController;

@interface SimonWebAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SimonWebViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SimonWebViewController *viewController;

@end

