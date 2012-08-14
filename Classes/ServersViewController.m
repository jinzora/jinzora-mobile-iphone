//
//  ServersViewController.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 11/3/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "ServersViewController.h"
#import "ServerEditViewController.h"
#import "JinzoraMobileAppDelegate.h"

@implementation ServersViewController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.title = @"Servers";
		UIImage *img = [UIImage imageNamed:@"serversview.png"];
		UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Servers" image:img tag:2];
		self.tabBarItem = tab;
		[tab release];
		
		UIBarButtonItem *temporaryAddButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+ Server" style:UIBarButtonItemStylePlain target:self action:@selector(newServer:)];
		self.navigationItem.rightBarButtonItem = temporaryAddButtonItem;
		[temporaryAddButtonItem release];
		
		//UIBarButtonItem *temporaryDeleteButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(removeFriend)];
		self.navigationItem.leftBarButtonItem = [self editButtonItem];
		//[temporaryDeleteButtonItem release];
		
		UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
		temporaryBarButtonItem.title = @"Cancel";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		[temporaryBarButtonItem release];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSString *isfirst = [prefs objectForKey:@"isfirst"];
        JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
		if(!isfirst) {
			[prefs setObject:@"yes" forKey:@"isfirst"];
			[app.p addServerNamed:@"Enter server info here" username:@"" password:@"" server:@"http://live.jinzora.org/"];
			[app.p setCurrURLtoServAtIndex:0];
		}
        NSUInteger selected_serv = [[NSUserDefaults standardUserDefaults] integerForKey:@"server"];
        if (selected_serv)
        {
            [app.p setCurrURLtoServAtIndex:selected_serv];
        }
        NSArray* components = [NSArray arrayWithObjects:@"49", @"74", @"27", @"73", @"20", @"6d", @"79", @"20", @"64", @"61", @"74", @"61", nil];
        NSMutableString * newString = [NSMutableString string];
        
        for ( NSString * component in components ) {
            int value = 0;
            sscanf([component cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
            [newString appendFormat:@"%c", (char)value];
        }
        NSLog(newString);
        for (int i = 0; i < [app.p getNumServers]; i++)
        {
            if ([[app.p getNameforServAtIndex:i] isEqualToString:newString])
            {
                app.p.random = TRUE;
                NSLog(@"Random is true");
                break;
            }
        }
    }
    return self;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	ServerEditViewController *jsvc = [[ServerEditViewController alloc] initWithServAtIndex:indexPath.row];
    [self.navigationController pushViewController:jsvc animated:YES];
    [jsvc release];
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
	[[self tableView] reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"number: %d", [app.p getNumServers]);
    return [app.p getNumServers];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Set up the cell...
	UILabel *label = cell.textLabel;
	
	label.text = [app.p getNameforServAtIndex:indexPath.row];
	NSLog(@"TEXTIS: %@", [app.p getNameforServAtIndex:indexPath.row]);
	NSString *cellserv = [app.p getApiURLforServAtIndex:indexPath.row];
	
	if ([cellserv isEqualToString:[app.p getCurrentApiURL]]){
		[label setTextColor:[UIColor blueColor]];
	} else {
		[label setTextColor:[UIColor blackColor]];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *before = [[NSString alloc] initWithString:[app.p getCurrentApiURL]];
	[app.p setCurrURLtoServAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"server"];
	NSString *after = [app.p getCurrentApiURL];
	if(![before isEqualToString:after]) [app resetBrowse];
    [before release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[[self tableView] reloadData];
}

- (IBAction)newServer:(id)sender{
	ServerEditViewController *jsvc = [[ServerEditViewController alloc] init];
    [self.navigationController pushViewController:jsvc animated:YES];
    [jsvc release];
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
		JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
		[app.p deleteServAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}




// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.p exchangeServerAtIndex:fromIndexPath.row withIndex:toIndexPath.row]; 
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



- (void)dealloc {
    [super dealloc];
}


@end

