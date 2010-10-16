//
//  XMLRPCRequest+RuvenExtensions.h
//  Settings
//
//  Created by Ruven Chu on 7/15/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCRequest.h"

@interface XMLRPCRequest(RuvenExtensions)

- (void)setHTTPHeader: (NSString *)key withValue:(NSString *) value;
- (NSString *)getHTTPHeader: (NSString *)key;
- (NSString *) getBodyString;

@end
