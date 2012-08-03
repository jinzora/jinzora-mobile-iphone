//
//  DownloadViewController.m
//  JinzoraMobile
//
//  Created by Ryan Wilson on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewController.h"
#import "JinzoraMobileAppDelegate.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController

@synthesize downloadPlaylist;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //downloadPlaylist = [[Playlist alloc] initFromStandardFile];
        self.title = @"Downloads";
        UIImage *img = [UIImage imageNamed:@"preferencesview.png"];
		UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Downloads" image:img tag:3];
		self.tabBarItem = tab;
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
		[tab release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    downloadPlaylist = [[Playlist alloc] initFromStandardFile];
	[[self tableView] reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [downloadPlaylist release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    [downloadPlaylist printSongs];
    NSLog([NSString stringWithFormat:@"%d", [downloadPlaylist songCount]]);
    return [downloadPlaylist songCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song* selectedSong = [downloadPlaylist getSongAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    UILabel *lbl1 = cell.textLabel;
    //UILabel *lbl2 = cell.detailTextLabel;
    
    lbl1.text = [NSString stringWithFormat:@"%@ - %@", [selectedSong getTitle],[selectedSong getArtist]];
    NSLog(lbl1.text);
    [downloadPlaylist printSongs];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PlayViewController *pvc = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
        if ((pvc.currentPlaylist.currentIndex == indexPath.row) && pvc.localPlayer)
        {
            UIAlertView *result = [[UIAlertView alloc] initWithTitle: @"Song Not Deleted" message: @"Song is currently playing" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [result show];
            [result release];
            return;
        }
        NSString* localPath = [downloadPlaylist getSongAtIndex:indexPath.row].localPath;
		[downloadPlaylist removeSongAtIndex:indexPath.row];
        [downloadPlaylist writeOutToFile];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        BOOL fileExists = [fileManager fileExistsAtPath:localPath];
        NSLog(@"Path to file: %@", localPath);        
        NSLog(@"File exists: %d", fileExists);
        NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:localPath]);
        if (fileExists) 
        {
            BOOL success = [fileManager removeItemAtPath:localPath error:&error];
            if (!success) NSLog(@"Error: %@", [error localizedDescription]);
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECTED");
    Song *localSong = [downloadPlaylist getSongAtIndex:indexPath.row];
    [downloadPlaylist printSongs];
    NSLog(localSong.localPath);
    PlayViewController *pvc = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    [pvc replacePlaylistWithPlaylistandTrack:downloadPlaylist :indexPath.row];
    self.navigationController.tabBarController.selectedViewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:1];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [super dealloc];
}

@end
