//
//  PlayTableController.m
//  Settings
//
//  Created by Ruven Chu on 5/2/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "BrowseViewController.h"
#import "JinzoraMobileAppDelegate.h"
#import "JSON.h"
#import "RecentsViewController.h"

@interface BrowseViewController (Internal)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;
- (void)beginLoadingJsonData:(BOOL)isRoot;
- (void)synchronousLoadJsonData;
- (void)synchronousLoadRootJsonData;
- (void)didFinishLoadingJsonData;
@end

@implementation BrowseViewController

@synthesize numitems, baseInfo;

- (id)initWithStyle:(UITableViewStyle)style {	
	
	if (self = [super initWithStyle:style]) {
		queueDone = NO;
		imagestoload = 0;
		
		self.title = @"Browse Music";
		UIImage *img = [UIImage imageNamed:@"browseview.png"];
		UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Browse Music" image:img tag:0];
		self.tabBarItem = tab;
		[tab release];
		
		self.baseInfo = nil;
		self.numitems = 0;		
		
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:11];
		alreadyLoaded = NO;
		
		queuelock = [[NSLock alloc] init];
		imgLoadingQueue = [[NSMutableArray alloc] init];
		
		//reloadSet = [[NSMutableSet alloc] init];
		
		imgHash = [[NSMutableDictionary alloc] init];
		
		sema = [[RCSemaphore alloc] initWithCount:0];
		menuList = [[NSMutableArray alloc] init];
		
		int p;
		for(p = 0; p < 27; p++){
			NSMutableArray* letterarray = [[NSMutableArray alloc] init];
			[menuList addObject:letterarray];
			[letterarray release];
		} 
		
		UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
		temporaryBarButtonItem.title = @"Back";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		[temporaryBarButtonItem release];
	}
	
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style withDict:(NSMutableDictionary *)info {
	//note calls normal initWithStyle
	if (self = [self initWithStyle:style]) {
		
		self.title = [info objectForKey:@"name"];
		self.baseInfo = info;
		
		NSString *play = [info objectForKey:@"playlink"];
		if(play != nil && [play length] > 5) {
			UISegmentedControl *segmentedcontrol = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"add_bar_icon.png"],[UIImage imageNamed:@"play_bar_icon.png"],nil]];
			segmentedcontrol.segmentedControlStyle = UISegmentedControlStyleBar;
			segmentedcontrol.momentary = YES;
			[segmentedcontrol addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
			
			UIBarButtonItem *doublebutton = [[UIBarButtonItem alloc] initWithCustomView:segmentedcontrol];
			self.navigationItem.rightBarButtonItem = doublebutton;
			[segmentedcontrol release];
			[doublebutton release];
		}
	}
    return self;
}


- (void)segmentAction:(id)sender
{
	if([sender selectedSegmentIndex] == 0){
		[self addMusic:self];
	} else {
		[self playMusic:self];
	}
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	if (!alreadyLoaded) {
		[self showLoadingIndicators];
		[self beginLoadingJsonData: (self.baseInfo == nil) ];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	if(![[self.navigationController viewControllers] containsObject:self]){
		queueDone = YES;
		int i;
		for(i=0;i<10;i++) [sema signal];
		[imgHash removeAllObjects];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	queueDone = YES;
	[imgHash removeAllObjects];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [menuList count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[menuList objectAtIndex:(NSUInteger)section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *object = [[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	NSString *thistype = [[object objectForKey:@"type"] lowercaseString];
	UITableViewCell *cell;
	
	if ([thistype isEqualToString:@"album" ] || [thistype isEqualToString:@"track" ]) {
		
		static NSString *CellIdentifier;
		if([object objectForKey:@"hasimage"])CellIdentifier = @"AlbumArtCell";
		else CellIdentifier = @"AlbumCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		
		UILabel *lbl1 = cell.textLabel;
		UILabel *lbl2 = cell.detailTextLabel;
		
		lbl1.text = [object objectForKey:@"name"];
		lbl2.text = [object objectForKey:@"artist"];
		if ([thistype isEqualToString:@"track"]) {
			lbl2.text = [NSString stringWithFormat:@"%@ - %@", lbl2.text,[object objectForKey:@"album"]];
			UIButton *add = [UIButton buttonWithType:UIButtonTypeContactAdd ];
			[add setImage:[UIImage imageNamed:@"add_tiny.png"] forState:UIControlStateNormal];
			[add setImage:[UIImage imageNamed:@"add_pressed_tiny.png"] forState:UIControlStateHighlighted];
			[add addTarget:self action:@selector(addSong:withEvent:) forControlEvents:UIControlEventTouchUpInside];
			cell.accessoryView = add;
		} 
		
		if ([object objectForKey:@"hasimage"] != nil) {
			UIImageView *imgView = cell.imageView;
			NSString *file = [object objectForKey:@"thumbnail"];
			UIImage* touse = [imgHash objectForKey:file];
			if(!touse){
				touse = [UIImage imageNamed:@"bwicon.png"];
				[queuelock lock];
				[imgLoadingQueue addObject:indexPath];
				[queuelock unlock];
				//[reloadSet addObject:indexPath];
				[sema signal];
				//imagestoload++;
			}
			imgView.image = touse;
			
			CGFloat ratio = touse.size.height/54.0f;
			imgView.transform = CGAffineTransformMakeScale (ratio, ratio);
		}
		
	} else {
    
		static NSString *CellIdentifier;
		if([object objectForKey:@"hasimage"])CellIdentifier = @"NormalArtCell";
		else CellIdentifier = @"NormalCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		UILabel *label = cell.textLabel;
		label.text = [object objectForKey:@"name"];

		if ([thistype isEqualToString:@"user-history"]) {
			UIButton *add = [UIButton buttonWithType:UIButtonTypeContactAdd ];
			[add setImage:[UIImage imageNamed:@"add_tiny.png"] forState:UIControlStateNormal];
			[add setImage:[UIImage imageNamed:@"add_pressed_tiny.png"] forState:UIControlStateHighlighted];
			[add addTarget:self action:@selector(addSong:withEvent:) forControlEvents:UIControlEventTouchUpInside];
			cell.accessoryView = add;
		} 
		
		if ([object objectForKey:@"hasimage"]){
			UIImageView *imgView = cell.imageView;
			NSString *file = [object objectForKey:@"thumbnail"];
			UIImage* touse = [imgHash objectForKey:file];
			if(!touse){
				touse = [UIImage imageNamed:@"bwicon.png"];
				[queuelock lock];
				[imgLoadingQueue addObject:indexPath];
				[queuelock unlock];
				//[reloadSet addObject:indexPath];
				[sema signal];
				//imagestoload++;
			}
			imgView.image = touse;
			
			CGFloat ratio = touse.size.height/54.0f;
			imgView.transform = CGAffineTransformMakeScale (ratio, ratio);
		}
	}
    return cell;
}

-(void)loadImages{
	NSLog(@"starting threads!");
	while(YES){
		[sema wait];
		if(queueDone) break;
		[queuelock lock];
		NSIndexPath *indexPath = [[imgLoadingQueue objectAtIndex:([imgLoadingQueue count]-1)] retain];
		[imgLoadingQueue removeLastObject];
		[queuelock unlock];
		NSMutableDictionary *object = [[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		NSString *file = [object objectForKey:@"thumbnail"];
		NSLog(@"loading: %@",file);
		UIImage *touse = [imgHash objectForKey:file];
		if (!touse) {
			touse = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: file]]];
			if(touse) {
				[imgHash setObject:touse forKey:file];
				//if ([reloadSet containsObject:indexPath]) {
					[self performSelectorOnMainThread:@selector(reloadCellImage:) withObject:indexPath waitUntilDone:NO];
					//NSLog(@"onscreen");
				//}
			} else [object removeObjectForKey:@"hasimage"];
		}
		[self performSelectorOnMainThread:@selector(checkDone) withObject:nil waitUntilDone:NO];
	}
	NSLog(@"ending threads!");
}

-(void) checkDone{
	imagestoload--;
	if(imagestoload == 0) {
		queueDone = YES;
		int i;
		for(i=0;i<10;i++) [sema signal];
	}
}
	
-(void) reloadCellImage:(NSIndexPath *)indexPath{
	NSMutableDictionary *object = [[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	UIImageView *imgView = cell.imageView;
	UIImage* touse = [imgHash objectForKey:[object objectForKey:@"thumbnail"]];
	imgView.image = touse;
	[indexPath release];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSString *type = [[baseInfo objectForKey:@"type"] lowercaseString];
	if(self.numitems < 52 || [type isEqualToString:@"album"] || [type isEqualToString:@"playlist"]) return nil;
	
	NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
	[tempArray addObject:@"#"];
	[tempArray addObject:@"A"];
	[tempArray addObject:@"B"];
	[tempArray addObject:@"C"];
	[tempArray addObject:@"D"];
	[tempArray addObject:@"E"];
	[tempArray addObject:@"F"];
	[tempArray addObject:@"G"];
	[tempArray addObject:@"H"];
	[tempArray addObject:@"I"];
	[tempArray addObject:@"J"];
	[tempArray addObject:@"K"];
	[tempArray addObject:@"L"];
	[tempArray addObject:@"M"];
	[tempArray addObject:@"N"];
	[tempArray addObject:@"O"];
	[tempArray addObject:@"P"];
	[tempArray addObject:@"Q"];
	[tempArray addObject:@"R"];
	[tempArray addObject:@"S"];
	[tempArray addObject:@"T"];
	[tempArray addObject:@"U"];
	[tempArray addObject:@"V"];
	[tempArray addObject:@"W"];
	[tempArray addObject:@"X"];
	[tempArray addObject:@"Y"];
	[tempArray addObject:@"Z"];
	
	return tempArray;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *object = [[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	NSString *thistype = [[object objectForKey:@"type"] lowercaseString];
	if([object objectForKey:@"hasimage"] || [thistype isEqualToString:@"album" ] || [thistype isEqualToString:@"track"]) return 54;
	return 44;
}

/*

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([self.title isEqualToString:@"Browse Playlists"]) return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}
 
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
	 if (editingStyle == UITableViewCellEditingStyleDelete) {
		 // Delete the row from the data source
		 JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
		 NSMutableDictionary *info = [[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		 NSString *file = [NSString stringWithFormat:@"%@&request=deleteplaylist&jz_playlist_id=%@",[app.p getAPIStringFromPreferences],[info objectForKey:@"playlistid"]];
		 NSLog(file);
		 [NSString stringWithContentsOfURL:[NSURL URLWithString:file]];
		 [[menuList objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
		 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	 }   
	 else if (editingStyle == UITableViewCellEditingStyleInsert) {
		 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	 }   
 }*/


#pragma mark Music Actions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	NSLog(@"%@",[[[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"]);
	if([[[[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"] isEqualToString:@"Recently Played by Friends"]){
		RecentsViewController *detailViewController = [[RecentsViewController alloc] init];
		// ...
		// Pass the selected object to the new view controller.
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
		
	} else if ([[[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"browse"]) {
		BrowseViewController *bvc = [[BrowseViewController alloc] initWithStyle: UITableViewStylePlain withDict:[[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
		[self.navigationController pushViewController:bvc animated:YES];
		[bvc release]; 
		//[imgHash removeAllObjects];
	} else {
		NSString *playlink = [[[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"playlink"];
		PlayViewController *pvc = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
		[pvc replacePlaylistWithURL:playlink];
		self.navigationController.tabBarController.selectedViewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:1];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)playMusic:(id)sender{
	NSString *playlink = [baseInfo objectForKey:@"playlink"];
	PlayViewController *pvc= [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	NSString *playlistid = [baseInfo objectForKey:@"playlistid"];
	[pvc replacePlaylistWithURL:playlink withID:playlistid];
	self.navigationController.tabBarController.selectedViewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:1];
}

- (void)addMusic:(id)sender{
	NSString *playlink = [baseInfo objectForKey:@"playlink"];
	PlayViewController *myPlayViewController = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	[myPlayViewController addURLToPlaylist:playlink];
}

- (void) addSong:(UIButton*) button withEvent:(UIEvent *) event {
	NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
	NSString *playlink = [[[menuList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"playlink"];
	PlayViewController *myPlayViewController = [[[self.navigationController.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
	[myPlayViewController addURLToPlaylist:playlink];
}


#pragma mark Json Loading

- (void)beginLoadingJsonData:(BOOL)isRoot 
{
    // One way to use operations is to create an invocation operation,
    // packaging up a target and selector to run.'
	NSInvocationOperation *operation;
	if (isRoot) {
		operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadRootJsonData) object:nil];
	} else {
		operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadJsonData) object:nil];
	}
	[operationQueue addOperation:operation];
	[operation release];
}

- (void)synchronousLoadRootJsonData
{
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *file = [app.p getCurrentApiURL];
	NSLog(@"File is: %@", file);

	file = [NSString stringWithFormat:@"%@&type=json&request=home",file];
	
	NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:file]];
	SBJSON *jsonParser = [[SBJSON alloc]init];
	NSArray *browselist = (NSArray *)[jsonParser objectWithString:jsonString error:NULL];
	[jsonParser release];
	for(NSDictionary *infodict in browselist){
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:infodict];
		NSUInteger which = [BrowseViewController getIndexFromLetter:[[[dict objectForKey:@"name"] uppercaseString] characterAtIndex:0]];
		[[menuList objectAtIndex: which] addObject:dict];
		self.numitems += 1;
	}
	
	alreadyLoaded = YES;
    [self performSelectorOnMainThread:@selector(didFinishLoadingJsonData) withObject:nil waitUntilDone:NO];
}

static int compareTracks(id t1, id t2, void *context)
{
    int value1 = [[[(NSDictionary *) t1 objectForKey:@"metadata"] objectForKey:@"number"] intValue];
    int value2 = [[[(NSDictionary *) t2 objectForKey:@"metadata"] objectForKey:@"number"] intValue];
    return [[NSNumber numberWithInt:value1] compare:[NSNumber numberWithInt:value2]];
}

- (void)synchronousLoadJsonData{
	NSString *file = [baseInfo objectForKey:@"browse"];
	NSString *type = [[baseInfo objectForKey:@"type"] lowercaseString];
	file = [NSString stringWithFormat:@"%@&type=json&node_fields=name,type,album,artist,thumbnail,playlink,browse&track_fields=name,album,metadata,artist,playlink,type",file];
	
	NSLog(file);
	
	NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:file]];
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSDictionary *browselist = (NSDictionary *)[jsonParser objectWithString:jsonString error:NULL];
	[jsonParser release];
	NSArray *browsekeys = [browselist allKeys];
	for(NSString *section in browsekeys){
		NSArray *toparse = [browselist objectForKey:section];
		for (NSDictionary *infodict in toparse){
			if(queueDone) return;
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:infodict];
			if([dict objectForKey:@"name"]==[NSNull null]) [dict setObject:@"null" forKey:@"name"];
			NSUInteger which = 0;
			if(!([type isEqualToString:@"album"] || [type isEqualToString:@"playlist"] || [type isEqualToString:@"user-history"])) {
				which = [BrowseViewController getIndexFromLetter:[[[dict objectForKey:@"name"] uppercaseString] characterAtIndex:0]];
			}
			[[menuList objectAtIndex: which] addObject:dict];
		
			NSString *thumb = [dict objectForKey:@"thumbnail"];
			if(thumb != nil && [thumb length] > 5) {
				[dict setObject:@"1" forKey:@"hasimage"];
				/*[imgLoadingQueue addObject:[NSIndexPath indexPathForRow:([[menuList objectAtIndex:which] count]-1) inSection:which]];
				[sema signal];*/
				imagestoload++;
			} 
			self.numitems += 1;
		}
	}
	if([type isEqualToString:@"album"]){
		[[menuList objectAtIndex:0] sortUsingFunction:compareTracks context:nil];
	}
	alreadyLoaded = YES;
    [self performSelectorOnMainThread:@selector(didFinishLoadingJsonData) withObject:nil waitUntilDone:NO];
} 
 
- (void)didFinishLoadingJsonData{
	
	int i;
	NSMutableArray *reversed = [[NSMutableArray alloc]init];
	for (i = ([imgLoadingQueue count]-1); i >=0 ;i--){
		[reversed addObject:[imgLoadingQueue objectAtIndex:i]];
	}
	[imgLoadingQueue release];
	imgLoadingQueue = reversed;
	
    [self hideLoadingIndicators];
	[self.tableView reloadData];
	if(imagestoload > 0){
		for(i=0;i<10;i++){
			NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
			[operationQueue addOperation:operation];
			[operation release];
		}
	}
}

// LOADING OVERLAY

- (void)showLoadingIndicators
{
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:20];
        loadingLabel.textColor = [UIColor grayColor];
        loadingLabel.text = @"Loading...";
        [loadingLabel sizeToFit];
        
        static CGFloat bufferWidth = 8.0;
        
        CGFloat totalWidth = spinner.frame.size.width + bufferWidth + loadingLabel.frame.size.width;
        
        CGRect spinnerFrame = spinner.frame;
        spinnerFrame.origin.x = (self.tableView.bounds.size.width - totalWidth) / 2.0;
        spinnerFrame.origin.y = (self.tableView.bounds.size.height - spinnerFrame.size.height) / 2.0;
        spinner.frame = spinnerFrame;
        [self.tableView addSubview:spinner];
        
        CGRect labelFrame = loadingLabel.frame;
        labelFrame.origin.x = (self.tableView.bounds.size.width - totalWidth) / 2.0 + spinnerFrame.size.width + bufferWidth;
        labelFrame.origin.y = (self.tableView.bounds.size.height - labelFrame.size.height) / 2.0;
        loadingLabel.frame = labelFrame;
        [self.tableView addSubview:loadingLabel];
    }
}

- (void)hideLoadingIndicators
{
    if (spinner) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        [spinner release];
        spinner = nil;
        
        [loadingLabel removeFromSuperview];
        [loadingLabel release];
        loadingLabel = nil;
    }
}

- (void)dealloc {
	[sema release];
	//[reloadSet release];
	queueDone = YES;
	[imgLoadingQueue release];
	[queuelock release];
	[imgHash release];
	[menuList release];
	[operationQueue release];
	[spinner release];
	[loadingLabel release];
    [super dealloc];
}

+ (NSUInteger) getIndexFromLetter:(char) num {
	switch (num) {
		case 'A':
			return 1;
		case 'B':
			return 2;
		case 'C':
			return 3;
		case 'D':
			return 4;
		case 'E':
			return 5;
		case 'F':
			return 6;
		case 'G':
			return 7;
		case 'H':
			return 8;
		case 'I':
			return 9;
		case 'J':
			return 10;
		case 'K':
			return 11;
		case 'L':
			return 12;
		case 'M':
			return 13;
		case 'N':
			return 14;
		case 'O':
			return 15;
		case 'P':
			return 16;
		case 'Q':
			return 17;
		case 'R':
			return 18;
		case 'S':
			return 19;
		case 'T':
			return 20;
		case 'U':
			return 21;
		case 'V':
			return 22;
		case 'W':
			return 23;
		case 'X':
			return 24;
		case 'Y':
			return 25;
		case 'Z':
			return 26;
		case '#':
		case '0':	
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
		default:
			return 0;
	}
	return -1;
}

@end

