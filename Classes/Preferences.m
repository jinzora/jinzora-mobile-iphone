//
//  Preferences.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 5/17/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "Preferences.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Preferences

@synthesize info, servers, friends, random;

- (void) dealloc {
	[servers release];
	[info release];
	[super dealloc];
}

-(void) exchangeServerAtIndex:(int) indexFrom withIndex:(int)indexTo{
	NSMutableDictionary* tomove = [[servers objectAtIndex:indexFrom] retain];
	[servers removeObjectAtIndex:indexFrom];
	[servers insertObject:tomove atIndex:indexTo];
	[tomove release];
}

- (id) init {
	if (self = [super init]){
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		
		NSString *pref_file = [documentsDirectory stringByAppendingPathComponent:@"preferences.dat"];
		self.info = [NSMutableDictionary dictionaryWithContentsOfFile:pref_file];
		if (info == nil) self.info = [NSMutableDictionary dictionary];
		if([self.info objectForKey:@"currfile"] == nil) [self.info setObject:@"" forKey:@"currfile"];
		pref_file = [documentsDirectory stringByAppendingPathComponent:@"servers.dat"];
		self.servers = [NSMutableArray arrayWithContentsOfFile:pref_file];
		if (servers == nil) self.servers = [NSMutableArray array];
		
		pref_file = [documentsDirectory stringByAppendingPathComponent:@"friends.dat"];
		self.friends = [NSMutableArray arrayWithContentsOfFile:pref_file];
		if (friends == nil) self.friends = [NSMutableArray array];
        self.random = FALSE;
	}
	
	return self;
}

- (void) writeOutToFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pref_file = [documentsDirectory stringByAppendingPathComponent:@"preferences.dat"];
	[info writeToFile:pref_file atomically:YES];
	pref_file = [documentsDirectory stringByAppendingPathComponent:@"servers.dat"];
	[servers writeToFile:pref_file atomically:YES];
	pref_file = [documentsDirectory stringByAppendingPathComponent:@"friends.dat"];
	[friends writeToFile:pref_file atomically:YES];
	
}

-(void) addServerNamed:(NSString *)name username:(NSString *)user password:(NSString *)pass server:(NSString*)serv{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:name forKey:@"name"];
    if ([serv hasSuffix:@"index.php"])
    {
        serv = [serv substringToIndex:([serv length] - [@"index.php" length]) ];
    }
    if ([serv hasSuffix:@"/"])
    {
        serv = [serv substringToIndex:([serv length] - [@"/" length])];
    }
    if ( !([serv hasPrefix:@"http://"] || [serv hasPrefix:@"https://"]) )
    {
        serv = [NSString stringWithFormat:@"http://%@", serv];
    }
	[dict setObject:serv forKey:@"serv"];
	[dict setObject:pass forKey:@"pass"];
	[dict setObject:user forKey:@"user"];
	[servers addObject:dict];
}

-(void) setCurrURLtoServAtIndex:(int) index{
	[self.info setValue:[self getApiURLforServAtIndex:index] forKey:@"currfile"];
}
	
-(NSString *) getApiURLforServAtIndex:(int) index{
	NSDictionary *dict = [servers objectAtIndex:index];
	const char *cStr = [[dict objectForKey:@"pass"] UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, strlen(cStr), result);
	NSString *md5 = [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
	return [NSString stringWithFormat:@"%@/api.php?user=%@&pass=%@&pw_hashed=true", [dict objectForKey:@"serv"], [dict objectForKey:@"user"], md5];
}

-(void) exchangeFriendAtIndex:(int) indexFrom withIndex:(int)indexTo{
	NSMutableDictionary* tomove = [[friends objectAtIndex:indexFrom] retain];
	[friends removeObjectAtIndex:indexFrom];
	[friends insertObject:tomove atIndex:indexTo];
	[tomove release];
}
-(void) addFriendNamed:(NSString *)name{
	[friends addObject:name];
}

-(int) getNumFriends{
	return [friends count];
}

-(void) deleteFriendAtIndex:(int) index{
	[friends removeObjectAtIndex:index];
}
-(NSString *) getFriendAtIndex:(int) index{
	return [friends objectAtIndex:index];
}

-(void) deleteServAtIndex:(int) index{
	[servers removeObjectAtIndex:index];
}

-(NSString *) getNameforServAtIndex:(int) index{
	return [[servers objectAtIndex:index] objectForKey:@"name"];
}

-(NSString *) getUserforServAtIndex:(int) index{
	return [[servers objectAtIndex:index] objectForKey:@"user"];
}

-(NSString *) getServforServAtIndex:(int) index{
	return [[servers objectAtIndex:index] objectForKey:@"serv"];
}

-(NSString *) getPassforServAtIndex:(int) index{
	return [[servers objectAtIndex:index] objectForKey:@"pass"];
}

-(void) modifyServerAtIndex:(int)servIndex named:(NSString *) name username:(NSString *)user password:(NSString *)pass server:(NSString *)serv{
	NSMutableDictionary *dict = [servers objectAtIndex:servIndex];
	[dict setObject:name forKey:@"name"];
    if ([serv hasSuffix:@"index.php"])
    {
        serv = [serv substringToIndex:([serv length] - [@"index.php" length]) ];
    }
    if ([serv hasSuffix:@"/"])
    {
        serv = [serv substringToIndex:([serv length] - [@"/" length])];
    }
    if ( !([serv hasPrefix:@"http://"] || [serv hasPrefix:@"https://"]) )
    {
        serv = [NSString stringWithFormat:@"http://%@", serv];
    }
	[dict setObject:serv forKey:@"serv"];
	[dict setObject:pass forKey:@"pass"];
	[dict setObject:user forKey:@"user"];
}

-(int) getNumServers{
	return [servers	count];
}

- (NSString*) getCurrentApiURL {
	return [self.info objectForKey:@"currfile"];
}

- (void) setCurrentApiURLTo: (NSString *) url{
	[self.info setValue:url forKey:@"currfile"];
}

- (NSString *) getRepUser{
	return [self.info valueForKey:@"ruser"];
}

- (void) setRepUserTo:(NSString*) user{
	[self.info setValue:user forKey:@"ruser"];
}

- (NSString *) getRepPassword{
	return [self.info valueForKey:@"rpass"];
}

- (void) setRepPasswordTo:(NSString*) pass{
	[self.info setValue:pass forKey:@"rpass"];
}

@end
