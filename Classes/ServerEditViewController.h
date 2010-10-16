//
//  ServerEditViewController.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/14/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerEditViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *user;
	IBOutlet UITextField *pass;
	IBOutlet UITextField *serv;
	IBOutlet UITextField *name;
	CGFloat animatedDistance;
	int servIndex;
}

-(id)initWithServAtIndex:(int)index;

@end
