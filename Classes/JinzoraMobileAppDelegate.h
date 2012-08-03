//
//  JinzoraMobileAppDelegate.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/9/09.
//  Copyright Stanford University 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseViewController.h"
#import "PlayViewController.h"
//#import "PreferencesViewController.h"
#import "RepSettingsViewController.h"
#import "ServersViewController.h"
#import "FollowersViewController.h"
#import "DownloadViewController.h"
#import "Preferences.h"

@interface JinzoraMobileAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController *tabBarController;
	
	BrowseViewController *bvc;
	PlayViewController *pvc;
	//RepSettingsViewController *prvc;
	ServersViewController *svc;
	FollowersViewController *fvc;
	DownloadViewController *dvc;
    
	Preferences *p;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) BrowseViewController *bvc;
@property (nonatomic, retain) PlayViewController *pvc;
//@property (nonatomic, retain) RepSettingsViewController *prvc;
@property (nonatomic, retain) FollowersViewController *fvc;
@property (nonatomic, retain) DownloadViewController *dvc;
@property (nonatomic, retain) Preferences *p;

- (void) resetBrowse;

@end

