//
//  AlbumArtView.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/10/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface AlbumArtView : UIView {
	IBOutlet Song *currentSong;
	UIImageView *background;
	UIImage *currentImage;
	NSString *currentFile;
}

-(void)loadImageinBack;

@end
