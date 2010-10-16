//
//  XMLRPCRequest+RuvenExtensions.m
//  Settings
//
//  Created by Ruven Chu on 7/15/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "XMLRPCRequest+RuvenExtensions.h"


@implementation XMLRPCRequest(RuvenExtensions)

- (void)setHTTPHeader: (NSString *)key withValue:(NSString *) value
{
	if ([self userAgent] == nil)
	{
		[_request addValue: value forHTTPHeaderField: key];
	}
	else
	{
		[_request setValue: value forHTTPHeaderField: key];
	}
}
	
- (NSString *)getHTTPHeader: (NSString *)key
{
	return [_request valueForHTTPHeaderField: key];
}

- (NSString *) getBodyString{
	return [_encoder source];;
}

@end
