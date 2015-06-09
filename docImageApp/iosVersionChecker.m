//
//  iosVersionChecker.m
//  imdMeetingClient
//
//  Created by Yuhua Gong on 12-9-26.
//
//

#import "iosVersionChecker.h"
#import "JSON.h"

@implementation iosVersionChecker
+ (NSData *)parseJSONDataFrom:(id)object
{
    if([NSJSONSerialization class])
    {
        return [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    }
    else
    {
        NSString *paramsString = [object JSONRepresentation];
        return [paramsString dataUsingEncoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)parseJSONStringFrom:(id)object
{
    if([NSJSONSerialization class])
    {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
        NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        return JSONString;
    }
    else
    {
        return [object JSONRepresentation];
    }
}

+ (id)parseJSONObjectFromData:(NSData *)JSONData
{
    if([NSJSONSerialization class])
    {
        return [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    }
    else
    {
        NSString *responsString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        return [responsString JSONValue];
    }
}

+ (id)parseJSONObjectFromJSONString:(NSString *)JSONString
{
    if ([NSJSONSerialization class]) {
        NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    }
    else {
        return [JSONString JSONValue];
    }
}

+ (UIImage *)resizableImage:(UIImage *)image with:(UIEdgeInsets)edgeInsets
{
    if([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)])
    {
        return [image resizableImageWithCapInsets:edgeInsets];
    }
    else
    {
        return [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top];
    }
}
@end
