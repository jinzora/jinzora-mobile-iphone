//
//  RCSemaphore.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/17/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>


@interface RCSemaphore : NSObject {
	pthread_mutex_t varMutex;
	pthread_mutex_t holdMutex;
	int count;
}

-(id) initWithCount:(int) start;
-(void) wait;
-(void) signal;
-(int) getCount;

@end
