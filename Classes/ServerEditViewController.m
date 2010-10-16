//
//  ServerEditViewController.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/14/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "ServerEditViewController.h"
#import "JinzoraMobileAppDelegate.h"

@implementation ServerEditViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIImage *bgImage = [UIImage imageNamed:@"background.png"];
        UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
		[[self view] addSubview:background];
		[[self view] sendSubviewToBack:background];
		self.title=@"Jinzora Settings";
		UIBarButtonItem *temporaryAddButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePreferences:)];
		self.navigationItem.rightBarButtonItem = temporaryAddButtonItem;
		[temporaryAddButtonItem release];
		servIndex = -1;
    }
    return self;
}

-(id)initWithServAtIndex:(int)index{
	if(self = [self init]){
		servIndex = index;
		if(servIndex >= 0){
			JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
			user.text = [app.p getUserforServAtIndex:servIndex];
			serv.text = [app.p getServforServAtIndex:servIndex];
			pass.text = [app.p getPassforServAtIndex:servIndex];
			name.text = [app.p getNameforServAtIndex:servIndex];
		}
	}
	return self;
}
- (void) savePreferences: (id) sender {
	NSLog(@"SAVED!");
	JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(servIndex < 0){
		[app.p addServerNamed:name.text username:user.text password:pass.text server:serv.text];
	} else {
		[app.p modifyServerAtIndex:servIndex named:name.text username:user.text password:pass.text server:serv.text];
	}
	
	[app.p writeOutToFile];
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	user.clearsOnBeginEditing = NO;
	user.clearButtonMode = UITextFieldViewModeWhileEditing;
	user.autocorrectionType = UITextAutocorrectionTypeNo;
	pass.clearsOnBeginEditing = NO;
	pass.clearButtonMode = UITextFieldViewModeWhileEditing;
	serv.clearsOnBeginEditing = NO;
	serv.clearButtonMode = UITextFieldViewModeWhileEditing;
	serv.autocorrectionType = UITextAutocorrectionTypeNo;
	name.clearsOnBeginEditing = NO;
	name.clearButtonMode = UITextFieldViewModeWhileEditing;
	name.autocorrectionType = UITextAutocorrectionTypeNo;
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
	} else if (theTextField == serv) {
		[serv resignFirstResponder];
	} else if (theTextField == name) {
		[name resignFirstResponder];
	}
	
	
	return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
