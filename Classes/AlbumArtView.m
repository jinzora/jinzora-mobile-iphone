//
//  AlbumArtView.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/10/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "AlbumArtView.h"
#import "JinzoraMobileAppDelegate.h"

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

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error downloading background image");
    return;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    urlData = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)incrementalData
{
    [urlData appendData:incrementalData];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imageFile = [NSString stringWithFormat:@"%@_%@.jpg", currentSong.artist, currentSong.title];
    
    NSString *localImagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageFile];
    [urlData writeToFile:localImagePath atomically:YES];
    [currentSong.info setObject:localImagePath forKey:@"image"];
}

- (void)downloadImage{
    NSString *albumArtPath = [[currentSong getAlbumArt] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:albumArtPath];
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (fileExists || [albumArtPath isEqualToString:@""] || !currentSong.artist || !currentSong.title || [app.pvc determineRandom] == FALSE)
    {
        return;
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:albumArtPath]];
    [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

-(void)loadImageinBack{
    [self downloadImage];
	NSString *file = [[currentSong getAlbumArt] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if([file isEqualToString:@""]) 
    {
        currentFile = @"noart";
    }
	else if(![file isEqualToString:currentFile] && [file length] > 0)
    {
		NSLog(@"Loading new album art: %@", file);
		[currentFile release];
        currentFile = [file retain];
	}
    [background setImage:nil];
    [self performSelectorInBackground:@selector(loadImage) withObject:nil];
}

- (void)changeImage {
	[background setImage:currentImage];
}

- (void)loadImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[currentImage release];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:currentFile];
	if([currentFile isEqualToString:@"noart"])
    {
        currentImage = [[UIImage imageNamed:@"defaultaa.jpg"] retain];
    }
	else if (fileExists)
    {
        currentImage = [[UIImage imageWithData: [NSData dataWithContentsOfFile:currentFile]] retain];
    }
    else
    {
        currentImage = [[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: currentFile]]] retain];
    }
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
