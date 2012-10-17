//
//  JinzoraMobileAppDelegate.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/9/09.
//  Copyright Stanford University 2009. All rights reserved.
//

#import "JinzoraMobileAppDelegate.h"

@implementation JinzoraMobileAppDelegate

@synthesize window, tabBarController, bvc, pvc, dvc, p;


- (void)applicationDidFinishLaunching:(UIApplication *)application {  
	
	
	tabBarController = [[UITabBarController alloc] init];
	p = [[Preferences alloc] init];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
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
	
	//fvc = [[FollowersViewController alloc] init];
	//UINavigationController *followersNavController = [[[UINavigationController alloc] initWithRootViewController:fvc] autorelease];
	//followersNavController.navigationBar.tintColor = [UIColor blackColor];
	//[fvc release];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:browseNavController,playNavController,serversNavController,dlNavController, nil];
	
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

- (void)switchToServer:(NSDictionary *)dict
{
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUInteger index = 0;
    BOOL add = YES;
    NSString *serv = [dict objectForKey:@"server"];
    
    // Server URL processing
    if ([serv hasSuffix:@"index.php"])
    {
        serv = [serv substringToIndex:([serv length] - [@"index.php" length]) ];
    }
    if ([serv hasSuffix:@"/"])
    {
        serv = [serv substringToIndex:([serv length] - [@"/" length])];
    }
    if ( !([serv hasPrefix:@"http://"] || [serv hasPrefix:@"https://"]) )
    {
        serv = [NSString stringWithFormat:@"http://%@", serv];
    }

    // Search for server in current servers
    for (index = 0; index < [app.p getNumServers]; index++)
    {
        if ([serv isEqualToString:[app.p getServforServAtIndex:index]])
        {
            add = NO;
            break;
        }
    }
    // Add server if not in current servers
    if (add)
    {
        index = [app.p getNumServers];
        [app.p addServerNamed:[NSString stringWithFormat:@"Server %u", index] username:[dict objectForKey:@"user"] password:[dict objectForKey:@"password"] server:serv];
    }
    NSString *before = [[NSString alloc] initWithString:[app.p getCurrentApiURL]];
	[app.p setCurrURLtoServAtIndex:index];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"server"];
	NSString *after = [app.p getCurrentApiURL];
	if(![before isEqualToString:after]) [app resetBrowse];
    [before release];
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSString *json = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return dict;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *encoded_str = [url.path substringFromIndex:1];
    if (url.query)
    {
        encoded_str = [NSString stringWithFormat:@"%@?%@", encoded_str, url.query];
    }
    NSDictionary *dict = [self parseQueryString:encoded_str];
    
    if (!dict)
    {
        return NO;
    }
    
    [self switchToServer:dict];
    NSString *note = [NSString stringWithFormat:@"Your friend recommends you listen to the artist %@'s song %@", [dict objectForKey:@"artist"], [dict objectForKey:@"title"]];
    UIAlertView *recommendation = [[UIAlertView alloc] initWithTitle: @"Musubi recommendation" message:note delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [recommendation show];
    [recommendation release];
    return YES;
}

- (void)dealloc {
	[p release];
	[tabBarController release];
    [window release];
    [super dealloc];
}


@end
