//
//  playlist.m
//  jinzora_play
//
//  Created by albert on 5/3/09.
//  Copyright 2009 Planet Express. All rights reserved.
//

#import "Playlist.h"


@implementation Playlist

@synthesize songs, playlistid, currentIndex;

-(id)init {
	return [self initWithNSData:nil];
}

-(id)initWithNSData:(NSData*)playlist_data {
	if (self = [super init]) {
		NSString *playlist_string;
		playlist_string = [[NSString alloc] initWithData:playlist_data encoding:NSASCIIStringEncoding];
		NSArray *playlist_tokenized = [playlist_string componentsSeparatedByString:@"\n"];
		
		songs = [Playlist parseM3U: playlist_tokenized];
		[playlist_string release];
		
		currentIndex = 0;
	}
	return self;
}

-(id) initWithSong:(Song *) song{
	if (self = [super init]) {
		songs = [[NSMutableArray alloc] initWithObjects:song,nil];
		currentIndex = 0;
	}
	return self;
}

-(id)initFromStandardFile{
	if(self = [super init]){
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		
		NSString *play_file = [documentsDirectory stringByAppendingPathComponent:@"last_playlist.dat"];
		NSMutableArray *pinfo = [NSMutableArray arrayWithContentsOfFile:play_file];
		NSLog([NSString stringWithFormat:@"numsongs:%d", [pinfo count]]);		
		songs = [[NSMutableArray alloc] init];
		if(pinfo){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			for (NSMutableDictionary *dict in pinfo){
				Song *s = [[Song alloc] initWithURL:[NSURL URLWithString:@""] withArtist:[dict objectForKey:@"artist"] withTitle:[dict objectForKey:@"title"]];
                NSString *fileName =
                [(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)[NSString stringWithFormat:@"%@_%@.mp3", s.artist, s.title], NULL, NULL, kCFStringEncodingUTF8) autorelease];
                s.info = [dict objectForKey:@"info"];
                s.localPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
				[songs addObject:s];
			}
			currentIndex = 0;
		} 
	}
	
	return self;
}

-(id) initWithSongUrl:(NSString *)url withArtist:(NSString *) artist withTitle:(NSString *) title{
	if(self = [super init]){
		NSString *m3u = [NSString stringWithFormat:@"#EXTM3U\n#EXTINF:0,%@ - %@\n%@",title,artist,url];
		NSLog(@"%@",m3u);
		songs = [Playlist parseM3U: [m3u componentsSeparatedByString:@"\n"]];
		currentIndex = 0;
			
	}
	return self;
}

-(NSUInteger) songCount {
	return [songs count];
}

-(void) clearPlaylist {
	[songs removeAllObjects];
	currentIndex = 0;
}

-(Song *) getSongAtIndex:(NSUInteger)index {
	return [songs objectAtIndex:index];
}

-(void) removeSongAtIndex:(NSUInteger)index{
	[songs removeObjectAtIndex:index];
	if(currentIndex > index) currentIndex--;
}

-(void) addSong:(Song *)song atIndex:(NSUInteger)index{
	[songs insertObject:song atIndex:index];
}

-(void) exchangeSongAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
	Song *tomove = [songs objectAtIndex:fromIndex];
	[songs removeObjectAtIndex:fromIndex];
	[songs insertObject:tomove atIndex:toIndex];
}

-(Song*) getCurrentSong {
	if ([songs count]>0) {
		return [songs objectAtIndex:currentIndex];
	} else {
		return nil;
	}
}

-(BOOL) canGoForward {
	return (currentIndex < ([songs count]-1));
}

-(BOOL) canGoBack {
	return (currentIndex > 0);
}

+(NSMutableArray*)parseM3U:(NSArray*)playlist_tokenized {
	NSLog(@" Parsing M3U");
	NSMutableArray *arr;
	arr = [[NSMutableArray alloc] init];
	int counter = 0;
	NSURL *url;
	NSString *thisartist = @"";
	NSString *thistitle = @"";
	for (NSString *s in playlist_tokenized) {
		NSLog(@"     Processing String: %@", s);
		if (counter == 0) {
			if (([s length] > 6) && (![[s substringToIndex:7] isEqualToString:@"#EXTM3U"])) {
				NSLog(@"Invalid M3U format");
				return nil;
			}
		} else {
			if (([s length] > 6) && ([[s substringToIndex:7] isEqualToString:@"#EXTINF"])) {
				s = [s substringFromIndex:([s rangeOfString:@","].location + 1)];
				NSRange divider = [s rangeOfString:@" - " options:NSBackwardsSearch];
				thisartist = [s substringToIndex:divider.location];
				thistitle = [s substringFromIndex:(divider.location + divider.length)];
			} else if ([s length] > 1) {
				url = [NSURL URLWithString: s];
				NSLog([NSString	stringWithFormat:@"Adding song with artist:%@ and title:%@", thisartist, thistitle]);
				Song *theSong = [[Song alloc] initWithURL:url withArtist:thisartist withTitle:thistitle];
				[arr addObject: theSong];
			}
		}
		counter++;
	}
	return arr;
}
- (void) addToPlaylist:(Playlist*)playlist {
	[songs addObjectsFromArray:[playlist songs]];
	[self printSongs];
}

-(void) printSongs {
	for (Song *s in songs){
		NSLog(@" %@ %@ %@ %d", [s getArtist], [s getTitle], [s.url absoluteString], [s getLength]);
	}	
}

- (void) dealloc {
	[songs release];
	[playlistid release];
	[super dealloc];
}

- (void) writeOutToFile {
    [self printSongs];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *play_file = [documentsDirectory stringByAppendingPathComponent:@"last_playlist.dat"];
	NSMutableArray *towrite = [NSMutableArray array];
	for (Song *s in songs){
		NSMutableDictionary *songdict = [NSMutableDictionary dictionary];
		[songdict setObject:[s getArtist] forKey:@"artist"];
		[songdict setObject:[s getTitle] forKey:@"title"];
        [songdict setObject:s.info forKey:@"info"];
		[towrite addObject:songdict];
	}
	[towrite writeToFile:play_file atomically:YES];
}

@end
