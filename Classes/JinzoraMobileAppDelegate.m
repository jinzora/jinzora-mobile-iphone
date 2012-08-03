//
//  JinzoraMobileAppDelegate.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/9/09.
//  Copyright Stanford University 2009. All rights reserved.
//

#import "JinzoraMobileAppDelegate.h"

@implementation JinzoraMobileAppDelegate

@synthesize window, tabBarController, bvc, pvc, dvc, fvc, p;


- (void)applicationDidFinishLaunching:(UIApplication *)application {  
	
	
	tabBarController = [[UITabBarController alloc] init];
	p = [[Preferences alloc] init];
	
	bvc = [[BrowseViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *browseNavController = [[[UINavigationController alloc] initWithRootViewController:bvc] autorelease];   
	browseNavController.navigationBar.tintColor = [UIColor blackColor]; 
	[bvc release];
	
	pvc = [[PlayViewController alloc] init];
	UINavigationController *playNavController = [[[UINavigationController alloc] initWithRootViewController:pvc] autorelease];   
	playNavController.navigationBar.tintColor = [UIColor blackColor]; 
	[pvc release];
	
	//prvc = [[RepSettingsViewController alloc] init];
	//UINavigationController *prefNavController = [[[UINavigationController alloc] initWithRootViewController:prvc] autorelease];   
	//prefNavController.navigationBar.tintColor = [UIColor blackColor]; 
	//[prvc release];
    
    dvc = [[DownloadViewController alloc] init];
	UINavigationController *dlNavController = [[[UINavigationController alloc] initWithRootViewController:dvc] autorelease];   
	dlNavController.navigationBar.tintColor = [UIColor blackColor]; 
	[dvc release];
	
	svc = [[ServersViewController alloc] init];
	UINavigationController *serversNavController = [[[UINavigationController alloc] initWithRootViewController:svc] autorelease];
	serversNavController.navigationBar.tintColor = [UIColor blackColor];
	[svc release];
	
	fvc = [[FollowersViewController alloc] init];
	UINavigationController *followersNavController = [[[UINavigationController alloc] initWithRootViewController:fvc] autorelease];
	followersNavController.navigationBar.tintColor = [UIColor blackColor];
	[fvc release];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:browseNavController,playNavController,serversNavController,followersNavController, dlNavController, nil];
	
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
}

- (void) resetBrowse {
	bvc = [[BrowseViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *browseNavController = [[[UINavigationController alloc] initWithRootViewController:bvc] autorelease];   
	browseNavController.navigationBar.tintColor = [UIColor blackColor]; 
	[bvc release];
	NSMutableArray *objects = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
	[objects replaceObjectAtIndex:0 withObject:browseNavController];
	tabBarController.viewControllers = objects;
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	PlayViewController *myPlayViewController = [[[tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	[p writeOutToFile];
	//[myPlayViewController.currentPlaylist writeOutToFile];
}


- (void)dealloc {
	[p release];
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end
