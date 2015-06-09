//
//  userLocalData.h
//  docImageApp
//
//  Created by 侯建政 on 8/27/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userLocalData : NSObject
+ (void)saveObject:(id)object toUserDefaultByKey:(NSString *)key;
+ (void)saveImdToken:(NSString *)token;
+ (NSString *)getImdToken;
+ (void)saveUserName:(NSString *)userName;
+ (NSString *)getUserName;
+ (void)saveUserPhone:(NSString *)userPhone;
+ (NSString *)getUserPhone;
//存取最热的获取资源的时间
+ (void)saveHotresourceTime:(NSString *)str;
+ (NSString *)getHotresourceTime;
//存取评论最多的获取资源的时间
+ (void)saveCommentresourceTime:(NSString *)str;
+ (NSString *)getCommentresourceTime;
  //存储头像
+ (void)savePhotoFilePath:(NSString *)path;
+ (NSString*)getPhotoFilePath;
+ (void)savePhotoId:(NSString *)pid;
+ (NSString*)getPhotoId;
//存取最热的所有CASE的数量
+ (void)saveHotCount:(NSInteger)count;
+ (float)getHotCount;
//存取最新的所有CASE的数量
+ (void)saveNewCount:(NSInteger)count;
+ (float)getNewCount;
//存取评论最多的所有CASE的数量
+ (void)saveCommentCount:(NSInteger)count;
+ (float)getCommentCount;
@end
