//
//  PlayViewController.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/9/09.
//  Copyright 2009 Stanford University. All rights reserved.
//f

#import "PlayViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "PlaylistViewController.h"
#import "Utilities.h"
#import "JinzoraMobileAppDelegate.h"
#import "Reachability.h"

@interface PlayViewController (Internal)
- (void) resetProgress;
+ (NSString *) getTimeTextAt:(int)progress outOf:(int)total positive:(BOOL)isPos;
@end

@implementation PlayViewController

@synthesize currentPlaylist, playing, streamer, localPlayer;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		progressDown = NO;
		static CGFloat buttonsize = 100.0f;
		play = [[UIImage imageNamed:@"playB.png"] retain];
		play_pressed = [[UIImage imageNamed:@"play_pressedB.png"] retain];
		pause = [[UIImage imageNamed:@"pauseB.png"] retain];
		pause_pressed = [[UIImage imageNamed:@"pause_pressedB.png"] retain];
		playButtonView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonsize, buttonsize)]; 
		playButtonView.image = play;
		back = [[UIImage imageNamed:@"backB.png"] retain];
		back_pressed= [[UIImage imageNamed:@"back_pressedB.png"] retain];
		backButtonView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonsize, buttonsize)]; 
		backButtonView.image = back;
		forward = [[UIImage imageNamed:@"forwardB.png"] retain];
		forward_pressed= [[UIImage imageNamed:@"forward_pressedB.png"] retain];
		forwardButtonView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonsize, buttonsize)]; 
		forwardButtonView.image = forward;
		playing = NO;

		self.title = @"Now Playing";
		UIImage *img = [UIImage imageNamed:@"playview.png"];
		UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Now Playing" image:img tag:1];
		self.tabBarItem = tab;
		[tab release];
		
		UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
		[[self view] addSubview:background];
		[[self view] sendSubviewToBack:background];
		
		Playlist *newPlaylist = [[Playlist alloc] initFromStandardFile];
		[currentPlaylist addToPlaylist:newPlaylist];
		[self changeTrack:0];
		[newPlaylist release];
		
        
        UIBarButtonItem *temporaryRecommendButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Recommend" style:UIBarButtonItemStylePlain target:self action:@selector(recommendSong)];
        self.navigationItem.leftBarButtonItem = temporaryRecommendButtonItem;
        [temporaryRecommendButtonItem release];
        
		UIBarButtonItem *temporayPlaylistButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"playlist_bar_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showPlaylist)];
		self.navigationItem.rightBarButtonItem = temporayPlaylistButtonItem;
		[temporayPlaylistButtonItem release];
		
		UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
		temporaryBarButtonItem.title = @"Playing";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		[temporaryBarButtonItem release];
		
		thv = [[TrackHeaderView	alloc] initWithFrame:CGRectMake(200, 0, 100, 38) ];
		thv.currentSong = currentSong;
		self.navigationItem.titleView = thv;
		[thv setNeedsDisplay];
		[self.view bringSubviewToFront:playSpinner];
		if([currentSong getLength] == 0 ) progressSlider.enabled = NO;
    }
    return self;
}

#pragma mark Button Event Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	static CGFloat buttondist = 100.0f;
	UITouch *touch = [touches anyObject];
    CGPoint startTouchPosition = [touch locationInView:self.view];
	if(!playing) playButtonView.image = play;
	else playButtonView.image = pause;
	playButtonView.frame = CGRectMake(startTouchPosition.x-(playButtonView.frame.size.width/2), startTouchPosition.y-buttondist-(playButtonView.frame.size.height/2), playButtonView.frame.size.width, playButtonView.frame.size.height);
	backButtonView.image = back;
	backButtonView.frame = CGRectMake(startTouchPosition.x-buttondist-(backButtonView.frame.size.width/2), startTouchPosition.y-(backButtonView.frame.size.width/2), backButtonView.frame.size.width, backButtonView.frame.size.height);
	forwardButtonView.image = forward;
	forwardButtonView.frame = CGRectMake(startTouchPosition.x+buttondist-(forwardButtonView.frame.size.width/2), startTouchPosition.y-(forwardButtonView.frame.size.width/2), forwardButtonView.frame.size.width, forwardButtonView.frame.size.height);
	[self.view addSubview:playButtonView];
	//if([currentPlaylist canGoBack])
	[self.view addSubview:backButtonView];
	//if([currentPlaylist canGoForward])
	[self.view addSubview:forwardButtonView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.view];
	CGPoint relativeTouchPosition = [playButtonView convertPoint:currentTouchPosition fromView:self.view];
	if([playButtonView pointInside:relativeTouchPosition withEvent:nil]){
		if(!playing) {
			if(playButtonView.image != play_pressed) playButtonView.image = play_pressed;
		}
		else {
			if(playButtonView.image != pause_pressed) playButtonView.image = pause_pressed;
		}
	} else {
		if(!playing) {
			if(playButtonView.image != play) playButtonView.image = play;
		}
		else {
			if(playButtonView.image != pause) playButtonView.image = pause;
		}
	}
	relativeTouchPosition = [backButtonView convertPoint:currentTouchPosition fromView:self.view];
	if([backButtonView pointInside:relativeTouchPosition withEvent:nil]){
		if(backButtonView.image != back_pressed) backButtonView.image = back_pressed;
	} else {
		if(backButtonView.image != back) backButtonView.image = back;
	}
	relativeTouchPosition = [forwardButtonView convertPoint:currentTouchPosition fromView:self.view];
	if([forwardButtonView pointInside:relativeTouchPosition withEvent:nil]){
		if(forwardButtonView.image != forward_pressed) forwardButtonView.image = forward_pressed;
	} else {
		if(forwardButtonView.image != forward) forwardButtonView.image = forward;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.view];
	CGPoint relativeTouchPosition = [playButtonView convertPoint:currentTouchPosition fromView:self.view];
	if([playButtonView pointInside:relativeTouchPosition withEvent:nil]){
		[self playPressed:playButtonView];
	}
	relativeTouchPosition = [backButtonView convertPoint:currentTouchPosition fromView:self.view];
	if([backButtonView pointInside:relativeTouchPosition withEvent:nil]){
		[self prevTrack:backButtonView];
	}
	relativeTouchPosition = [forwardButtonView convertPoint:currentTouchPosition fromView:self.view];
	if([forwardButtonView pointInside:relativeTouchPosition withEvent:nil]){
		[self nextTrack:forwardButtonView];
	}
	[playButtonView removeFromSuperview];
	[backButtonView removeFromSuperview];
	[forwardButtonView removeFromSuperview];
}

#pragma mark Control Logic

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer{
    if (localPlayer)
    {
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
        [localPlayer stop];
        [localPlayer release];
        localPlayer = nil;
        return;
    }
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		if([[self.navigationController viewControllers] count] > 1) {
			[[NSNotificationCenter defaultCenter] removeObserver:[self.navigationController topViewController] name:ASStatusChangedNotification object:streamer];
		}
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

-(void) copyCurrentSong{
	currentSong.url = [currentPlaylist getCurrentSong].url;
	currentSong.title = [currentPlaylist getCurrentSong].title;
	currentSong.artist = [currentPlaylist getCurrentSong].artist;
    currentSong.origserv = [currentPlaylist getCurrentSong].origserv;
    currentSong.trackid = [currentPlaylist getCurrentSong].trackid;
    currentSong.downloadurl = [currentPlaylist getCurrentSong].downloadurl;
    currentSong.localPath = [currentPlaylist getCurrentSong].localPath;
	currentSong.info = NULL;
	if([currentPlaylist getCurrentSong].alreadyLoaded){
		if([currentPlaylist getCurrentSong].info) currentSong.info = [currentPlaylist getCurrentSong].info;
	} else {
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(songLoaded:)
		 name:SongLoadedNotification
		 object:nil];
		[currentPlaylist getCurrentSong].needsNotification = YES;
	}
}

-(void) songLoaded:(NSNotification *)aNotifications{
	NSLog(@"Song Loaded!");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:SongLoadedNotification object:nil];
	[self copyCurrentSong];
	[albumArt loadImageinBack];
	[albumArt setNeedsDisplay];
	[thv setNeedsDisplay];
	[self updateProgress:nil];
    if (currentSong.info && currentSong.origserv)
    {
        NSString *encodedpath = [currentSong.info objectForKey:@"path"];
        encodedpath =
        [(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)encodedpath, NULL, NULL, kCFStringEncodingUTF8) autorelease];
        NSString *serv = [currentSong.origserv stringByReplacingOccurrencesOfString:@"api.php" withString:@"index.php"];
        currentSong.downloadurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&action=download&jz_path=%@&type=track&ext.m3u", serv, encodedpath]];
        //NSLog([currentSong.downloadurl absoluteString]);
    }
    if (currentSong.downloadurl)
    {
        [self downloadSong];
    }
}

- (BOOL) determineRandom
{
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (app.p.random == FALSE && status != ReachableViaWiFi)
    {        
        UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"No Wifi Connection" message: @"Jinzora does not support 3G" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [error show];
        [error release];
        return FALSE;
    }
    if (status == NotReachable)
    {
        return FALSE;
    }
    return TRUE;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *result = [[UIAlertView alloc] initWithTitle: @"Download Error" message: @"Error downloading file" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [result show];
    [result release];
    return;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    urlData = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)incrementalData
{
    [urlData appendData:incrementalData];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    // Save file
    UIAlertView *result;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName =
	[(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)[NSString stringWithFormat:@"%@_%@.mp3", currentSong.artist, currentSong.title], NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
    NSString *songPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    BOOL write =[urlData writeToFile:songPath atomically:YES];
    if (write == TRUE)
    {
        NSLog([NSString stringWithFormat:@"Write of file %@ successful", songPath]);
        NSLog(@"Song initialized!");
        // Add to playlist
        Playlist* downloadPlaylist = [[Playlist alloc] initFromStandardFile];
        NSLog(@"Playlist read!");
        [downloadPlaylist addSong:currentSong atIndex:[downloadPlaylist songCount]];
        [downloadPlaylist printSongs];
        [downloadPlaylist writeOutToFile];
        [downloadPlaylist release];
    }
    else {
        NSLog([NSString stringWithFormat:@"Write of file %@ failed", songPath]);
        result = [[UIAlertView alloc] initWithTitle: @"Error Saving File" message: @"Try deleting files from your downloads playlist" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [result show];
        [result release];
    }
    [urlData release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"OK"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/musubi-group-chat"]];
    }
}

- (NSString *)encodedStringWithJSONObject:(NSDictionary *)obj
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSUTF8StringEncoding error:nil];
    if (!data)
    {
        return nil;
    }
    NSString *jsonStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    jsonStr = [jsonStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return jsonStr;
}

- (IBAction)recommendSong
{
    // Return if no current song
    if (!currentSong.info)
    {
        NSLog(@"No song chosen to recommend");
        return;
    }
    NSLog(@"Recommend button pressed");
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // First produce callback URL
    NSUInteger serv = [[NSUserDefaults standardUserDefaults] integerForKey:@"server"];
    
    NSDictionary *jinzora = [NSDictionary dictionaryWithObjectsAndKeys:currentSong.artist, @"artist", currentSong.title, @"title", [app.p getServforServAtIndex:serv], @"server", [app.p getUserforServAtIndex:serv], @"user",
                                  [app.p getPassforServAtIndex:serv], @"password", nil];
    
    NSString *callback = [NSString stringWithFormat:@"jinzora://play/%@", [self encodedStringWithJSONObject:jinzora]];
    
    // Create JSON
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys: currentSong.artist, @"text", [currentSong.info objectForKey:@"image"], @"src", callback, @"callback", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"picture", @"type", json, @"json", nil];
    
    // Encode JSON
    
    NSURL *musubi_url = [NSURL URLWithString:[NSString stringWithFormat:@"musubi://share/%@", [self encodedStringWithJSONObject:dict]]];
    
    // Send to Musubi
    if ([[UIApplication sharedApplication] canOpenURL:musubi_url])
    {
        [[UIApplication sharedApplication] openURL:musubi_url];
        NSLog(@"Musubi request sent");
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Musubi Not Found" message:@"Musubi must be installed to recommend songs! Do you want to install it?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        [alertView show];
        [alertView release];
    }
}

- (IBAction) downloadSong
{
    if ([self determineRandom] == FALSE || [self songInDownloads])
    {
        return;
    }
    // Download song
    NSURLRequest *req = [NSURLRequest requestWithURL:currentSong.downloadurl];
    [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}


-(BOOL) songInDownloads
{
    if ([currentSong localPath])
    {
        return TRUE;
    }
    Playlist* downloadPlaylist = [[Playlist alloc] initFromStandardFile];
    // Check for song in playlist
    for (NSUInteger i = 0; i < [downloadPlaylist songCount]; i++)
    {
        Song *playlistSong = [downloadPlaylist getSongAtIndex:i];
        if ([currentSong.artist isEqualToString:playlistSong.artist] && [currentSong.title isEqualToString:playlistSong.title])
        {
            currentSong.localPath = playlistSong.localPath;
            [downloadPlaylist release];
            return TRUE;
        }
    }
    [downloadPlaylist release];
    return FALSE;
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
    if (streamer || localPlayer) return;
	
	[self destroyStreamer];
    
    if ([self songInDownloads])
    {
        NSLog(@"Playing song locally");
        NSURL *localUrl = [NSURL fileURLWithPath:currentSong.localPath];
        NSError *error;
        localPlayer = [[MyAVAudioPlayer alloc] initWithContentsOfURL:localUrl error:&error];
        
        progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        return;
    }
    if ([self determineRandom] == FALSE)
    {
        return;
    }
	NSString *escapedValue =
	[(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)[currentSong.url absoluteString], NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
        
	progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
	if([[self.navigationController viewControllers] count] > 1) {
		[[NSNotificationCenter defaultCenter] addObserver:[self.navigationController topViewController] selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];	
    }
}


- (void)startStreamer {
	if ([[currentPlaylist songs] count] == 0) {
		return;
	}
    if ([currentSong localPath])
    {
        NSURL *url = [NSURL fileURLWithPath:currentSong.localPath];
        NSError *error;
        localPlayer = [[MyAVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [localPlayer play];
        NSLog(@" Playing song locally %@", [currentSong getTitle]);
        return;
    }
	streamer = [[AudioStreamer alloc] initWithURL:currentSong.url];
	[streamer start];
}

- (IBAction)showPlaylist{
	NSLog(@"showing playlist");
	PlaylistViewController *myPlaylistViewController = [[PlaylistViewController alloc] initWithStyle:UITableViewStylePlain];
	// Set the playlist
	myPlaylistViewController.myPlaylist = currentPlaylist;
	if(streamer)[[NSNotificationCenter defaultCenter] addObserver:myPlaylistViewController selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];	
	// Push the new view onto stack
	[self.navigationController pushViewController: myPlaylistViewController animated:YES];
	
	[myPlaylistViewController release];
}

#pragma mark View Updates

- (void)resetProgress{
	startLabel.text = [PlayViewController getTimeTextAt:0 outOf:[currentSong getLength] positive:YES];
	endLabel.text = [PlayViewController getTimeTextAt:0	outOf:[currentSong getLength] positive:NO];
	progressView.progress = 0.0;
	progressSlider.value = 0.0;
}

-(void)playbackStateChangedLocal
{
    if(![currentPlaylist canGoForward]){
        [self destroyStreamer];
        [self changeTrack:0];
        [self resetProgress];
    } else {
        [self nextTrack:self];
    }
    playing = YES;
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[playSpinner startAnimating];
		playing = YES;
	}
	else if ([streamer isPlaying])
	{
		[playSpinner stopAnimating];
		playing = YES;
	}
	else if ([streamer isPaused]){
		playing = NO;
	}
	else if ([streamer isIdle])
	{
		if([playSpinner isAnimating]) [playSpinner stopAnimating];
		if(![currentPlaylist canGoForward]){
			[self destroyStreamer];
			[self changeTrack:0];
			[self resetProgress];
		} else {
			[self nextTrack:self];
		}
		playing = NO;
	}
}

+ (NSString *) getTimeTextAt:(int)progress outOf:(int)total positive:(BOOL)isPos{
	if (!isPos) progress = total-progress;
	if (progress < 0) progress = 0;
	int seconds = progress%60;
	int minutes = progress/60;
	NSString *secondsString = [NSString stringWithFormat:@"%d",seconds];
	if (seconds < 10) secondsString = [NSString stringWithFormat:@"0%@", secondsString];
	NSString *minutesString = [NSString stringWithFormat:@"%d",minutes];
	if (!isPos) minutesString = [NSString stringWithFormat:@"-%@", minutesString];
	return [NSString stringWithFormat:@"%@:%@",minutesString,secondsString];
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
    if (localPlayer.player.rate != 0.0 && [currentSong getLength] != 0)
    {
        if (progressSlider.enabled == NO) progressSlider.enabled = YES;
		if(!progressDown && localPlayer.player.playing){
			double progress = (double)localPlayer.player.currentTime;
			startLabel.text = [PlayViewController getTimeTextAt:(int)progress outOf:[currentSong getLength] positive:YES];
			endLabel.text = [PlayViewController getTimeTextAt:(int)progress	outOf:[currentSong getLength] positive:NO];
			progressSlider.value = progress/[currentSong getLength];
		}
    }
	else if (streamer.bitRate != 0.0 && [currentSong getLength] != 0)
	{
		if (progressSlider.enabled == NO) progressSlider.enabled = YES;
		if(!progressDown  && [streamer isPlaying]){
			double progress = streamer.progress;
			startLabel.text = [PlayViewController getTimeTextAt:(int)progress outOf:[currentSong getLength] positive:YES];
			endLabel.text = [PlayViewController getTimeTextAt:(int)progress	outOf:[currentSong getLength] positive:NO];
			progressSlider.value = progress/[currentSong getLength];
			
			if(!scrobbled && progress > 30.0){
				[self scrobbleTrack];
				scrobbled = YES;
			}
		}
	}
	else
	{
		startLabel.text = [PlayViewController getTimeTextAt:0 outOf:[currentSong getLength] positive:YES];;
		endLabel.text = [PlayViewController getTimeTextAt:0	outOf:[currentSong getLength] positive:NO];
		progressSlider.value = 0;
		if (progressSlider.enabled == YES) progressSlider.enabled = NO;
	}
}

- (IBAction)updateText:(id)sender{
	startLabel.text = [PlayViewController getTimeTextAt:(int)((int)(progressSlider.value*[currentSong getLength])) outOf:[currentSong getLength] positive:YES];
	endLabel.text = [PlayViewController getTimeTextAt:(int)((int)(progressSlider.value*[currentSong getLength])) outOf:[currentSong getLength] positive:NO];
}

- (IBAction)clickProgressBar:(id)sender{
	progressDown = YES;
}

- (IBAction)changeProgress:(id)sender{
	NSLog(@"%d",((int)(progressSlider.value*[currentSong getLength])));
    if (localPlayer)
    {
        NSTimeInterval offset = progressSlider.value*[currentSong getLength];
        [localPlayer.player setCurrentTime:offset];
    }
    else
    {
        [streamer startWithOffsetInSecs:((int)(progressSlider.value*[currentSong getLength]))];
    }
	progressDown = NO;
}

-(void) scrobbleTrack{
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"%@",[app.p getRepUser]);
	NSLog(@"%@",[app.p getRepPassword]);
	for(int i = 0; i<[app.p getNumFriends];i++){
		NSString *human = [NSString stringWithFormat:@"Jinzora: %@ - %@",currentSong.artist, currentSong.title];
		NSString *playlink = [[currentSong.url absoluteString] stringByReplacingOccurrencesOfString:@"&" withString:@"@@@"];
		NSString *machine = [NSString stringWithFormat:@"%@!!!%@!!!%@",currentSong.artist,currentSong.title,playlink];
		NSString *url = [NSString stringWithFormat:
						 @"http://mfischer.stanford.edu/send/?username=%@&password=%@&tag=Jinzora&to=%@&subject=JinzoraScrobble&message_human=%@&message_machine=%@",
						 [app.p getRepUser],[app.p getRepPassword],[app.p getFriendAtIndex:i], human,machine];
		NSLog(@"%@",url);
		NSLog(@"%@",[[currentSong.url absoluteString] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"]);
		NSString *final = [NSString stringWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:
																				  NSASCIIStringEncoding]]];
	}
}

#pragma mark Playback Control

- (void)changeTrack:(int) index {
	currentPlaylist.currentIndex = index;
	[self copyCurrentSong];
    
	NSLog(@"New song number %d %@ by %@", index, [currentSong getTitle], [currentSong getArtist]);
	scrobbled = NO;
	[albumArt setNeedsDisplay];
	[thv setNeedsDisplay];
	
	if ([self.navigationController.viewControllers count] > 1) {
		[[[self.navigationController.viewControllers objectAtIndex:1] tableView] reloadData];
	}
}

- (IBAction) stop {
    if (localPlayer)
    {
        [localPlayer stop];
        return;
    }
	[streamer stop];
}

- (void) playSong{
	if ([[currentPlaylist songs] count] == 0) {
		return;
	}
	[self destroyStreamer];
	[self createStreamer];
    if (localPlayer)
    {
        [localPlayer play];
    }
    else
    {
        [streamer start];
    }
	NSLog(@" Streaming song %@", [currentSong getTitle]);
}

- (IBAction)nextTrack:(id)sender{
	NSLog(@"Skipping to next track");
    BOOL local;
    if (localPlayer)
    {
        local = YES;
    }
    else
    {
        local = NO;
    } 
	[self changeTrack:((currentPlaylist.currentIndex + 1) % [currentPlaylist songCount])];
	[self destroyStreamer];
	[self resetProgress];
	if(playing || local)[self playSong];
}

- (IBAction)prevTrack:(id)sender{
	NSLog(@"Going back to previous track");
    BOOL local;
    if (localPlayer)
    {
        local = YES;
    }
    else
    {
        local = NO;
    }
	[self changeTrack:((currentPlaylist.currentIndex - 1 + [currentPlaylist songCount]) % [currentPlaylist songCount])];
	[self destroyStreamer];
	[self resetProgress];
	if(playing || local)[self playSong];
}

- (IBAction)playPressed:(id)sender
{
    if ([currentSong localPath])
    {
        if (!localPlayer)
        {
            [self playSong];
        }
        else
        {
            if (localPlayer.player.playing)
            {
                NSLog(@"pause");
                [localPlayer pause];
            }
            else
            {
                NSLog(@"play");
                [localPlayer play];
            }
        }
        return;
    }
	if (!streamer)
	{
		[self playSong];
	}
	else
	{
		NSLog(@"pause");
		[streamer pause];
	}
}

#pragma mark Playlist Editing

-(void) addPlaylistToPlaylist:(Playlist *)newPlaylist{
	[currentPlaylist addToPlaylist:newPlaylist];
	[self changeTrack:[currentPlaylist currentIndex]];
}

- (void) addURLToPlaylist:(NSString*)urlString {
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *playlist_data = [NSData dataWithContentsOfURL:url];
	Playlist *newPlaylist = [[Playlist alloc] initWithNSData: playlist_data];
	[self addPlaylistToPlaylist:newPlaylist];
	[newPlaylist release];
}

- (void) replacePlaylistWithPlaylist:(Playlist *) newPlaylist{
	[currentPlaylist clearPlaylist];
	[currentPlaylist addToPlaylist: newPlaylist];
	NSLog([NSString stringWithFormat:@"%d",[currentPlaylist.songs count]]);
	[self changeTrack:0];
	[self playSong];
	if ([self.navigationController.viewControllers count] > 1) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void) replacePlaylistWithPlaylistandTrack:(Playlist *) newPlaylist :(NSUInteger) trackNumber{
	[currentPlaylist clearPlaylist];
	[currentPlaylist addToPlaylist: newPlaylist];
	NSLog([NSString stringWithFormat:@"%d",[currentPlaylist.songs count]]);
	[self changeTrack:trackNumber];
	[self playSong];
	if ([self.navigationController.viewControllers count] > 1) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void) replacePlaylistWithURL:(NSString*)urlString {
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *playlist_data = [NSData dataWithContentsOfURL:url];
	NSLog(urlString);
	Playlist *newPlaylist = [[Playlist alloc] initWithNSData: playlist_data];
	[self replacePlaylistWithPlaylist:newPlaylist];
	[newPlaylist release];
}

- (void) replacePlaylistWithURL:(NSString*)urlString withID:(NSString*)playlist_id{
	[self replacePlaylistWithURL:urlString];
	currentPlaylist.playlistid = playlist_id;
}

#pragma mark Inherited Methods


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
}

- (void)dealloc {
	[self destroyStreamer];
	[currentPlaylist release];
	[thv release];
	
	[playButtonView release];
	[play release];
	[play_pressed release];
	[pause release];
	[pause_pressed release];
	[backButtonView release];
	[back release];
	[back_pressed release];
	[forwardButtonView release];
	[forward release];
	[forward_pressed release];
	
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
    [super dealloc];
}

@end
