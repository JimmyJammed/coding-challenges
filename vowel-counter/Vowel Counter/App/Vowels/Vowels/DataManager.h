//
//  DataManager.h
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
-(void)serverRequest:(NSString *)request withData:(NSDictionary *)data completion:(void (^)(NSDictionary *results))completion;

@end
