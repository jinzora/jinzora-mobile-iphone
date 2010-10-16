//
//  TrackHeaderView.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/8/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"


@interface TrackHeaderView : UIView {
	UILabel *titleLabel;
	UILabel *artistLabel;
	UILabel *albumLabel;
	IBOutlet Song *currentSong;
}

@property (retain) IBOutlet Song *currentSong;

@end
