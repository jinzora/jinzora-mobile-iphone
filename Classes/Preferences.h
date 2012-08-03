//
//  Preferences.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 5/17/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Preferences : NSObject {
	NSMutableDictionary *info;
	NSMutableArray *servers;
	NSMutableArray *friends;
    BOOL random;
}

-(void) modifyServerAtIndex:(int)servIndex named:(NSString *) name username:(NSString *)user password:(NSString *)pass server:(NSString *)serv;
-(void) exchangeServerAtIndex:(int) indexFrom withIndex:(int)indexTo;
-(void) addServerNamed:(NSString *)name username:(NSString *)user password:(NSString *)pass server:(NSString*)serv;
-(void) exchangeFriendAtIndex:(int) indexFrom withIndex:(int)indexTo;
-(void) addFriendNamed:(NSString *)name;
-(void) deleteFriendAtIndex:(int) index;
-(NSString *) getFriendAtIndex:(int) index;
-(int) getNumFriends;
-(NSString *) getUserforServAtIndex:(int) index;
-(NSString *) getServforServAtIndex:(int) index;
-(NSString *) getPassforServAtIndex:(int) index;
-(void) deleteServAtIndex:(int) index;
-(void) setCurrURLtoServAtIndex:(int) index;
-(NSString *) getApiURLforServAtIndex:(int) index;
-(NSString *) getNameforServAtIndex:(int) index;
-(int) getNumServers;
- (void) writeOutToFile;
- (NSString*) getCurrentApiURL;
- (void) setCurrentApiURLTo: (NSString *) url;
- (NSString *) getRepUser;
- (void) setRepUserTo: (NSString *) user;
- (NSString *) getRepPassword;
- (void) setRepPasswordTo: (NSString *) user;

@property (nonatomic, retain) NSMutableDictionary *info;
@property (nonatomic, retain) NSMutableArray *servers;
@property (nonatomic, retain) NSMutableArray *friends;
@property BOOL random;
@end
