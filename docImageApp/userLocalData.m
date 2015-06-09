//
//  userLocalData.m
//  docImageApp
//
//  Created by 侯建政 on 8/27/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "userLocalData.h"
#import "UrlCenter.h"

#define APP_IMD_TOKEN @"imdToken%@"
#define HOT_RESOURCE_TIME @"hotResourcetime"
#define COMMENT_RESOURCE_TIME @"commentResourcetime"
#define APP_IMD_USERNAME @"userName"
#define APP_IMD_USERPHONE @"phoneNumber"
#define PHOTO_IMD_IMAGE @"photoImage"
#define PHOTO_IMD_ID @"photoId"

#define NEW_IMD_COUNT @"new_count"
#define HOT_IMD_COUNT @"hot_count"
#define COMMENT_IMD_COUNT @"comment_count"
@implementation userLocalData
+ (BOOL)checkValidObject:(id)object
{
  if (object == nil) {
    return NO;
  }
  else if ([object isMemberOfClass:[NSString class]] && ! [(NSString *)object length]) {
    return NO;
  }
  else if ([object isMemberOfClass:[NSArray class]] && ! [(NSArray *)object count]) {
    return NO;
  }
  else if ([object isMemberOfClass:[NSDictionary class]] && ! [[(NSDictionary *)object allKeys] count]) {
    return NO;
  }
  else if ([object isMemberOfClass:[NSNumber class]] && ! (NSNumber *)object) {
    return NO;
  }
  else {
    return YES;
  }
}

+ (void)saveObject:(id)object toUserDefaultByKey:(NSString *)key
{
  if ([self checkValidObject:object]) {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
  }
  else {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (id)objectFromUserDefaultForKey:(NSString *)key
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


+ (void)saveImdToken:(NSString *)token
{
  [self saveObject:token toUserDefaultByKey:[NSString stringWithFormat:APP_IMD_TOKEN,DOCIMAGEAPP_SERVER]];
}
+ (NSString *)getImdToken
{
  return [self objectFromUserDefaultForKey:[NSString stringWithFormat:APP_IMD_TOKEN,DOCIMAGEAPP_SERVER]];
}
+ (void)saveUserName:(NSString *)userName
{
  [self saveObject:userName toUserDefaultByKey:APP_IMD_USERNAME];
}
+ (NSString *)getUserName
{
  return [self objectFromUserDefaultForKey:APP_IMD_USERNAME];
}
+ (void)saveUserPhone:(NSString *)userPhone
{
  [self saveObject:userPhone toUserDefaultByKey:APP_IMD_USERPHONE];
}
+ (NSString *)getUserPhone
{
  return [self objectFromUserDefaultForKey:APP_IMD_USERPHONE];
}
+ (void)saveHotresourceTime:(NSString *)str
{
  [self saveObject:str toUserDefaultByKey:HOT_RESOURCE_TIME];
}
+ (NSString *)getHotresourceTime
{
  return [self objectFromUserDefaultForKey:HOT_RESOURCE_TIME];
}
+ (void)saveCommentresourceTime:(NSString *)str
{
  [self saveObject:str toUserDefaultByKey:COMMENT_RESOURCE_TIME];
}
+ (NSString *)getCommentresourceTime
{
  return [self objectFromUserDefaultForKey:COMMENT_RESOURCE_TIME];
}
+ (void)savePhotoFilePath:(NSString *)path
{
  [self saveObject:path toUserDefaultByKey:PHOTO_IMD_IMAGE];
}
+ (NSString*)getPhotoFilePath
{
  return [self objectFromUserDefaultForKey:PHOTO_IMD_IMAGE];
}
+ (void)savePhotoId:(NSString *)pid
{
  [self saveObject:pid toUserDefaultByKey:PHOTO_IMD_ID];
}
+ (NSString*)getPhotoId
{
  return [self objectFromUserDefaultForKey:PHOTO_IMD_ID];
}
  //存取最热的所有CASE的数量
+ (void)saveHotCount:(NSInteger)count
{
  [self saveObject:[NSNumber numberWithInteger:count] toUserDefaultByKey:HOT_IMD_COUNT];
}
+ (float)getHotCount
{
  
  return [[self objectFromUserDefaultForKey:HOT_IMD_COUNT] floatValue];
}
  //存取最新的所有CASE的数量
+ (void)saveNewCount:(NSInteger)count
{
[self saveObject:[NSNumber numberWithInteger:count] toUserDefaultByKey:NEW_IMD_COUNT];
}
+ (float)getNewCount
{
return [[self objectFromUserDefaultForKey:NEW_IMD_COUNT] floatValue];
}
  //存取评论最多的所有CASE的数量
+ (void)saveCommentCount:(NSInteger)count
{
[self saveObject:[NSNumber numberWithInteger:count] toUserDefaultByKey:COMMENT_IMD_COUNT];
}
+ (float)getCommentCount
{
return [[self objectFromUserDefaultForKey:COMMENT_IMD_COUNT] floatValue];
}
@end
