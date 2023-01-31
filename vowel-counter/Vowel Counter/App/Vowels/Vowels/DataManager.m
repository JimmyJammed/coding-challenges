//
//  DataManager.m
//  Vowels
//
//  Created by James Hickman on 8/5/14.
//  Copyright (c) 2014 NitWit Studios. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager
-(void)serverRequest:(NSString *)request withData:(NSDictionary *)data completion:(void (^)(NSDictionary *results))completion{
    NSMutableDictionary *postObject = [[NSMutableDictionary alloc] init];
    [postObject setValue:request forKey:@"request"];
    for(NSString *key in [data allKeys]){
        [postObject setObject:[data valueForKey:key] forKey:key];
    }
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postObject options:0 error:NULL];
    NSString *postLength = [NSString stringWithFormat:@"%li", (unsigned long)[postData length]];
    
    NSMutableURLRequest *URLrequest = [[NSMutableURLRequest alloc] init];
    [URLrequest setURL:[NSURL URLWithString:API_PATH]];
    [URLrequest setHTTPMethod:@"POST"];
    [URLrequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [URLrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [URLrequest setHTTPBody:postData];
    [URLrequest setTimeoutInterval:20];
    
    [NSURLConnection sendAsynchronousRequest:URLrequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             if( data != nil ) {
                 NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                 completion(response);
             } else {
                 NSLog(@"Error getting data: %@",error.localizedDescription);
                 completion(nil);
             }
         }
         else if ([data length] == 0 && error == nil){
             completion(nil);
         }
         else if (error != nil && error.code == NSURLErrorTimedOut){
             completion(nil);
         }
         else if (error != nil){
             completion(nil);
         }
     }];
    
}
@end
