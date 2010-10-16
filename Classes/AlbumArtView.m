//
//  AlbumArtView.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/10/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "AlbumArtView.h"


@implementation AlbumArtView

- (void)drawRect:(CGRect)rect {
	[self loadImageinBack];
}

- (void) awakeFromNib {
	//self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,320.0f,320.0f);
	background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)]; 
	[self addSubview:background];
	[self sendSubviewToBack:background];
}

-(void)loadImageinBack{
	NSString *file = [[currentSong getAlbumArt] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]; //  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	if([file isEqualToString:@""]) file = @"noart";
	if(![file isEqualToString:currentFile] && [file length] > 0){
		NSLog(@"Loading new album art: %@", file);
		[currentFile release];
		currentFile = [file retain];
		[background setImage:nil];
		[self performSelectorInBackground:@selector(loadImage) withObject:nil];
	}
}

- (void)changeImage {
	[background setImage:currentImage];
}

- (void)loadImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[currentImage release];
	
	if([currentFile isEqualToString:@"noart"]) currentImage = [[UIImage imageNamed:@"defaultaa.jpg"] retain];
	else currentImage = [[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: currentFile]]] retain];
	[self performSelectorOnMainThread:@selector(changeImage) withObject:nil waitUntilDone:NO];
	[pool release];
}


- (void)dealloc {
	[currentFile release];
	[currentImage release];
	[background release];
    [super dealloc];
}


@end
