//
//  Song.m
//  jinzora_play
//
//  Created by albert on 5/3/09.
//  Copyright 2009 Planet Express. All rights reserved.
//

#import "Song.h"
#import "JinzoraMobileAppDelegate.h"
//#import "Utilities.h"
#import "JSON.h"

NSString *const SongLoadedNotification = @"SongLoadedNotification";

@interface Song (Internal)
-(void) loadMetaData;
@end

@implementation Song

@synthesize url, downloadurl, localPath, info, trackid, artist, title, needsNotification, origserv, alreadyLoaded;

-(id)initWithURL:(NSURL*)trackurl withArtist:(NSString*) art withTitle:(NSString*) tit{
	if (self = [super init]) {
		self.url = trackurl;
		self.artist = art;
		self.title = tit;
		JinzoraMobileAppDelegate *app = (JinzoraMobileAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.origserv = [app.p getCurrentApiURL];
		needsNotification = NO;
		alreadyLoaded = NO;
		notificationCenter = [[NSNotificationCenter defaultCenter] retain];
		[self performSelectorInBackground:@selector(loadMetaData) withObject:nil];
	}
	return self;
}

-(void) loadMetaData{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	int i,k;
	NSArray* queryp = [[url query] componentsSeparatedByString:@"&"];
	
	NSString* track_id=@"";
	for(NSString *queryparts in queryp){
		NSArray* parts = [queryparts componentsSeparatedByString:@"="];
		if ([((NSString*)[parts objectAtIndex:0]) isEqualToString:@"jz_path" ]) {
			track_id = ((NSString*)[parts objectAtIndex:1]);
		}
	}
	self.trackid = track_id;
	NSString *jzpath = [NSString stringWithFormat:@"%@&request=trackinfo&jz_path=%@&type=json",origserv, track_id];
	NSLog(jzpath);
    
	NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:jzpath]];
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSDictionary *browselist = (NSDictionary *)[jsonParser objectWithString:jsonString error:NULL];
	[jsonParser release];
	NSArray *browsekeys = [browselist allKeys];
	for(k=0; k<[browsekeys count]; k++){
		NSArray *toparse = [browselist objectForKey:[browsekeys objectAtIndex:k]];
		for (i=0;i<[toparse count];i++){
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[toparse objectAtIndex:i]];
            NSDictionary *metadict = [dict objectForKey:@"metadata"];
			[dict addEntriesFromDictionary:metadict];
			[dict removeObjectForKey:@"metadata"];
			[dict setObject:@"Song" forKey:@"type"];
			if([dict objectForKey:@"name"]==[NSNull null]) [dict setObject:@"null" forKey:@"name"];
			self.info = dict;
			if(needsNotification){
				
				NSNotification *notification =
				[NSNotification
				 notificationWithName:SongLoadedNotification
				 object:nil];
				[notificationCenter
				 performSelector:@selector(postNotification:)
				 onThread:[NSThread mainThread]
				 withObject:notification
				 waitUntilDone:NO];
			}
		}
	}
	alreadyLoaded = YES;
	[pool release];
    NSString *encodedpath = [self.info objectForKey:@"path"];
    encodedpath =
	[(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)encodedpath, NULL, NULL, kCFStringEncodingUTF8) autorelease];
    NSString *serv = [origserv stringByReplacingOccurrencesOfString:@"api.php" withString:@"index.php"];
    self.downloadurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&action=download&jz_path=%@&type=track&ext.m3u", serv, encodedpath]];
    NSLog([self.downloadurl absoluteString]);
}


-(NSString *)getAlbum {
	if(!info) return @"";
	return [info objectForKey:@"album"];
}

-(NSString *)getLocalPath {
	if(!self.localPath) return @"";
	return self.localPath;
}

-(NSString *)getAlbumArt {
	if(!info) return @"";
	return [info objectForKey:@"image"];
}

-(NSString *)getArtist {
	if (!info) return artist;
	return [info objectForKey:@"artist"];
}

-(NSString *)getTitle {
	if (!info) return title;
	return [info objectForKey:@"name"];
}

-(int)getLength {
	if (!info) return 0;
	return [[info objectForKey:@"length"] intValue];
}


-(void) dealloc {
	[notificationCenter release];
	[artist release];
	[title release];
	[url release];
	[trackid release];
	[info release];
	[origserv release];
	[super dealloc];
}
@end
