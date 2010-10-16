//
//  Utilities.m
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/2/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import "Utilities.h"
#import "JinzoraMobileAppDelegate.h"
#import "NSData+Base64.h"
@implementation Utilities

+(NSString *)cleanUpPhoneNumber:(NSString *)phoneNum{
	// get a scanner, initialised with our input string
	NSScanner *scanner = [NSScanner scannerWithString:phoneNum];
	// create a mutable output string (empty for now)
	NSMutableString *cleanedString = [[NSMutableString alloc] init];
	NSCharacterSet *controlCharSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	[scanner setCharactersToBeSkipped:controlCharSet];
	while ([scanner isAtEnd] == NO) {
		NSString *outString;
		// scan up to the next instance of one of the control characters
		if ([scanner scanUpToCharactersFromSet:controlCharSet intoString:&outString]) {
			// add the string chunk to our output string
			[cleanedString appendString:outString];
		}
	}
	NSString *toreturn = [(NSString *)[cleanedString copy] autorelease];
	[cleanedString release];
	
	return toreturn;
}

@end
