//
//  PreferencesViewController.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/13/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "PreferencesViewController.h"
#import "JinzoraMobileAppDelegate.h"
#import "Utilities.h"
#import "ServerEditViewController.h"
#import "Preferences.h"
#import "NSData+Base64.h"

@implementation PreferencesViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"About";
		UIImage *img = [UIImage imageNamed:@"preferencesview.png"];
		UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"About" image:img tag:3];
		self.tabBarItem = tab;
		[tab release];
		
		UIImage *bgImage = [UIImage imageNamed:@"background.png"];
        UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
		[[self view] addSubview:background];
		[[self view] sendSubviewToBack:background];
    }
    return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}

@end
