//
//  playlist.h
//  jinzora_play
//
//  Created by albert on 5/3/09.
//  Copyright 2009 Planet Express. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"

@interface Playlist : NSObject {
	NSMutableArray *songs;
	NSMutableArray *notifylist;
	int currentIndex;
	NSString *playlistid;
}

+(NSMutableArray*)parseM3U:(NSArray*)playlist_tokenized;
-(NSUInteger) songCount;
-(id) init;
-(id) initWithNSData:(NSData*) playlist_data;
- (void) addToPlaylist:(Playlist*) playlist;
- (void) printSongs;
- (void) clearPlaylist;
- (Song*) getCurrentSong;
- (BOOL) canGoForward;
- (BOOL) canGoBack;
-(void) addSong:(Song *)song atIndex:(NSUInteger)index;
-(void) removeSongAtIndex:(NSUInteger)index;
-(void) exchangeSongAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex ;
-(NSUInteger) songCount;
-(Song *) getSongAtIndex:(NSUInteger)index;
- (void) writeOutToFile;
-(id)initFromStandardFile;
-(id) initWithSong:(Song *) song;
-(id) initWithSongUrl:(NSString *)url withArtist:(NSString *) artist withTitle:(NSString *) title;

@property (retain) NSMutableArray *songs;
@property int currentIndex;
@property (copy) NSString *playlistid;

@end
