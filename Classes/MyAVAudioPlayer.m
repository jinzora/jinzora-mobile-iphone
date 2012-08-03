//
//  MyAVAudioPlayer.m
//
//  Created by Matt Gallagher on 27/09/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "JinzoraMobileAppDelegate.h"
#import "MyAVAudioPlayer.h"

@implementation MyAVAudioPlayer

@synthesize player;


-(id)initWithContentsOfURL:(NSURL *)localUrl error:(NSError **)error
{
    if (self = [super init])
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:localUrl error:error];
        player.delegate = self;
    }
    return self;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Local song finished playing");
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.pvc playbackStateChangedLocal];
}

- (BOOL)play
{
    return [player play];
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.pvc.playing = YES;
}

- (void)stop
{
    [player stop];
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.pvc.playing = YES;
}

- (void)pause
{
    [player pause];
    JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.pvc.playing = NO;
}

- (void)dealloc
{
    [player release];
	[super dealloc];
}

@end