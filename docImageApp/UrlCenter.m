//
//  UrlCenter.m
//  docImageApp
//
//  Created by 侯建政 on 8/19/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "UrlCenter.h"

@implementation UrlCenter
+(NSString*)urlOfType:(int)urlType
{
  NSString* urlStr= nil;
  switch (urlType) {
    case LOGIN_URL:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/Login",DOCIMAGEAPP_SERVER];
    }
      break;
    case REGISTER_URL:
    {
     urlStr = [NSString stringWithFormat:@"http://%@/SimpleSignUp",DOCIMAGEAPP_SERVER];
    }
      break;
    case CHECKMOBILE_URL:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/Profile/checkMobileAvailable", DOCIMAGEAPP_SERVER];
    }
      break;
    case CHECKEMAIL_URL:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/Profile/checkEmailAvailable", DOCIMAGEAPP_SERVER];
    }
      break;
    case FIND_EMAIL:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/MobilePassword:findViaEmail",DOCIMAGEAPP_SERVER];
    }
      break;
    case FIND_MOBILE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/Password:findViaMobile",DOCIMAGEAPP_SERVER];
    }
      break;
    case Mobile_VerifyCode:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/SignUp/requestMobileVerifyCode",DOCIMAGEAPP_SERVER];
    }
      break;
    case CheckActivationCode:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/Password:checkActivationCode",DOCIMAGEAPP_SERVER];
    }
      break;
    case RESETPASSWORD:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/Password:resetViaMobile",DOCIMAGEAPP_SERVER];
    }
      break;
    case GET_CASE_ID:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/case/newid",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case UPLOAD_PICTURE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/pic/upload",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case UPLOAD_CONTENTS:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/case/upsert",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_IMAGE_CASE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/case/show/withpics",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_NOT_IMAGE_CASE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/case/show/withoutpics",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case DOWNLOAD_IMAGE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/pic/show",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_NEW_CASE_INFO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/load/latest/latest",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_HOT_CASE_INFO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/load",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_COMMENT_CASE_INFO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/load",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_RECOMMEN_CASE_INFO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/recommend/",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_PARENT_DISCUSS:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/comment/show",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_CHIRLD_DISCUSS:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/comment/subs",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case POST_DISCUSS:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/comment/new",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case UPDOWN_DISCUSS:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/comment/updown",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case ADD_FAV:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/favorite/fav",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_FAV_LIST:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/favorite/load",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case IS_FAV:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/favorite/isfav",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case SEARCH_STRING:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/search",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_SEARCH_DEPARTMENT:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/filter/department",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_SEARCH_PART:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/filter/part",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_USER_INFO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/userInfo2",DOC_HOME_SERVER];
    }
      break;
    case GET_ALL_DEPARTMENT:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/department",DOC_HOME_SERVER];
    }
      break;
    case Email_VerifyCode:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/Profile:sendVerifyEmail",DOCIMAGEAPP_SERVER];
    }
      break;
    case UpdateEmail:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/Profile:requestUpdateEmail",DOCIMAGEAPP_SERVER];
    }
      break;
    case SAVE_USERINFO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/Profile",DOCIMAGEAPP_SERVER];
    }
      break;
    case WEIXIN_POSTDATA:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/WxLogin",DOCIMAGEAPP_SERVER];
    }
      break;
    case WEIXIN_BIND:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/WxCheck",DOCIMAGEAPP_SERVER];
    }
      break;
    case WEIXIN_SignUp:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/WxSignUp",DOCIMAGEAPP_SERVER];
    }
      break;
    case GET_PERSON_PHOTO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/portrait",DOCIMAGEAPP_SERVER];
    }
      break;
    case POST_PERSON_PHOTO:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/pic/portrait",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_PERSON_COUNT:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/user/all",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_PERSON_SELF_CASE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/cases/self",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_PERSON_SELF_COMMENT:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/comment/self",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case FEEDBACKEMAIL:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/feedback",DOC_HOME_SERVER];
    }
      break;
    case GET_SERVER_VERSION:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/conf/version",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case GET_SMALL_PICTURE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/pic/showsmall",DOCIMAGEAPP_PICSHOW_SERVER];
    }
      break;
    case ACTIVITY_MOBILE:
    {
      urlStr = [NSString stringWithFormat:@"http://%@/client/Profile:mobile",DOCIMAGEAPP_SERVER];
    }
      break;
      default:
      break;
  }
  return urlStr;
}
@end
