//
//  RepSettingsViewController.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/16/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "RepSettingsViewController.h"
#import "JinzoraMobileAppDelegate.h"
#import "NSData+Base64.h"

@implementation RepSettingsViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIImage *bgImage = [UIImage imageNamed:@"background.png"];
        UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
		[[self view] addSubview:background];
		[[self view] sendSubviewToBack:background];
		self.title=@"Mr. P Settings";
		UIImage *img = [UIImage imageNamed:@"preferencesview.png"];
		UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Settings" image:img tag:3];
		self.tabBarItem = tab;
		[tab release];
		//UIBarButtonItem *temporaryAddButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePreferences:)];
		//self.navigationItem.rightBarButtonItem = temporaryAddButtonItem;
		//[temporaryAddButtonItem release];
    }
    return self;
}

- (void) savePreferences: (id) sender {
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.p setRepUserTo:user.text];
	[app.p setRepPasswordTo:((pass.text) ? pass.text : @"") ];
	NSString *url = [NSString stringWithFormat:
					 @"http://mfischer.stanford.edu/install/?username=%@&password=%@&tag=Jinzora",
					 [app.p getRepUser],[app.p getRepPassword]];
	
	NSString *final = [NSString stringWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:
																			  NSASCIIStringEncoding]]];
	//NSString *serverfile = [NSString stringWithFormat:@"http://paneer.stanford.edu:2002/prpl-directory/ws/?op=get&prplId=%@&key=PCB_SERVER_API_URL", user.text];
	//NSString *servloc = [[NSString stringWithContentsOfURL:[NSURL URLWithString:[serverfile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] 
	//			 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//[app.p setRepServerTo:servloc];

	//NSString *start = [NSString stringWithFormat: @"%@:%@", ((user.text) ? (user.text) : @""),((pass.text) ? (pass.text) : @"")];
	//NSData *data = [start dataUsingEncoding:NSASCIIStringEncoding];
	//NSString *encoded = [data base64EncodedString];
	
	//[app.p setRepAuthHeaderTo:[NSString stringWithFormat:@"Basic %@",encoded]];
	
	[app.p writeOutToFile];
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	user.text = [app.p getRepUser];
	user.clearsOnBeginEditing = NO;
	user.clearButtonMode = UITextFieldViewModeWhileEditing;
	user.autocorrectionType = UITextAutocorrectionTypeNo;
	pass.text = [app.p getRepPassword];
	pass.clearsOnBeginEditing = NO;
	pass.clearButtonMode = UITextFieldViewModeWhileEditing;
	pass.autocorrectionType = UITextAutocorrectionTypeNo;
}

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

#pragma mark Text Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =	midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == user){
		[user resignFirstResponder];
	} else if (theTextField == pass) {
		[pass resignFirstResponder];
	}
	[self savePreferences:self];
	
	return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
