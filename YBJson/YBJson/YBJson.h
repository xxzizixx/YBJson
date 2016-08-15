//
//  YBJsonParams.h
//  YBJson
//
//  Created by 杨彪 on 16/8/8.
//  Copyright © 2016年 杨彪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark-   类的声明*****YBJsonBase
@interface YBJsonBase : NSObject

+ (BOOL)isClassFromBase:(Class)Class;

@end


#pragma mark-   类的声明*****YBJsonParam
@interface YBJsonParam : NSObject

@property (nonatomic, assign) int index;

@property (nonatomic, copy) NSString *type;

@end


#pragma mark-   类的声明*****YBJsonType
@interface YBJsonType : NSObject

@property (nonatomic, copy) NSString *code;

@property (nonatomic, assign, readonly) Class typeClass;

@property (nonatomic, assign) BOOL classFromBase;

@property (nonatomic, assign) BOOL KVCdisabled;

- (instancetype)initWithCode:(NSString *)code;

@end


#pragma mark-   类的声明*****YBJsonMember
@interface YBJsonMember : NSObject
{
    __weak id _whichObject;
    NSString *_name;
}

@property (nonatomic, assign) Class whichClass;

@property (nonatomic, weak, readonly) id whichObject;

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, assign, readonly, getter=isWhichClassFromBase) BOOL whichClassFromBase;

- (instancetype)initWithWhichObject:(id)whichObject;
@end


#pragma mark-   类的声明*****YBJsonIvae
@interface YBJsonIvar : YBJsonMember

@property (nonatomic, copy) NSString *propertyName;

@property (nonatomic) id value;

@property (nonatomic, assign) Ivar ivar;

@property (nonatomic, strong) YBJsonType *type;

- (instancetype)initWithIvar:(Ivar)ivar whichObject:(id)whichObject;

@end


#pragma mark-   类的声明*****YBJsonMethod
@interface YBJsonMethod : YBJsonMember

@property (nonatomic, assign) Method method;

@property (nonatomic, assign) SEL selector;

@property (nonatomic, strong) NSArray *params;

@property (nonatomic, copy) NSString *returnType;

- (instancetype)initWithMethod:(Method)method whichObject:(id)whichObject;

@end

#pragma mark-  Block的定义
/** 遍历成员变量用的block */
typedef void (^YBIvarsBlock)   (YBJsonIvar *ivar, BOOL *stop);

/** 遍历方法用的block */
typedef void (^YBMethodsBlock) (YBJsonMethod *method, BOOL *stop);

/** 遍历所有类用的block */
typedef void (^YBClassesBlock) (Class Class, BOOL *stop);




#pragma mark-   分类的声明*****YBCoding
@interface NSObject (YBCoding)
/** 解码（从文件中解析对象） */
- (void)decode:(NSCoder *)decoder;
/** 编码（将对象写入文件中） */
- (void)encode:(NSCoder *)encoder;

@end

/** 归档的实现 */
#define YBCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self decode:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self encode:encoder]; \
}


#pragma mark-   分类的声明*****YBMemberBlock
@interface NSObject (YBMemberBlock)

/** 遍历所有的成员变量 */
- (void)enumerateIvarsWithBlock:(YBIvarsBlock)block;

/** 遍历所有的方法 */
- (void)enumerateMethodsWithBlock:(YBMethodsBlock)block;

/** 遍历所有的类 */
- (void)enumerateClassesWithBlock:(YBClassesBlock)block;

@end


#pragma mark-   协议的声明*****YBJsonProtocal
@protocol YBJsonProtocal <NSObject>
@optional
/** 将属性名换为其他key去字典中取值 */
- (NSDictionary *)keyReplacedPropertyName;

/** 数组中需要转换的模型类 */
- (NSDictionary *)objectModelNeedToConvertInArray;

/** 当字典转模型完毕时调用 */
- (void)dictionaryConvertToModelDidFinish;

/** 当模型转字典完毕时调用 */
- (void)modelConvertToDictionaryDidFinish;

@end


#pragma mark-   分类的声明*****YBJsonModel
@interface NSObject (YBJsonModel) <YBJsonProtocal>

/** 将字典的键值对转成模型属性 */
- (void)convertDictionaryToModel:(NSDictionary *)dict;

/** 将模型转成字典 */
- (NSDictionary *)convertModelToDictionary;


/** 通过字典来创建一个模型 */
+ (instancetype)createModelFromDictionary:(NSDictionary *)dict;

/** 通过字典数组来创建一个模型数组 */
+ (NSArray *)createModelArrayFromDictionaryArray:(NSArray *)dictArray;

/** 通过模型数组来创建一个字典数组 */
+ (NSArray *)createDictionaryArrayFromModelArray:(NSArray *)modelArray;

/** 通过JSON数据来创建一个模型 */
+ (instancetype)createModelFromJsonData:(NSData *)jsonData;

/** 通过JSON数据来创建一个模型数组 */
+ (NSArray *)createModelArrayFromJsonData:(NSData *)jsonData;

/** 通过plist来创建一个模型 (fileName文件名(仅限于mainBundle中的文件)) */
+ (instancetype)createModelFromPlistWithFileName:(NSString *)fileName;

/** 通过plist来创建一个模型 (filePath文件全路径) */
+ (instancetype)createModelFromPlistWithFilePath:(NSString *)filePath;

/** 通过plist来创建一个模型数组 (fileName文件名(仅限于mainBundle中的文件)) */
+ (NSArray *)createModelArrayFromPlistWithFileName:(NSString *)fileName;

/** 通过plist来创建一个模型数组 (filePath文件全路径) */
+ (NSArray *)createModelArrayFromPlistWithFilePath:(NSString *)filePath;

@end




