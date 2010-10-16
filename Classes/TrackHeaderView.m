//
//  TrackHeaderView.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/8/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "TrackHeaderView.h"


@implementation TrackHeaderView

@synthesize currentSong;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.autoresizesSubviews = NO;
    
		self.backgroundColor = [UIColor clearColor];
		artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 12)];
		artistLabel.backgroundColor = [UIColor clearColor];
		artistLabel.font = [UIFont boldSystemFontOfSize:12];
		artistLabel.adjustsFontSizeToFitWidth = YES;
		artistLabel.minimumFontSize = 12;
		artistLabel.textAlignment = UITextAlignmentLeft;
		artistLabel.textColor = [UIColor lightGrayColor];
		artistLabel.shadowColor = [UIColor blackColor];
		
		[self addSubview:artistLabel];
		
		//Create artist label
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 200, 12)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:12];
		titleLabel.adjustsFontSizeToFitWidth = YES;
		titleLabel.minimumFontSize = 12;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.shadowColor = [UIColor blackColor];
		[self addSubview:titleLabel];
		
		//Create album label
		albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 200, 12)];
		albumLabel.backgroundColor = [UIColor clearColor];
		albumLabel.font = [UIFont boldSystemFontOfSize:12];
		albumLabel.adjustsFontSizeToFitWidth = YES;
		albumLabel.minimumFontSize = 12;
		albumLabel.textAlignment = UITextAlignmentLeft;
		albumLabel.textColor = [UIColor lightGrayColor];
		albumLabel.shadowColor = [UIColor blackColor];
		[self addSubview:albumLabel];
	}
    return self;
}




- (void)drawRect:(CGRect)rect {
	[artistLabel setText:[currentSong getArtist]];
	[titleLabel setText:[currentSong getTitle]];
	[albumLabel setText:[currentSong getAlbum]];;
}


- (void)dealloc {
	[artistLabel release];
	[titleLabel release];
	[albumLabel release];
    [super dealloc];
}


@end
