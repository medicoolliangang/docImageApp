//
//  iosVersionChecker.h
//  imdMeetingClient
//
//  Created by Yuhua Gong on 12-9-26.
//
//

#import <Foundation/Foundation.h>

@interface iosVersionChecker : NSObject
+ (NSData *)parseJSONDataFrom:(id)object;
+ (NSString *)parseJSONStringFrom:(id)object;
+ (id)parseJSONObjectFromData:(NSData *)JSONData;
+ (id)parseJSONObjectFromJSONString:(NSString *)JSONString;
+ (UIImage *)resizableImage:(UIImage *)image with:(UIEdgeInsets)edgeInsets;
@end
