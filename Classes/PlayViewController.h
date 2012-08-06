//
//  PlayViewController.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/9/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamer.h"
#import "MyAVAudioPlayer.h"
#import "Song.h"
#import "Playlist.h"
#import "TrackHeaderView.h"
#import "AlbumArtView.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface PlayViewController : UIViewController {
	IBOutlet UIView *volumeSlider;
	IBOutlet AlbumArtView *albumArt;
	IBOutlet UILabel *startLabel;
	IBOutlet UILabel *endLabel;
	IBOutlet UIProgressView *progressView;
	IBOutlet UISlider *progressSlider;
	BOOL progressDown;
	IBOutlet UIActivityIndicatorView *playSpinner;
	
	IBOutlet Playlist *currentPlaylist;
	IBOutlet Song *currentSong;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	
    MyAVAudioPlayer *localPlayer;
	TrackHeaderView *thv;
	
	BOOL playing;
	UIImageView *playButtonView;
	UIImage *play;
	UIImage *play_pressed;
	UIImage *pause;
	UIImage *pause_pressed;
	UIImageView *backButtonView;
	UIImage *back;
	UIImage *back_pressed;
	UIImageView *forwardButtonView;
	UIImage *forward;
	UIImage *forward_pressed;
    
	BOOL scrobbled;
    NSMutableData *urlData;
}

@property (nonatomic, retain) Playlist *currentPlaylist;
@property BOOL playing;
@property (assign) AudioStreamer *streamer;
@property (assign) MyAVAudioPlayer *localPlayer;

- (IBAction)nextTrack:(id)sender;
- (IBAction)prevTrack:(id)sender;
- (IBAction)playPressed:(id)sender;
- (void)updateProgress:(NSTimer *)aNotification;
- (void) replacePlaylistWithURL:(NSString*)urlString;
- (void) replacePlaylistWithPlaylist:(Playlist *) newPlaylist;
- (void) replacePlaylistWithPlaylistandTrack:(Playlist *) newPlaylist :(NSUInteger) trackNumber;
- (void) replacePlaylistWithURL:(NSString*)urlString withID:(NSString*)playlist_id;
-(void) addPlaylistToPlaylist:(Playlist *)newPlaylist;
- (void) addURLToPlaylist:(NSString*)urlString;
- (void)changeTrack:(int) index;
- (void) playSong;
- (IBAction) stop;
- (IBAction)changeProgress:(id)sender;
- (IBAction)clickProgressBar:(id)sender;
- (IBAction)updateText:(id)sender;
- (void)destroyStreamer;
- (void)resetProgress;
- (void)playbackStateChangedLocal;
- (BOOL) determineRandom;
- (BOOL) songInDownloads;

@end
