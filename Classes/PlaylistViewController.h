//
//  PlaylistViewController.h
//  JinzoraMobile
//
//  Created by albert on 5/3/09.
//  Copyright 2009 Planet Express. All rights reserved.
//

#import "Utilities.h"
#import <UIKit/UIKit.h>
#import "Playlist.h"

@interface PlaylistViewController : UITableViewController <UITextFieldDelegate>{
	Playlist *myPlaylist;
	NSMutableData *receivedData;
	BOOL justloaded;
	UITextField *myTextField;
	UISegmentedControl *topButtons;
}

@property (retain) Playlist *myPlaylist;

@end