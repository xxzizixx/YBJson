//
//  ViewController.m
//  YBJSON
//
//  Created by 杨彪 on 16/8/13.
//  Copyright © 2016年 杨彪. All rights reserved.
//

#import "ViewController.h"
#import "YBJson.h"
#import "Model.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 字典转模型 */
    //    [self test1];
    
    /** 模型中嵌套模型 */
    //    [self test2];
    
    /** 模型中有个数组属性，数组里面又要装着其他模型 */
    //    [self test3];
    
    /** 模型中的属性名和字典中的key不相同 */
    //    [self test4];
    
    /** 将一个字典数组转成模型数组 */
    //    [self test5];
    
    /** 将一个模型转成字典 */
    //    [self test6];
    
    /** 将一个模型数组转成字典数组 */
    [self test7];
}


#pragma mark- 将一个模型数组转成字典数组
- (void)test7 {
    
    User *user1 = [[User alloc] init];
    user1.name = @"Jack";
    user1.icon = @"lufy.png";
    
    User *user2 = [[User alloc] init];
    user2.name = @"Rose";
    user2.icon = @"nami.png";
    
    NSArray *userArray = @[user1, user2];
    
    NSArray *dictArray = [User createDictionaryArrayFromModelArray:userArray];
    NSLog(@"%@", dictArray);
}

#pragma mark- 将一个模型转成字典
- (void)test6 {
    
    User *user = [[User alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    Status *status = [[Status alloc] init];
    status.user = user;
    status.text = @"Nice mood!";
    
    NSDictionary *statusDict = [status convertModelToDictionary];
    NSLog(@"%@",statusDict);
}


#pragma mark- 将一个字典数组转成模型数组
- (void)test5 {
    
    NSArray *dictArray = @[
                           @{
                               @"name" : @"Jack",
                               @"icon" : @"lufy.png"
                               },
                           @{
                               @"name" : @"Rose",
                               @"icon" : @"name.png"
                               }
                           ];
    
    NSArray *userArray = [User createModelArrayFromDictionaryArray:dictArray];
    
    for (User *user in userArray) {
        
        NSLog(@"name=%@, icon=%@", user.name, user.icon);
    }
    
}

#pragma mark- 模型中的属性名和字典中的key不相同
- (void)test4 {
    
    NSDictionary *dict = @{
                           @"id" : @"20",
                           @"desciption" : @"kids",
                           };
    
    Student *student = [Student createModelFromDictionary:dict];
    NSLog(@"\nID=%@, \ndesc=%@,", student.ID, student.desc);
    
}


#pragma mark- 模型中有个数组属性，数组里面又要装着其他模型
- (void)test3 {
    
    NSDictionary *dict = @{
                           @"statuses" : @[
                                   @{
                                       @"text" : @"Fuck the word if you are rich,",
                                       @"user" : @{
                                               @"name" : @"Rose",
                                               @"icon" : @"nami.png"
                                               }
                                       },
                                   @{
                                       @"text" : @"otherwise fuck yourself!",
                                       @"user" : @{
                                               @"name" : @"Jack",
                                               @"icon" : @"lufy.png"
                                               }
                                       }
                                   ],
                           @"ads" : @[
                                   @{
                                       @"image" : @"ad01.png",
                                       @"url" : @"http://www.ad01.com"
                                       },
                                   @{
                                       @"image" : @"ad02.png",
                                       @"url" : @"http://www.ad02.com"
                                       }
                                   ],
                           @"totalNumber" : @"2014"
                           };
    
    StatusResult *result = [StatusResult createModelFromDictionary:dict];
    
    for (Status *status in result.statuses) {
        
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        NSLog(@"%@====%@===%@====", text, name, icon);
    }
    
    for (Ad *ad in result.ads) {
        
        NSString *image = ad.image;
        NSString *url   = ad.url;
        NSLog(@"%@====%@===", image, url);
    }
    
    
}

#pragma mark- 模型中嵌套模型
- (void)test2 {
    
    NSDictionary *dict = @{
                           @"text" : @"Fuck the word if you are rich,",
                           @"user" : @{
                                   @"name" : @"Jack",
                                   @"icon" : @"lufy.png"
                                   },
                           @"retweetedStatus" : @{
                                   @"text" : @"otherwise fuck yourself!",
                                   @"user" : @{
                                           @"name" : @"Rose",
                                           @"icon" : @"name.png"
                                           }
                                   }
                           };
    Status *status = [Status createModelFromDictionary:dict];
    NSLog(@"text=%@, name=%@, icon=%@; retweeted:text=%@, name=%@, icon=%@;", status.text, status.user.name, status.user.icon, status.retweetedStatus.text, status.retweetedStatus.user.name, status.retweetedStatus.user.icon);
}


#pragma mark- 字典转模型
- (void)test1 {
    
    
    NSDictionary *dict = @{
                           @"name" : @"Jack",
                           @"icon" : @"lufy.png",
                           @"age" : @20,
                           @"height" : @"1.55",
                           @"money" : @100.9,
                           @"sex" : @(Male),
                           @"gay" : @"true"
                           };
    
    User *model = [User createModelFromDictionary:dict];
    
    NSLog(@"%@====%@===%u",model.name, model.height,model.sex);
    
    
}

@end
