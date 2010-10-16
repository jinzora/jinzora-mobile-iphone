//
//  Utilities.h
//  JinzoraMobile
//
//  Created by Ruven Chu on 7/2/09.
//  Copyright 2009 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnection.h"
#import "XMLRPCRequest+RuvenExtensions.h"

@interface Utilities : NSObject {

}

+(NSString *)cleanUpPhoneNumber:(NSString *)phoneNum;
@end