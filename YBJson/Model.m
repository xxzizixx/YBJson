//
//  Model.m
//  YBJson
//
//  Created by 杨彪 on 16/8/8.
//  Copyright © 2016年 杨彪. All rights reserved.
//

#import "Model.h"

@implementation User

@end



@implementation Status

@end



@implementation Ad

@end



@implementation StatusResult 

- (NSDictionary *)objectModelNeedToConvertInArray {
    
    return @{
              @"statuses" : [Status class],
              @"ads" : [Ad class]
             };
    
}

@end



@implementation Bag

@end



@implementation Student

- (NSDictionary *)keyReplacedPropertyName {
    
    return @{
             @"ID" : @"id",
             @"desc" : @"desciption",
             };
}

@end


