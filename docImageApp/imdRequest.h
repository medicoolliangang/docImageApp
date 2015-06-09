//
//  imdRequest.h
//  docImageApp
//
//  Created by 侯建政 on 8/19/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface imdRequest : NSObject<ASIHTTPRequestDelegate>
+(ASIHTTPRequest*) getRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType;
+(ASIHTTPRequest*) postRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType postData:(NSMutableDictionary *)dic json:(BOOL)done;
+(ASIHTTPRequest*) upLoadPictureRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType path:(NSMutableArray *)pathArray imageName:(NSString *)name;
+(ASIHTTPRequest*) downLoadPictureRequest:(NSString*)url requestType:(id)requestType;
+(ASIHTTPRequest*) postSearch:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType postData:(NSString *)str;
+(ASIHTTPRequest*) downLoadPhotoRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType;
+(ASIHTTPRequest*) downLoadsmallPictureRequest:(NSString*)url requestType:(NSString *)requestType;
+(void) setToken:(ASIHTTPRequest*) request;
@end
