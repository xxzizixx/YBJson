//
//  Model.h
//  YBJson
//
//  Created by 杨彪 on 16/8/8.
//  Copyright © 2016年 杨彪. All rights reserved.
//


typedef enum {
    Male,
    Female
} Sex;


#import <Foundation/Foundation.h>
#import "YBJson.h"

@interface User : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, strong) NSNumber *money;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) Sex sex;
@property (nonatomic, assign) BOOL gay;
@end


@interface Status : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Status *retweetedStatus;
@end


@interface Ad : NSObject
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *url;
@end


@interface StatusResult : NSObject <YBJsonProtocal>
@property (nonatomic, strong) NSMutableArray *statuses;
@property (nonatomic, strong) NSArray *ads;
@property (nonatomic, strong) NSNumber *totalNumber;
@end




#pragma mark-  
@interface Bag : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double price;
@end

@interface Student : NSObject <YBJsonProtocal>
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *desc;
@end


