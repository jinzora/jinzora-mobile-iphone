//
//  PlaylistViewController.m
//  JinzoraMobile
//
//  Created by albert on 5/3/09.
//  Copyright 2009 Planet Express. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlayViewController.h"
#import "JinzoraMobileAppDelegate.h"
#import "Utilities.h"

@interface PlaylistViewController (Internal)
- (void)playbackStateChanged:(NSNotification *)aNotification;
@end

@implementation PlaylistViewController

@synthesize myPlaylist;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	[super viewDidLoad];
	justloaded = YES;
	
	self.title = @"Playlist";
	
	topButtons = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Save",@"Edit",nil]];
	topButtons.segmentedControlStyle = UISegmentedControlStyleBar;
	topButtons.momentary = YES;
	[topButtons addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		
	UIBarButtonItem *doublebutton = [[UIBarButtonItem alloc] initWithCustomView:topButtons];
	self.navigationItem.rightBarButtonItem = doublebutton;
	[doublebutton release];
	
	[self playbackStateChanged:nil];
}

- (void)segmentAction:(id)sender
{
	NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
	if([sender selectedSegmentIndex] == 0)
	{
		UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Save Playlist" message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
		myTextField = [[UITextField alloc] init];
		myTextField.delegate = self;
		[myTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[myTextField setBackgroundColor:[UIColor whiteColor]];
		[myAlertView addSubview:myTextField];
		[myAlertView show];
		[myAlertView release];
		
	} else {
		UITableView *view = [self tableView];
		if([view isEditing]) {
			[view setEditing:NO animated:YES];
			UISegmentedControl* seg = (UISegmentedControl*) self.navigationItem.rightBarButtonItem.customView;
			[seg setTitle:@"Edit" forSegmentAtIndex:1];
		} else {
			[view setEditing:YES animated:YES];
			UISegmentedControl* seg = (UISegmentedControl*) self.navigationItem.rightBarButtonItem.customView;
			[seg setTitle:@"Done" forSegmentAtIndex:1];
		}
		
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == myTextField){
		[myTextField resignFirstResponder];
	} 
	
	return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[myTextField resignFirstResponder];
	if(buttonIndex == 1) {
		NSMutableString *httpBodyString;
		NSURL *url;
		NSString *urlString;
		int i;
		JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
		httpBodyString=[[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"name=%@", myTextField.text]];
		for(i = 0; i<[myPlaylist songCount]; i++){
			Song *thissong = [myPlaylist getSongAtIndex:i];
			[httpBodyString appendFormat:@"&songs[]=%@", thissong.trackid];
		}
		
		urlString=[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@&request=saveplaylist",[app.p getCurrentApiURL]]];
		NSLog(urlString);
		NSLog(httpBodyString);
		url=[[NSURL alloc] initWithString:urlString];
		[urlString release];
		
		NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:url];
		[url release];
		
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
		[httpBodyString release];
		
		NSURLConnection *connectionResponse = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
		
		if (!connectionResponse)
		{
			NSLog(@"Failed to submit request");
		}
		else
		{
			NSLog(@"--------- Request submitted ---------");
			NSLog(@"connection: %@ method: %@, encoded body: %@, body: %a", connectionResponse, [urlRequest HTTPMethod], [urlRequest HTTPBody], httpBodyString);
			receivedData=[[NSMutableData data] retain];
		}
		[NSURLConnection release];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
	NSString *rdata = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	NSLog(rdata);
	myPlaylist.playlistid = rdata;
	
    [connection release];
    [receivedData release];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[self tableView] reloadData];
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	if([[app.p getCurrentApiURL] isEqualToString:@"http://live.jinzora.org/api.php?user=&pass=D41D8CD98F00B204E9800998ECF8427E&pw_hashed=true"]) [topButtons setEnabled:NO forSegmentAtIndex:0];
	else [topButtons setEnabled:YES forSegmentAtIndex:0];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if(justloaded == YES){
		[self playbackStateChanged:nil];
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:myPlaylist.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		justloaded = NO;
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(![[self.navigationController viewControllers] containsObject:self]){
		[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	}
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [myPlaylist.songs count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	UILabel *label = cell.textLabel;
    label.text = [NSString stringWithFormat:@"%d. %@",indexPath.row+1, [[myPlaylist.songs objectAtIndex:indexPath.row] getTitle]];
	
	if (myPlaylist.currentIndex == indexPath.row){
		[label setTextColor:[UIColor blueColor]];
	} else {
		[label setTextColor:[UIColor blackColor]];
		cell.accessoryView = nil;
	}
    return cell;
}

- (void) pausePressed:(UIButton*) button withEvent:(UIEvent *) event {
	NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
	PlayViewController *myPlayViewController = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	[myPlayViewController playPressed:self];
	//[self playbackStateChanged:nil];
	//[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Geez this is pretty ugly, dont judge!
	PlayViewController *myPlayViewController = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	[myPlayViewController changeTrack:indexPath.row];
	[myPlayViewController destroyStreamer];
	[myPlayViewController resetProgress];
	[myPlayViewController playSong];
	//[self.navigationController popViewControllerAnimated:YES];

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		int originalCurrent = myPlaylist.currentIndex;
		[myPlaylist removeSongAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		PlayViewController *myPlayViewController = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
		if (originalCurrent == indexPath.row) {
			if((indexPath.row == [myPlaylist.songs count]) && [myPlaylist.songs count] != 0) {
				[myPlayViewController changeTrack:originalCurrent-1];
			}
			else if([myPlaylist.songs count] != 0){
				[myPlayViewController changeTrack:originalCurrent];
			}
			[myPlayViewController destroyStreamer];
			[myPlayViewController resetProgress];
		}
		[self playbackStateChanged:nil];
		[tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[myPlaylist exchangeSongAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
	NSArray *toupdate = [tableView indexPathsForVisibleRows];
	//[tableView reloadRowsAtIndexPaths:toupdate withRowAnimation: UITableViewRowAnimationNone];
	for (NSIndexPath* indexPath in toupdate) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		UILabel *label = cell.textLabel;
		NSString *string = [label.text substringFromIndex:([label.text rangeOfString:@"."].location + 2)];
		if (indexPath.row == fromIndexPath.row) {
			label.text = [NSString stringWithFormat:@"%d. %@", toIndexPath.row+1, string];
		} else if (indexPath.row > fromIndexPath.row && indexPath.row <= toIndexPath.row){
			label.text = [NSString stringWithFormat:@"%d. %@", indexPath.row, string];
		} else if (indexPath.row < fromIndexPath.row && indexPath.row >= toIndexPath.row){
			label.text = [NSString stringWithFormat:@"%d. %@", indexPath.row+2, string];
		}
	}
	
	if(myPlaylist.currentIndex == fromIndexPath.row) myPlaylist.currentIndex = toIndexPath.row;
	else if (myPlaylist.currentIndex > fromIndexPath.row && myPlaylist.currentIndex <= toIndexPath.row) myPlaylist.currentIndex--;
	else if (myPlaylist.currentIndex < fromIndexPath.row && myPlaylist.currentIndex >= toIndexPath.row) myPlaylist.currentIndex++;
}

- (void)setAccessoryPlaying:(BOOL)isPlaying {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:myPlaylist.currentIndex inSection:0]];
	UIButton *add = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	if(isPlaying){
		[add setImage:[UIImage imageNamed:@"pause_small.png"] forState:UIControlStateNormal];
		[add setImage:[UIImage imageNamed:@"pause_small_pressed.png"] forState:UIControlStateHighlighted];
	} else {
		[add setImage:[UIImage imageNamed:@"play_small.png"] forState:UIControlStateNormal];
		[add setImage:[UIImage imageNamed:@"play_small_pressed.png"] forState:UIControlStateHighlighted];
	}
	[add addTarget:self action:@selector(pausePressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
	cell.accessoryView = add;
	[self.tableView reloadData];
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	PlayViewController *pvc = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	if ([pvc.streamer isWaiting]) {
		[self setAccessoryPlaying:YES];
	}
	else if ([pvc.streamer isPlaying]) {
		[self setAccessoryPlaying:YES];
	}
	else if ([pvc.streamer isPaused]) {
		[self setAccessoryPlaying:NO];
	}
	else if ([pvc.streamer isIdle])	{
		[self setAccessoryPlaying:NO];
	} else {
		[self setAccessoryPlaying:NO];
	}
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)dealloc {
	[topButtons release];
	[myTextField release];
	[myPlaylist release];
    [super dealloc];
}


@end

