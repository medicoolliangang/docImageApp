//
//  Strings.m
//  docImageApp
//
//  Created by 侯建政 on 8/19/14.
//  Copyright (c) 2014 jianzheng. All rights reserved.
//

#import "Strings.h"

@implementation Strings
+(BOOL) validRealName:(NSString*) userString
{
  NSString *regExPattern = @"^[\u4e00-\u9fa5]{2,}$";
  NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
  NSUInteger regExMatches = [regEx numberOfMatchesInString:userString options:0 range:NSMakeRange(0, [userString length])];
  if (regExMatches == 0) {
    return NO;
  } else
    return YES;
}

+(BOOL) validUserName:(NSString*) userString
{
  NSString *regExPattern = @"^[a-zA-Z0-9\u4e00-\u9fa5][a-zA-Z0-9_\u4e00-\u9fa5]+$";
  NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
  NSUInteger regExMatches = [regEx numberOfMatchesInString:userString options:0 range:NSMakeRange(0, [userString length])];
  if (regExMatches == 0) {
    return NO;
  } else
    return YES;
}
+(BOOL) validEmail:(NSString*) emailString
{
  NSString *regExPattern = @"\\w+([-+.]\\w*)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
  NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
  NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
  if (regExMatches == 0) {
    return NO;
  } else
    return YES;
}

+(BOOL)phoneNumberJudge:(NSString*)number
{
  NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                            initWithPattern:@"^(((13[0-9]{1})|15[0-9]{1}|18[0-9]{1})\\d{8})$"
                                            options:NSRegularExpressionCaseInsensitive
                                            error:nil];
  NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:number
                                                                options:NSMatchingReportProgress
                                                                  range:NSMakeRange(0, number.length)];
  if (numberofMatch == 0) {
    return NO;
  } else
    return YES;
}


+(NSMutableArray*) Departments
{
  NSMutableArray* ds = [[NSMutableArray alloc] init];
  
  
  NSArray* keys = [NSArray arrayWithObjects:DEPARTMENT_CN, DEPARTMENT_EN,DEPARTMENT_KEY,nil];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"麻醉科", @"anesthesiology", @"Anesthesiology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"烧伤整形外科", @"burn and Plastic Surge", @"BurnAndPlasticSurge", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"心血管外科", @"cardiac surgery", @"CardiacSurgery", nil] forKeys:keys]];
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"心血管内科", @"cardiology", @"Cardiology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"重症医学科", @"critical care medicine", @"CriticalCareMedicine", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"中西医结合科", @"department of TCM & WM", @"DepartmentOfTcmWm", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"皮肤科", @"dermatology", @"Dermatology", nil] forKeys:keys]];
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"急诊医学科", @"emergency medicine", @"EmergencyMedicine", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"内分泌科", @"endocrinology", @"Endocrinology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"消化内科", @"gastroenterology", @"Gastroenterology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"全科医疗科", @"general practice", @"GeneralPractice", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"普通外科", @"general surgery", @"GeneralSurgery", nil] forKeys:keys]];
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"老年科", @"geriatrics", @"Geriatrics", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"妇科", @"gynecology", @"Gynecology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"血液内科", @"hematology", @"Hematology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"传染科", @"infectious diseases", @"InfectiousDiseases", nil] forKeys:keys]];
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"医学检验科", @"laboratory", @"Laboratory", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"管理科室", @"medical affair", @"MedicalAffair", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"医学影像科", @"medical imaging department", @"MedicalImagingDepartment", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"民族医学科", @"national medicine", @"NationalMedicine", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"肾脏内科", @"nephrology", @"Nephrology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"神经内科", @"neurology", @"Neurology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"神经外科", @"neurosurgery", @"Neurosurgery", nil] forKeys:keys]];
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"临床营养科", @"nutrition department", @"NutritionDepartment", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"产科", @"obstetrics", @"Obstetrics", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"职业病科", @"Occupational Disease", @"OccupationalDisease", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"肿瘤科", @"oncology", @"Oncology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"眼科", @"ophthalmology", @"Ophthalmology", nil] forKeys:keys]];
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"骨科", @"orthopedics", @"Orthopedics", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"泌尿外科", @"urology", @"Urology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"耳鼻咽喉科", @"otolaryngology", @"Otolaryngology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"病理科", @"pathology", @"Pathology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"儿科", @"pediatrics", @"Pediatrics", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"药剂科", @"pharmacy", @"Pharmacy", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"医疗美容科", @"plastic surgery", @"PlasticSurgery", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"预防保健科", @"prevention and health care", @"PreventionAndHealthCare", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"精神科", @"psychiatry", @"Psychiatry", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"康复医学科", @"rehabilitation", @"Rehabilitation", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"呼吸内科", @"respiratory", @"Respiratory", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"风湿免疫科", @"rheumatology and clinical immunology", @"RheumatologyAndClinicalImmunology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"运动医学科", @"sports medicine", @"SportsMedicine", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"口腔科", @"stomatology", @"Stomatology", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"胸外科", @"Thoracic surgery", @"ThoracicSurgery", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"中医科", @"traditional Chinese medicine", @"TraditionalChineseMedicine", nil] forKeys:keys]];
  
  [ds addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"其他科室", @"other department", @"OtherDepartment", nil] forKeys:keys]];
  return ds;
}
+ (NSString *)getDepartmentString:(NSString *)str
{
  NSString *department;
  department = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Anesthesiology",@"麻醉科",@"BurnAndPlasticSurge",@"烧伤整形外科",@"CardiacSurgery",@"心血管外科",@"Cardiology",@"心血管内科",@"CriticalCareMedicine",@"重症医学科",@"DepartmentOfTcmWm",@"中西医结合科",@"Dermatology",@"皮肤科",@"EmergencyMedicine",@"急诊医学科",@"Endocrinology",@"内分泌科",@"Gastroenterology",@"消化内科",@"GeneralPractice",@"全科医疗科",
                       @"GeneralSurgery",@"普通外科",
                      @"Geriatrics", @"老年科",
                       @"Gynecology",@"妇科",
                       @"Hematology",@"血液内科",
                       @"InfectiousDiseases",@"传染科",
                       @"Laboratory",@"医学检验科",
                       @"MedicalAffair",@"管理科室",
                       @"MedicalImagingDepartment",@"医学影像科",
                       @"NationalMedicine",@"民族医学科",
                       @"Nephrology",@"肾脏内科",
                       @"Neurology",@"神经内科",
                       @"Neurosurgery",@"神经外科",
                       @"NutritionDepartment",@"临床营养科",
                       @"Obstetrics",@"产科",
                       @"Occupational Disease",@"职业病科",
                       @"Oncology",@"肿瘤科",
                       @"Ophthalmology",@"眼科",
                       @"Orthopedics",@"骨科",
                       @"Urology",@"泌尿外科",
                       @"Otolaryngology",@"耳鼻咽喉科",
                       @"Pathology",@"病理科",
                       @"Pediatrics",@"儿科",
                       @"Pharmacy",@"药剂科",
                       @"PlasticSurgery",@"医疗美容科",
                       @"PreventionAndHealthCare",@"预防保健科",
                       @"Psychiatry",@"精神科",
                       @"Rehabilitation",@"康复医学科",
                       @"Respiratory",@"呼吸内科",
                       @"RheumatologyAndClinicalImmunology",@"风湿免疫科",
                       @"SportsMedicine",@"运动医学科",
                       @"Stomatology",@"口腔科",
                       @"ThoracicSurgery",@"胸外科",
                       @"TraditionalChineseMedicine",@"中医科",
                       @"OtherDepartment",@"其他科室",nil];
  if (str.length >0) {
    department = [[dic objectForKey:str] copy];
    if (department.length <= 0) {
      department = @"";
    }
  }
  
  return department;
}
+ (NSString *)getDepartmentStringCN:(NSString *)str
{
  NSString *department;
  department = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"麻醉科",@"Anesthesiology",@"烧伤整形外科",@"BurnAndPlasticSurge",@"心血管外科",@"CardiacSurgery",@"心血管内科",@"Cardiology",@"重症医学科",@"CriticalCareMedicine",@"中西医结合科",@"DepartmentOfTcmWm",@"皮肤科",@"Dermatology",@"急诊医学科",@"EmergencyMedicine",@"内分泌科",@"Endocrinology",@"消化内科",@"Gastroenterology",@"全科医疗科",@"GeneralPractice",@"普通外科",@"GeneralSurgery",@"老年科",@"Geriatrics",@"妇科",@"Gynecology",@"血液内科",@"Hematology",@"传染科",@"InfectiousDiseases",@"医学检验科",@"Laboratory",@"管理科室",@"MedicalAffair",@"医学影像科",@"MedicalImagingDepartment",@"民族医学科",@"NationalMedicine",@"肾脏内科",@"Nephrology",@"神经内科",@"Neurology",@"神经外科",@"Neurosurgery",@"临床营养科",@"NutritionDepartment",@"产科",@"Obstetrics",@"职业病科",@"Occupational Disease",@"肿瘤科",@"Oncology",@"眼科",@"Ophthalmology",@"骨科",@"Orthopedics",@"泌尿外科",@"Urology",@"耳鼻咽喉科",@"Otolaryngology",@"病理科",@"Pathology",@"儿科",@"Pediatrics",@"药剂科",@"Pharmacy",@"医疗美容科",@"PlasticSurgery",@"预防保健科",@"PreventionAndHealthCare",@"精神科",@"Psychiatry",@"康复医学科",@"Rehabilitation",@"呼吸内科",@"Respiratory",@"风湿免疫科",@"RheumatologyAndClinicalImmunology",@"运动医学科",@"SportsMedicine",@"口腔科",@"Stomatology",@"胸外科",@"ThoracicSurgery",@"中医科",@"TraditionalChineseMedicine",@"其他科室",@"OtherDepartment",nil];
  if (str.length >0) {
    department = [[dic objectForKey:str] copy];
    if (department.length <= 0) {
      department = @"";
    }
  }
  
  return department;
}

+ (NSString *)getAnatomyString:(NSString *)str
{
  NSString *anatomy;
  anatomy = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Brain",@"脑",
                       @"Ear",@"耳",
                       @"Eye",@"眼",
                       @"Face",@"面部",
                       @"Head",@"头部",
                       @"Mouth",@"口",
                       @"Nose", @"鼻",
                       @"Skull",@"颅骨",
                       @"Airway",@"呼吸道",
                       @"Esophagus",@"食管",
                       @"Neck",@"颈部",
                       @"Vascular",@"血管",
                       @"Circulation",@"循环系统",
                       @"Heart",@"心脏",
                       @"Lungs",@"肺部",
                       @"Mediastinum",@"纵隔",
                       @"Stomach",@"胃",
                       @"Thorax",@"胸腔",
                       @"Ankle and Foot",@"踝部与足部",
                       @"Hip and Thigh",@"臀部与股部",
                       @"Lower Limb",@"下肢",
                       @"Shoulder and Arm",@"肩部与手臂",
                       @"Upper Limb",@"上肢",
                       @"Wrist and Hand",@"腕部与手部",
                       @"Back",@"背部",
                       @"MSK",@"肌肉骨骼系统",
                       @"Spine",@"脊柱",
                       @"Abdomen",@"腹部",
                       @"Aorta",@"主动脉",
                       @"Kidneys,Ureters,Bladder,and Adrenals",@"肾脏、输尿管、膀胱及肾上腺",
                       @"Large bowel",@"大肠",
                       @"Liver,Pancreas,and Biliary Tree",@"肝、胰及胆道系统",
                       @"Pelvis",@"盆腔",
                       @"Rectum and Anus",@"直肠与肛门",
                       @"Reproductive Organs",@"生殖器官",
                       @"Small bowel",@"小肠",
                       @"Spleen",@"脾",
                       @"Other",@"其他",nil];
  if (str.length >0) {
    anatomy = [[dic objectForKey:str] copy];
    if (anatomy.length <= 0) {
      anatomy = @"";
    }
  }
  return anatomy;
}
+ (NSString *)getAnatomyStringCN:(NSString *)str
{
  NSString *anatomy;
  anatomy = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"脑",@"Brain",
                       @"耳",@"Ear",
                       @"眼",@"Eye",
                       @"面部",@"Face",
                       @"头部",@"Head",
                       @"口",@"Mouth",
                       @"鼻",@"Nose",
                       @"颅骨",@"Skull",
                       @"呼吸道",@"Airway",
                       @"食管",@"Esophagus",
                       @"颈部",@"Neck",
                       @"血管",@"Vascular",
                       @"循环系统",@"Circulation",
                       @"心脏",@"Heart",
                       @"肺部",@"Lungs",
                       @"纵隔",@"Mediastinum",
                       @"胃",@"Stomach",
                       @"胸腔",@"Thorax",
                       @"踝部与足部",@"Ankle and Foot",
                       @"臀部与股部",@"Hip and Thigh",
                       @"下肢",@"Lower Limb",
                       @"肩部与手臂",@"Shoulder and Arm",
                       @"上肢",@"Upper Limb",
                       @"腕部与手部",@"Wrist and Hand",
                       @"背部",@"Back",
                       @"肌肉骨骼系统",@"MSK",
                       @"脊柱",@"Spine",
                       @"腹部",@"Abdomen",
                       @"主动脉",@"Aorta",
                       @"肾脏、输尿管、膀胱及肾上腺",@"Kidneys,Ureters,Bladder,and Adrenals",
                       @"大肠",@"Large bowel",
                       @"肝、胰及胆道系统",@"Liver,Pancreas,and Biliary Tree",
                       @"盆腔",@"Pelvis",
                       @"直肠与肛门",@"Rectum and Anus",
                       @"生殖器官",@"Reproductive Organs",
                       @"小肠",@"Small bowel",
                       @"脾",@"Spleen",
                       @"其他",@"Other",nil];
  if (str.length >0) {
    anatomy = [[dic objectForKey:str] copy];
    if (anatomy.length <= 0) {
      anatomy = @"";
    }
  }
  return anatomy;
}

+ (BOOL)judgeStringAsc:(NSString *)str
{
  if (str.length == 0) {
    return NO;
  }
  NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                            initWithPattern:@"^[\\u4E00-\\u9FA5\\uF900-\\uFA2D]+$"
                                            options:NSRegularExpressionCaseInsensitive
                                            error:nil];
  NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                options:NSMatchingReportProgress
                                                                  range:NSMakeRange(0, str.length)];
  if (numberofMatch == 0) {
    return NO;
  } else
    return YES;
}

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
  UIGraphicsBeginImageContext(newSize);
  
    // Tell the old image to draw in this new context, with the desired
    // new size
  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  
    // Get the new image from the context
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  
    // End the context
  UIGraphicsEndImageContext();
  
    // Return the new image.
  return newImage;
}
/**
 * 保存图片
 */
+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName{
  NSData* imageData;
  
    //判断图片是不是png格式的文件
  if (UIImagePNGRepresentation(tempImage)) {
      //返回为png图像。
    imageData = UIImagePNGRepresentation(tempImage);
  }else {
      //返回为JPEG图像。
    imageData = UIImageJPEGRepresentation(tempImage, 1.0);
  }
  if (imageData.length/1024 > 224 && imageData.length/1024 < 2048) {
    imageData = nil;
    imageData = UIImageJPEGRepresentation(tempImage, 0.6);
  }else if(imageData.length/1024 >= 2048)
  {
    imageData = nil;
    imageData = UIImageJPEGRepresentation(tempImage, 0.3);
  }
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
  
  NSString* documentsDirectory = [NSString stringWithFormat:@"%@/UploadImageFile",[paths objectAtIndex:0]];
  if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
  
  NSArray *nameAry=[fullPathToFile componentsSeparatedByString:@"/"];
  NSLog(@"===fullPathToFile===%@",fullPathToFile);
  NSLog(@"===FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
  if (![[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile]) {
    [imageData writeToFile:fullPathToFile atomically:NO];
  }
  return fullPathToFile;
}
+ (NSString *)getPositionEN:(NSString *)str
{
  NSString *position;
  position = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"ChiefPhysician",@"主任医师",@"DeputyChiefPhysician",@"副主任医师",@"Physician",@"主治医师",@"Healers",@"医师/医士",nil];
  if (str.length >0) {
    position = [[dic objectForKey:str] copy];
    if (position.length <= 0) {
      position = @"";
    }
  }
  
  return position;
}
+(NSString *)getDegreeEN:(NSString *)str
{
  NSString *degree;
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Bachelor",@"学士",@"Master",@"硕士",@"Doctor",@"博士",nil];
  if (str.length >0) {
    degree = [[dic objectForKey:str] copy];
    if (degree.length <= 0) {
      degree = @"";
    }
  }
  
  return degree;
}
+ (NSString *)getIdentityEncode:(NSString *)str{
  NSString *identity = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Doctor",@"临床医师",@"Student",@"医学院学生",nil];
  if (str.length >0) {
    identity = [[dic objectForKey:str] copy];
    if (identity.length <= 0) {
      identity = @"";
    }
  }
  
  return identity;
}
+ (NSString *)getIdentity:(NSString *)str{
  NSString *identity = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"临床医师",@"Doctor",@"医学院学生", @"Student",nil];
  if (str.length >0) {
    identity = [[dic objectForKey:str] copy];
    if (identity.length <= 0) {
      identity = @"";
    }
  }
  
  return identity;
}
+ (NSString *)getPosition:(NSString *)str
{
  NSString *position;
  position = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"主任医师",@"ChiefPhysician",@"副主任医师",@"DeputyChiefPhysician",@"主治医师",@"Physician",@"医师/医士",@"Healers",nil];
  if (str.length >0) {
    position = [[dic objectForKey:str] copy];
    if (position.length <= 0) {
      position = @"";
    }
  }
  
  return position;
}
+(NSString *)getDegree:(NSString *)str
{
  NSString *degree;
  degree = @"";
  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"学士",@"Bachelor",@"硕士",@"Master",@"博士",@"Doctor",nil];
  if (str.length >0) {
    degree = [[dic objectForKey:str] copy];
    if (degree.length <= 0) {
      degree = @"";
    }
  }
  
  return degree;
}
+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
  
  NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
  NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
  NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                        mutabilityOption:NSPropertyListImmutable
                                                                  format:NULL
                                                        errorDescription:NULL];
  
  return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}
+(BOOL) clearCache
{
  NSError *error = nil;
  NSFileManager* fm = [NSFileManager defaultManager];
  
  NSString* support = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/imageFile/"];
  
  
  BOOL ret = YES;
  for (NSString* file in [fm contentsOfDirectoryAtPath:support error:&error]) {
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", support, file];
    
    BOOL success = [fm removeItemAtPath:filePath error:&error];
    if (!success || error) {
      ret = NO;
      NSLog(@"Error: %@", error.localizedDescription);
    }
    NSLog(@"remove support file : %@", filePath);
  }
  return ret;
}
+ (float) folderSizeAtPath:(NSString*) folderPath{
  NSFileManager* manager = [NSFileManager defaultManager];
  if (![manager fileExistsAtPath:folderPath]) return 0;
  NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
  NSString* fileName;
  long long folderSize = 0;
  while ((fileName = [childFilesEnumerator nextObject]) != nil){
    NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
    folderSize += [self fileSizeAtPath:fileAbsolutePath];
  }
  return folderSize/(1024.0*1024.0);
}
+ (float) fileSizeAtPath:(NSString*) filePath{
  NSFileManager* manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:filePath]){
    return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
  }
  return 0;
}
 //加文字
+(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    /////注：此为后来更改，用于显示中文。zyq,2013-5-8
  CGSize size = CGSizeMake(img.size.width, img.size.height);          //设置上下文（画布）大小
  UIGraphicsBeginImageContext(size);                       //创建一个基于位图的上下文(context)，并将其设置为当前上下文
  CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
  CGContextTranslateCTM(contextRef, 0, img.size.height);   //画布的高度
  CGContextScaleCTM(contextRef, 1.0, -1.0);                //画布翻转
  CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);  //在上下文种画当前图片
  
  [[UIColor whiteColor] set];                                //上下文种的文字属性
  CGContextTranslateCTM(contextRef, 0, img.size.height);
  CGContextScaleCTM(contextRef, 1.0, -1.0);
  UIFont *font = [UIFont boldSystemFontOfSize:16];
  [text1 drawInRect:CGRectMake(0, img.size.height-30, 200, 80) withFont:font];       //此处设置文字显示的位置
  UIImage *targetimg =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
  UIGraphicsEndImageContext();                            //移除栈顶的基于当前位图的图形上下文。
  return targetimg;
}
+(UIImage *)imageWithSourceImage:(UIImage *)img WaterMask:(UIImage*)mask
  //图片水印，可控制显示位置
  //- (UIImage *)imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
  {
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
  }
#else
  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
  {
    UIGraphicsBeginImageContext(img.size);
  }
#endif
  
    //原图
  [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    //水印图
  CGRect rect = CGRectMake(img.size.width-img.size.width/3-5, img.size.height-img.size.width/3/mask.size.width*mask.size.height-5,img.size.width/3, img.size.width/3/mask.size.width*mask.size.height);
  [mask drawInRect:rect];
  
  UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newPic;
}
+ (BOOL)getFirstOpenInCurrentVersion{
  NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
  NSString *key = [NSString stringWithFormat:@"firstLogined_%@",version];
  BOOL isFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
  
  return isFirst;
}
+ (void)setFirstOpenInCurrentVersion:(BOOL)flag{
  NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
  NSString *key = [NSString stringWithFormat:@"firstLogined_%@",version];
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag] forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
