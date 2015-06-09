//
//  imdRequest.m
//  docImageApp
//
//  Created by 侯建政 on 8/19/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "imdRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "userLocalData.h"
#import "UrlCenter.h"
#import "JSON.h"
#import "ASINetworkQueue.h"
#import "Strings.h"
#import "Reachability.h"

@implementation imdRequest
+ (NSString *)getDeceive
{
  NSString* phoneModel = [[UIDevice currentDevice] model];
  NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
   NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
   NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
  return [NSString stringWithFormat:@"phoneModel:%@_phoneVersion:%@_appCurVersion:%@",phoneModel,phoneVersion,appCurVersion];
}
+(ASIHTTPRequest*) postSearch:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType postData:(NSString *)str
{
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType.length > 0) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  request.delegate = dlgt;
  [request setRequestMethod:@"POST"];
  [self setToken:request];
  [request appendPostData:[str dataUsingEncoding:NSUTF8StringEncoding]];
  [request setTimeOutSeconds:20.0f];
  [request startAsynchronous];
  return request;
}

+(ASIHTTPRequest*) getRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType
{
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType.length > 0) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  request.delegate = dlgt;
  [self setToken:request];
  [request setTimeOutSeconds:20.0f];
  [request startAsynchronous];
  return request;
}
+(ASIHTTPRequest*) postRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType postData:(NSMutableDictionary *)dic json:(BOOL)done
{
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType.length > 0) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  request.delegate = dlgt;
  [request setRequestMethod:@"POST"];
  
  
  if (done) {
    NSLog(@".......%@",[dic JSONRepresentation]);
    if ([requestType isEqualToString:@"Register"]) {
      
    }else
      [self setToken:request];
    [request appendPostData:[[dic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
  }else
  {
    NSArray *arr = [dic allKeys];
    for (int i = 0; i < arr.count; i++) {
      [request setPostValue:[dic objectForKey:[arr objectAtIndex:i]] forKey:[arr objectAtIndex:i]];
    }
    if ([requestType isEqualToString:@"LoginIn"]) {
      
    }else
      [self setToken:request];
  }
  [request setTimeOutSeconds:20.0f];
  [request startAsynchronous];
  return request;
}
+(ASIHTTPRequest*) upLoadPictureRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType path:(NSMutableArray *)pathArray imageName:(NSString *)name
{
  int uploadImageSize = 0;
  if ([[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) {
    uploadImageSize = 256;
  }else
    uploadImageSize = 128;
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  NSString *boundary = @"------WebKitFormBoundaryLP6KZBzuQ9a2BIGU";
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
  [request addRequestHeader:@"Content-Type" value:contentType];
  [request addRequestHeader:@"Accept" value:@"text/html"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType.length > 0) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  request.delegate = dlgt;
  [request setRequestMethod:@"POST"];
  NSMutableData* imageData = [NSMutableData data];
  for (int i = 0; i < [pathArray count]; i++) {
    NSData* data;
    NSString * picFilePath = [pathArray objectAtIndex:i];
    if(picFilePath){
      
      UIImage *image=[UIImage imageWithContentsOfFile:picFilePath];
      
        //UIImage *image = [Strings imageWithLogoImage:oldimage logo:[UIImage imageNamed:@"image-imd.png"]];
        //判断图片是不是png格式的文件
      if (UIImagePNGRepresentation(image)) {
          //返回为png图像。
        data = UIImagePNGRepresentation(image);
      }else {
          //返回为JPEG图像。
        data = UIImageJPEGRepresentation(image, 1.0);
      }
      if (data.length/1024 > uploadImageSize) {
      for (int i = 1; i < 10; i ++) {
        if (data.length/1024 > uploadImageSize) {
          data = UIImageJPEGRepresentation(image, 1- i*0.1);
        }else
          break;
      }
      }
    }
    [imageData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [imageData appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",name,[NSString stringWithFormat:@"xx%d",i]]] dataUsingEncoding:NSUTF8StringEncoding]];
    [imageData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [imageData appendData:[NSData dataWithData:data]];
    
      //[request setHTTPBody:body];
      //[request addData:data withFileName:@"xxx" andContentType:@"image/jpeg" forKey:@"photoContent"];
      //NSMutableData* imageData = [[NSMutableData alloc] initWithContentsOfFile:[pathArray objectAtIndex:i]];
      //[request setFile:[pathArray objectAtIndex:i] forKey:@"image"];
    
  }
  [imageData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [request setPostBody:imageData];
  [request setTimeOutSeconds:120.0f];
  [request setPostFormat:ASIMultipartFormDataPostFormat];
  [self setToken:request];
  [request startAsynchronous];
  return request;
}
+(ASIHTTPRequest*) downLoadPictureRequest:(NSString*)url requestType:(id)requestType
{
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSString *filePath = [path stringByAppendingPathComponent:[newUrl lastPathComponent]];
  [request setDownloadDestinationPath:filePath];
  
  [request setShouldContinueWhenAppEntersBackground:YES];
  [request setTimeOutSeconds:60.0f];
  [request setAllowResumeForFileDownloads:YES];
//  [request setDownloadCache:appDelegate.imageCache];
//  [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
  [self setToken:request];
  return request;
}
+(ASIHTTPRequest*) downLoadsmallPictureRequest:(NSString*)url requestType:(NSString *)requestType
{
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType.length > 0) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/smallPicture"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSString *filePath = [path stringByAppendingPathComponent:[newUrl lastPathComponent]];
  [request setDownloadDestinationPath:filePath];
  
  [request setShouldContinueWhenAppEntersBackground:YES];
  [request setTimeOutSeconds:60.0f];
  [request setAllowResumeForFileDownloads:YES];
    //  [request setDownloadCache:appDelegate.imageCache];
    //  [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
  [self setToken:request];
  return request;
}

+(ASIHTTPRequest*) downLoadPhotoRequest:(NSString*)url delegate:(id)dlgt requestType:(NSString *)requestType
{
  NSURL *newUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:newUrl];
  [request addRequestHeader:@"Source" value:@"imdpicshow"];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  [request addRequestHeader:@"User-Agent" value:[imdRequest getDeceive]];
  if (requestType.length > 0) {
    NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [requestInfo setObject:requestType forKey:@"requestType"];
    request.userInfo = requestInfo;
  }
  NSString *paths =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
  NSString* path = [NSString stringWithFormat:@"%@/PhotoImage",paths];
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSString *filePath = [path stringByAppendingPathComponent:[newUrl lastPathComponent]];
  [request setDownloadDestinationPath:filePath];
  
  [request setShouldContinueWhenAppEntersBackground:YES];
  [request setTimeOutSeconds:60.0f];
  [request setAllowResumeForFileDownloads:YES];
  [request setDelegate:dlgt];
    //  [request setDownloadCache:appDelegate.imageCache];
    //  [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
  [self setToken:request];
  [request startAsynchronous];
  return request;
}

//+(ASIHTTPRequest*) postRequest:(NSURL*)url delegate:(id)dlgt requestType:(NSString *)requestType postData:(NSMutableDictionary *)dic
//{
//  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//  [request addRequestHeader:@"Source" value:@"imdpicshow"];
//  [request addRequestHeader:@"Content-Type" value:@"application/json"];
//  [request addRequestHeader:@"Accept" value:@"application/json"];
//  
//  NSMutableDictionary *requestInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
//  [requestInfo setObject:requestType forKey:@"requestType"];
//  request.userInfo = requestInfo;
//  request.delegate = dlgt;
//  [request setRequestMethod:@"POST"];
//    //[request appendPostData:[[dic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
//  NSArray *arr = [dic allKeys];
//  for (int i = 0; i < arr.count; i++) {
//    [request setPostValue:[dic objectForKey:[arr objectAtIndex:i]] forKey:[arr objectAtIndex:i]];
//  }
//  if ([requestType isEqualToString:@"Register"]) {
//    
//  }else
//  {
//    [self setToken:request];
//  }
//  [request startAsynchronous];
//  return request;
//}
+(void) setToken:(ASIHTTPRequest*) request
{
   NSString *token = [userLocalData getImdToken];
  [ASIHTTPRequest setSessionCookies:nil];
  
  NSLog(@"Token %@", token);
  if (token != nil) {
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:token forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",DOCIMAGEAPP_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    [request setUserAgentString:IOS_USER_AGENT];
  }
}
@end