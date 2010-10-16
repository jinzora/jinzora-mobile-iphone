//
//  RCSemaphore.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/17/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "RCSemaphore.h"


@implementation RCSemaphore

-(id) init{
	if( self = [super init]){
		pthread_mutex_init(&holdMutex, NULL);
		pthread_mutex_init(&varMutex, NULL);
		count = 1;
	}
	return self;
}

-(id) initWithCount:(int) start{
	if(self = [super init]){
		pthread_mutex_init(&holdMutex, NULL);
		pthread_mutex_init(&varMutex, NULL);
		if(start == 0) pthread_mutex_lock(&holdMutex);
		count = start;
	}
	return self;
	
}

-(void) wait{
	pthread_mutex_lock(&holdMutex);
	pthread_mutex_lock(&varMutex);
	count--;
	if(count != 0) pthread_mutex_unlock(&holdMutex);
	pthread_mutex_unlock(&varMutex);
}

-(void) signal{
	pthread_mutex_lock(&varMutex);
	if(count == 0) pthread_mutex_unlock(&holdMutex);
	count++;
	pthread_mutex_unlock(&varMutex);
}

-(int) getCount{
	return count;
}

-(void) dealloc {
	pthread_mutex_destroy(&holdMutex);
	pthread_mutex_destroy(&varMutex);
	[super dealloc];
}

@end
