//
//  PlayTableController.h
//  Settings
//
//  Created by Ruven Chu on 5/2/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "RCSemaphore.h"

typedef enum
	{
		AS_STARTED = 0,
		AS_TABLE_LOADED,
		AS_IMAGES_DONE
	} BrowseControllerState;

@interface BrowseViewController : UITableViewController {
	NSMutableArray *menuList;
	NSMutableDictionary *baseInfo;
	NSMutableDictionary *imgHash;
	
	//NSMutableSet *reloadSet;
	NSMutableArray *imgLoadingQueue;
	NSLock *queuelock;
	
	int numitems;
	int imagestoload;
	
	NSOperationQueue *operationQueue;
	
	BOOL queueDone;
	BOOL alreadyLoaded;
	
	UIActivityIndicatorView *spinner;
    UILabel *loadingLabel;
	
	RCSemaphore *sema;
}

@property int numitems;
@property (nonatomic, retain) NSMutableDictionary* baseInfo;

- (id)initWithStyle:(UITableViewStyle)style withDict:(NSMutableDictionary *) info;
+ (NSUInteger) getIndexFromLetter:(char) num;
- (void)playMusic:(id)sender;
- (void)addMusic:(id)sender;

@end