//
//  DownloadViewController.h
//  JinzoraMobile
//
//  Created by Ryan Wilson on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"

@interface DownloadViewController : UITableViewController {
    Playlist *downloadPlaylist;
}

@property (nonatomic, retain) Playlist *downloadPlaylist;

@end
