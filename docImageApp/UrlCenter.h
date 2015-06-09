//
//  UrlCenter.h
//  docImageApp
//
//  Created by 侯建政 on 8/19/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MEETING_URL_ISDEV 1   //设为0 url换为dev版  1为IDC  0为QA
#define IOS_USER_AGENT @"imd-picture-iphone"
#if MEETING_URL_ISDEV
#define DOCIMAGEAPP_PICSHOW_SERVER @"picshow.i-md.com"
#define DOCIMAGEAPP_SERVER @"accounts.i-md.com"
#define DOC_HOME_SERVER @"www.i-md.com"
#else
//#define DOCIMAGEAPP_PICSHOW_SERVER @"picshow.corp.i-md.com"
//#define DOCIMAGEAPP_SERVER @"accounts.corp.i-md.com"
//#define DOC_HOME_SERVER @"www.corp.i-md.com"
#define DOCIMAGEAPP_PICSHOW_SERVER @"picshow.qa.i-md.com"
#define DOCIMAGEAPP_SERVER @"accounts.qa.i-md.com"
#define DOC_HOME_SERVER @"www.qa.i-md.com"
#endif

typedef enum
{
  LOGIN_URL,
  REGISTER_URL,
  CHECKMOBILE_URL,
  CHECKEMAIL_URL,
  FIND_EMAIL,
  FIND_MOBILE,
  Mobile_VerifyCode,
  CheckActivationCode,
  RESETPASSWORD,
  GET_CASE_ID,
  UPLOAD_PICTURE,
  UPLOAD_CONTENTS,
  GET_IMAGE_CASE,
  GET_NOT_IMAGE_CASE,
  DOWNLOAD_IMAGE,
  GET_NEW_CASE_INFO,
  GET_HOT_CASE_INFO,
  GET_COMMENT_CASE_INFO,
  GET_RECOMMEN_CASE_INFO,
  GET_PARENT_DISCUSS,
  GET_CHIRLD_DISCUSS,
  POST_DISCUSS,
  UPDOWN_DISCUSS,
  ADD_FAV,
  GET_FAV_LIST,
  IS_FAV,
  SEARCH_STRING,
  GET_SEARCH_DEPARTMENT,
  GET_SEARCH_PART,
  GET_USER_INFO,
  Email_VerifyCode,
  UpdateEmail,
  GET_ALL_DEPARTMENT,
  SAVE_USERINFO,
  WEIXIN_POSTDATA,
  WEIXIN_BIND,
  WEIXIN_SignUp,
  POST_PERSON_PHOTO,
  GET_PERSON_PHOTO,
  GET_PERSON_COUNT,
  GET_PERSON_SELF_CASE,
  GET_PERSON_SELF_COMMENT,
  FEEDBACKEMAIL,
  GET_SERVER_VERSION,
  GET_SMALL_PICTURE,
  ACTIVITY_MOBILE
}urls;
@interface UrlCenter : NSObject
+(NSString*)urlOfType:(int)urlType;
@end
