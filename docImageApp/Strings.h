//
//  Strings.h
//  docImageApp
//
//  Created by 侯建政 on 8/19/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEPARTMENT_CN  @"cnDepartment"
#define DEPARTMENT_EN  @"enDepartment"
#define DEPARTMENT_KEY  @"key"
#define REGISTER_EMAIL_FORMAT @"请输入正确的手机号或者Email"
#define USERLOGININFO   @"userLoginInfo"
#define LOGIN_NEXTSTEP @"下一步"
#define LOGIN_BACKSTEP @"上一步"
#define ACTIVE_MOBILE_CODE_TIMER 360
  //Login alert
#define LOGIN_ALERT_TITLE  @"登录失败"
#define LOGIN_ALERT_MESSAGE @"请尝试重新登录"
#define ALERT_CONFIRM @"确认"
//error alert
#define REQUEST_TIMEOUT_MESSAGE @"请求超时，请重试"
#define RUIYI_TITLE @"睿医提示"
#define REQUEST_ERROR @"网络出错-­‐请检查网络设置"
//register key
#define PHONE_NUMBER @"mobile"
#define PASSWORD @"password"
#define CODE_Available @"code"
#define REGISTER_PWD_LENGTH @"请确保密码长度在6~40个字符之间"
#define REGISTER_MOBILE_MESSAGE @"您输入的手机号码错误，请输入正确的手机号码。"
#define REGISTER_CODE_MESSAGE @"请输入正确的验证码"
#define REGISTER_SUCCESS @"success"
#define REGISTER_TOKEN @"token"
#define REGISTER_USER_ID @"uid"
#define REQUEST_TYPE @"requestType"

#define USERTYPE_DOCTOR @"Doctor"
#define USERTYPE_STUDENT @"Student"
#define SELECT_XUESHI @"学士"
#define SELECT_SHUOSHI @"硕士"
#define SELECT_BOSHI @"博士"
#define EDIT_DONE_CN @"完成"
#define TEXT_CANCEL @"取消"

#define LOGOUT_WARN @"退出后不会删除任何历史数据，下次登录该帐号后数据依然存在"
#define LOGOUT_CONFIRM @"退出登录"
#define FEEDBACK_PLACEHOLDER @"您的反馈意见将有助于我们优化睿医文献搜索服务"
#define FEEDBACK_SUBMIT_MESSAGE @"非常感谢您对睿医文献的理解和支持！"
#define SETTINGS_FEEDBACK @"反馈建议成功提交"

  //Settings
#define SETTINGS_ABOUTUS @"关于睿医"
#define SETTINGS_ABOUTUS_TEXT @"上海睿医信息科技有限公司创立于2011年，致力于综合运用互联网以及移动互联网领域的创新科技搭建专业医生的服务平台， 为医生提供专业的、即时的以及个性化的医学信息服务。i-MD医生专业服务平台服务的主要对象是中国执业医师， 并兼顾未取得执业证书的住院医师及医学院校在读学生。目前，平台正在进行开发的产品和服务包括：\n\n <blue>    1. 文献服务：</blue>\n    平台通过整合国内外主要医学文献数据库，免费向各位医师开放在线阅读和下载服务，也为部分医师提供代检代查服务。\n\n <blue>    2. 一对一/多对多在线视频互动学术会议服务：</blue>\n    包括医药学术会议、产品说明会、学术研讨会/讨论会等，实现异地实时一对多、多对多多媒体互动会议。\n\n<blue>    3. 专业资讯：</blue>\n    包括医药行业动态及卫生政策信息、国内外医学科研进展和临床动态、药品信息，诊疗指南、临床病例等。\n\n未来公司将不断完善平台，开发更多先进的电子医学信息系统，包括医学培训系统，在线医疗援助中心，以及医师法律援助中心等，对中国的医疗体系的电子信息化做出贡献。"


#define SETTINGS_AGREEMENT @"免责声明"
#define SETTINGS_AGREEMENT_TEXT @"    欢迎使用上海睿医信息科技有限公司睿医图志APP（以下简称睿医图志）！在使用之前请切记以下内容：\n\n    <blue>1.</blue> 凡以任何方式使用睿医图志内容者，均视为自愿接受本声明的约束。\n\n     <blue>2.</blue>睿医图志提供的医学影像仅用于专业医护人员得学习和研究，不得用于任何营利目的。如果超出以上范围，用户要为发生的版权侵权行为负责。一旦发现个人或团体有超出著作权法规定范围的行为，或者张贴与医疗无关的政治、邪教、恐怖和色情等画面，上海睿医信息科技有限公司保留取消用户或团体对睿医图志的使用权利，且不排除通过法律手段解决的可能性。\n\n     <blue>3.</blue>	睿医图志的图文治疗均来源于国内广大专业医护人员的自发上传。信息使用的主要目的是帮助广大用户以最便捷的查询相关的医学图像和评论， 而不是替代临床诊疗。所以必须声明，鉴于医药科学日新月异及临床实践的复杂性，本知识库系统并不能担保所提供的信息都是最新或唯一正确的，也不能担保这些信息能够覆盖或适用于所有治疗领域，用户在使用这些信息时必须运用自己的判断。\n\n     <blue>4.</blue>	睿医图志所提供的服务或建议仅供临床参考，不可直接作为临床诊断或制定治疗措施依据，最终的治疗决策需结合临床实际。对于任何因使用本产品信息所导致的医疗差错或医疗纠纷，睿医科技不承担任何责任。\n\n     <blue>5.</blue>	睿医图志中的很多内容，如病例图片、诊疗评价等这些内容不代表睿医图志的观点或立场，睿医图志会尽力维护内容的健康、科学和公正性，但并不对这些承担最终责任。\n\n     <blue>6．</blue>如果希望在睿医图志平台的互动区域署名发帖或跟帖，这些都需要用户注册独立的帐户，帐户中会包含一些必要的个人信息，睿医图志平台所有者及工作人员将严格执行有关用户信息的保护制度，保护用户信息仅限上述范围内使用。"
#define SETTINGS_RULE @"使用规则"
#define SETTINGS_RULE_TEXT @"    睿医图志推出的目的是为专业医护人员提供一个分享和讨论医学图像的教育平台。本使用规则旨在帮助您理解作为睿医图志成员意味着什么。请注意您在睿医图志上的所有活动都必须遵守睿医图志的使用规则和服务条款，这包括您分享的图片和对其他图片的评价。\n\n    <blue>1.</blue> 分享您最得意的图片得益于广大用户的全心支持，睿医图志已经发展成为一个引人注目的临床医学图像数字化图书馆。您在分享医学图像时，即帮助睿医图志扩展了医学图像数据库，又为成千上万的专业医护人员提供了学习的机会。睿医图志鼓励您在分享图片时，把交流学习和共同提高的最终目的铭记在心。同时，也请注意只分享属于您的图片并保护患者的隐私。\n\n    <blue>2.</blue>决不要把能辨认患者身份的信息包含在图片中在上传和张贴评价时，请时刻注意将能暴露患者身份的信息抹去。任何带有这些信息的图像和评价都会被睿医科技的医学团队和平台管理人员删除。\n\n     <blue>3.</blue>请添加有教育意义的标注和评价要把睿医图志打造成受推崇的学习交流平台，我们建议用户在上传图像和讨论时留下与当前病例相关的标注和评论；这样才有助于创建一个有关某个特定病例的对话环境。请避免张贴任何缺乏建设性的内容。\n\n     <blue>4.</blue>尊重患者睿医图志上的图片都来源于真实的患者，而患者自始自终权都有权利享受应有的尊严和得到应有的尊重。临床实践中适用的道德准则同样适用于上传病例图片。您不会在患者面前说的话也请不要出现在睿医图志上。\n\n     <blue>5.</blue>使用专业的衡量标准作为睿医图志的用户，您可以帮助我们共同建设好这个社区。例如您可以举报任何违反本规范的图片和评论。这包括（但不仅限于）：\n1.	任何违反睿医图志患者隐私保护政策的图片和评论。\n2.	用患者的病痛来开玩笑。\n3.	在评论中对其他用户进行羞辱、恶意中伤或挑起争议。\n4.	任何使用不恰当言辞的评论。\n\n     <blue>6.</blue>保持真实如果您不是专业医护人员，敬请回避。睿医图志是为专业医护人员打造的分享他们在日常诊疗工作中遇到的病例，而不是供患者张贴他们病情的的工具。如有您对您的健康状况表示担心，请直接咨询向医生咨询。请勿随意转载直接对睿医图志上的影像截屏并转载至其他地方有违睿医图志的服务条款和社区精神。\n我们撰写本规范的目的是希望每一位睿医图志的用户都能积极参与到有教育意义的分享中来。如果您对此有不同的看法，那睿医图志可能并不适合您。我们非常乐意听取您提出的任何问题和建议并欢迎您随时和我们保持联系。"
#define TUIJIAN @"亲，我发现了一个低调奢华有内涵的晒图软件，当中也许有小清新，更多是重口味，但肯定是专注于医学专业。速速来跟我一起围观、吐槽去吧。"
#define APP_TUIJIAN_URL @"http://p.i-md.com/invitation?linkType=other"

#define APP_RUIYIWENXIAN @"https://itunes.apple.com/cn/app/rui-yi-wen-xian/id492028918?l=zh&ls=1&mt=8"
#define APP_RUIYIZIXUN @"https://itunes.apple.com/cn/app/rui-yi-zi-xun/id519002672?l=zh&ls=1&mt=8"
#define WEB_TIANTAN @"http://strokeedu.org"
#define WEB_HUOPU @"http://deeplearningdiabetes.i-md.com"

#define RUIYITUZHI_APPURL @"itms-apps://itunes.apple.com/app/id945620109"
#define RUIYITUZHI_RATE @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=945620109"
@interface Strings : NSObject
+(BOOL) validEmail:(NSString*) emailString;
+(BOOL)phoneNumberJudge:(NSString*)number;
+(BOOL)judgeStringAsc:(NSString *)str;

+(NSMutableArray*) Departments;
+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;
+ (NSString *)getAnatomyString:(NSString *)str;
+ (NSString *)getDepartmentString:(NSString *)str;
+ (NSString *)getPositionEN:(NSString *)str;
+(NSString *)getDegreeEN:(NSString *)str;
+ (NSString *)getIdentityEncode:(NSString *)str;
+ (NSString *)getIdentity:(NSString *)str;
+ (NSString *)getPosition:(NSString *)str;
+(NSString *)getDegree:(NSString *)str;
+ (NSString *)getDepartmentStringCN:(NSString *)str;
+ (NSString *)getAnatomyStringCN:(NSString *)str;
+ (NSString *)replaceUnicode:(NSString *)unicodeStr;
+(BOOL) clearCache;
+ (float) folderSizeAtPath:(NSString*) folderPath;
+(UIImage *)addText:(UIImage *)img text:(NSString *)text1;
+(UIImage *)imageWithLogoImage:(UIImage *)img logo:(UIImage *)logo;
+(UIImage *)imageWithSourceImage:(UIImage *)img WaterMask:(UIImage*)mask;
+ (BOOL)getFirstOpenInCurrentVersion;
+ (void)setFirstOpenInCurrentVersion:(BOOL)flag;
+(BOOL) validUserName:(NSString*) userString;
+(BOOL) validRealName:(NSString*) userString;
@end
