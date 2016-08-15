//
//  YBJsonParams.m
//  YBJson
//
//  Created by 杨彪 on 16/8/8.
//  Copyright © 2016年 杨彪. All rights reserved.
//

#import "YBJson.h"

#pragma mark-   类的实现*****YBJsonPBase
static NSArray *bassClasses;
@implementation YBJsonBase

+ (void)initialize {
    
    // 初始化baseClass的类型
    bassClasses = @[@"NSObject", @"NSString",@"NSMutableString", @"NSArray",@"NSMutableArray", @"NSDictionary",@"NSMutableDictionary", @"NSURL",@"NSMutableURL", @"NSData",@"NSMutableData", @"NSNumber", @"NSDate"];
}

+ (BOOL)isClassFromBase:(Class)Class {
    
    // 判断参数是否为空 
    if (!Class) return NO;
    
    //   首先判断对象是不是包含在当前所设定的类里面；
    return [bassClasses containsObject:NSStringFromClass(Class)];
}

@end


#pragma mark-   类的实现*****YBJsonParam
@implementation YBJsonParam

@end


#pragma mark-   类的实现*****YBJsonType
@implementation YBJsonType

- (instancetype)initWithCode:(NSString *)code {
    
    if (self = [super init]) {
        self.code = code;
    }
    return self;
}

/** 重写类型标识符set方法 */
- (void)setCode:(NSString *)code {
    
    _code = code;
    if (!code) return;
    
    if (code.length == 0 || [code isEqualToString:@":"] || [code isEqualToString:@"^{objc_ivar=}"] || [code isEqualToString:@"^{objc_method=}"]) {
        
        self.KVCdisabled = YES;
    } else if ([code hasPrefix:@"@"] && code.length > 3) {
        
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringFromIndex:2];
        _code = [_code substringToIndex:_code.length - 1];
        _typeClass = NSClassFromString(_code);
        
        _classFromBase = [YBJsonBase isClassFromBase:_typeClass];
    }
}
@end


#pragma mark-   类的实现*****YBJsonMember
@implementation YBJsonMember

- (instancetype)initWithWhichObject:(id)whichObject {
    
    if (self = [super init]) {
        _whichObject = whichObject;
    }
    return self;
}

/** whichObject成员变量来源于哪一个累set重写赋值 */
- (void)setWhichClass:(Class)whichClass {
    
    _whichClass = whichClass;
    
    if (!whichClass) return;
    
    //  判断当前成员来源类是否是来自于Base里面；
    _whichClassFromBase = [YBJsonBase isClassFromBase:whichClass];
}
@end


#pragma mark-   类的实现*****YBJsonIvar
@implementation YBJsonIvar

- (instancetype)initWithIvar:(Ivar)ivar whichObject:(id)whichObject {
    
    if (self = [super initWithWhichObject:whichObject]) {
        
        self.ivar = ivar;
    }
    return self;
}

/** 重写ivar的set方法 */
- (void)setIvar:(Ivar)ivar {
    
    _ivar = ivar;
    
    // 1.获取成员变量名
    _name = [NSString stringWithUTF8String:ivar_getName(ivar)];
    
    // 2.获取属性名,也就是截取成员变量的名称的_(下划线)
    _propertyName = [_name hasPrefix:@"_"] ? [_name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] : _name;
    
    // 3.获取成员变量的类型符
    _type = [[YBJsonType alloc] initWithCode:[NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)]];
}

/** 重写value成员变量的值set和get方法 */
- (void)setValue:(id)value {
    
    if (_type.KVCdisabled) return;
    [_whichObject setValue:value forKey:_propertyName];
}
- (id)value {
    
    if (_type.KVCdisabled) return [NSNull null];
    return [_whichObject valueForKey:_propertyName];
}
@end


#pragma mark-   类的实现*****YBJsonMethod
@implementation YBJsonMethod

- (instancetype)initWithMethod:(Method)method whichObject:(id)whichObject {
    
    if (self = [super initWithWhichObject:whichObject]) {
        
        self.method = method;
    }
    return self;
}

- (void)setMethod:(Method)method {
    
    _method = method;
    
    if (!method) return;
    
    // 1.方法选择器
    _selector = method_getName(method);
    _name = NSStringFromSelector(self.selector);
    
    // 2.参数
    int argCount = method_getNumberOfArguments(method);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:argCount];
    for (int i = 2; i < argCount; i++) {
        YBJsonParam *param = [[YBJsonParam alloc] init];
        param.index = i - 2;
        param.type = [NSString stringWithUTF8String:method_copyArgumentType(method, i)];
        
        [params addObject:param];
    }
    _params = params;
    
    
    // 3.返回值类型
    _returnType = [NSString stringWithUTF8String:method_copyReturnType(method)];
}
@end


#pragma mark-   分类的实现*****YBCoding
@implementation NSObject (YBCoding)

- (void)encode:(NSCoder *)encoder {
    
    [self enumerateIvarsWithBlock:^(YBJsonIvar *ivar, BOOL *stop) {
        
        if (ivar.isWhichClassFromBase) return;
        [encoder encodeObject:ivar.value forKey:ivar.name];
    }];
}

- (void)decode:(NSCoder *)decoder {
    
    [self enumerateIvarsWithBlock:^(YBJsonIvar *ivar, BOOL *stop) {
        
        if (ivar.isWhichClassFromBase) return;
        ivar.value = [decoder decodeObjectForKey:ivar.name];
    }];
}

@end


#pragma mark-   分类的实现*****YBMemberBlock
@implementation NSObject (YBMemberBlock)
/**
 *  遍历所有的成员变量
 */
- (void)enumerateIvarsWithBlock:(YBIvarsBlock)block {
    
    [self enumerateClassesWithBlock:^(__unsafe_unretained Class Class, BOOL *stop) {
        // 1.获得所有的成员变量
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList(Class, &ivarCount);
        
        // 2.遍历每一个成员变量
        for (int i = 0; i < ivarCount; i++) {
            YBJsonIvar *ivar = [[YBJsonIvar alloc] initWithIvar:ivars[i] whichObject:self];
            ivar.whichClass = Class;
            block(ivar, stop);
        }
        
        // 3.释放内存
        free(ivars);
    }];
}

/**
 *  遍历所有的方法
 */
- (void)enumerateMethodsWithBlock:(YBMethodsBlock)block {
    
    [self enumerateClassesWithBlock:^(__unsafe_unretained Class Class, BOOL *stop) {
        // 1.获得所有的方法列表
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(Class, &methodCount);
        
        // 2.遍历每一个方法
        for (int i = 0; i < methodCount; i++) {
            YBJsonMethod *method = [[YBJsonMethod alloc] initWithMethod:methods[i] whichObject:self];
            method.whichClass = Class;
            block(method, stop);
        }
        
        // 3.释放内存
        free(methods);
    }];
}

/**
 *  遍历所有的类
 */
- (void)enumerateClassesWithBlock:(YBClassesBlock)block {
    
    // 1.没有block就直接返回
    if (block == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class Class = [self class];
    
    // 4.开始遍历每一个类
    while (Class && !stop) {
        // 4.1.执行操作
        block(Class, &stop);
        
        // 4.2.获得父类
        Class = class_getSuperclass(Class);
    }
}

@end


#pragma mark-   分类的实现*****YBJsonModel
@implementation NSObject (YBJsonModel)


/** 将字典的键值对转成模型属性 */
- (void)convertDictionaryToModel:(NSDictionary *)dict {
    
    if (![dict isKindOfClass:[NSDictionary class]]) return;
    
    [self enumerateIvarsWithBlock:^(YBJsonIvar *ivar, BOOL *stop) {
        
        // 来自Foundation框架的成员变量，直接返回
        if (ivar.isWhichClassFromBase) return;
        
        // 1.取出属性值
        NSString *key = [self getKeyFromPropertyName:ivar.propertyName];
        
        // 根据属性名获取对应的key
        id value = dict[key];
        // 值为空就直接返回
        if (!value || [value isKindOfClass:[NSNull class]]) return;
        
        // 2.如果是模型属性
        if (ivar.type.typeClass && !ivar.type.classFromBase) {
            // 成员变量属性不为空并且不是来自foundation；
            value = [ivar.type.typeClass createModelFromDictionary:value];
            
        } else if (ivar.type.typeClass == [NSString class] && [value isKindOfClass:[NSNumber class]]) {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            // 成员变量为foundation并且属性是string值是number；则将值从number转成string；
            value = [formatter stringFromNumber:value];
            
        } else if (ivar.type.typeClass == [NSNumber class] && [value isKindOfClass:[NSString class]]) {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            value = [formatter numberFromString:value];
            
        } else if (ivar.type.typeClass == [NSURL class] && [value isKindOfClass:[NSString class]]) {
            
            value = [NSURL URLWithString:value];
            
        } else if (ivar.type.typeClass == [NSString class] && [value isKindOfClass:[NSURL class]]) {
            
            value = [value absoluteString];
            
        } else if ([self respondsToSelector:@selector(objectModelNeedToConvertInArray)]) {
            // 3.字典数组-->模型数组
            //字典里面装的还是字典；将字典数组转成模型数组类型；
            Class objectClass = [self objectModelNeedToConvertInArray][ivar.propertyName];
            
            if (objectClass) {
                value = [objectClass createModelArrayFromDictionaryArray:value];
            }
        }
        
        // 4.赋值
        ivar.value = value;
    }];
    
    // 转换完毕
    if ([self respondsToSelector:@selector(dictionaryConvertToModelDidFinish)]) {
        
        [self dictionaryConvertToModelDidFinish];
    }
}


/** 将模型转成字典 */
- (NSDictionary *)convertModelToDictionary {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [self enumerateIvarsWithBlock:^(YBJsonIvar *ivar, BOOL *stop) {
        
        if (ivar.isWhichClassFromBase)  return;
        
        // 1.取出属性值
        id value = ivar.value;
        if (!value) return;
        
        // 2.如果是模型属性
        if (ivar.type.typeClass && !ivar.type.classFromBase) {
            // 成员变量属性不为空并且不是来自Base；
            value = [value convertModelToDictionary];
            
        } else if (ivar.type.typeClass == [NSURL class]) {
            value = [value absoluteString];
            
        } else if ([self respondsToSelector:@selector(objectModelNeedToConvertInArray)]) {
            // 3.处理数组里面有模型的情况
            Class objectClass = [self objectModelNeedToConvertInArray][ivar.propertyName];
            if (objectClass) {
                // 通过模型数组来创建一个字典数组
                value = [objectClass createDictionaryArrayFromModelArray:value];
            }
        }
        
        // 4.赋值
        dict[[self getKeyFromPropertyName:ivar.propertyName]] = value;
        
    }];
    
    if ([self respondsToSelector:@selector(modelConvertToDictionaryDidFinish)]) {
        
        [self modelConvertToDictionaryDidFinish];
    }
    
    return dict;
}


/** 通过字典来创建一个模型 */
+ (instancetype)createModelFromDictionary:(NSDictionary *)dict {
    
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    id model = [[self alloc] init];
    [model convertDictionaryToModel:dict];
    return model;
}

/** 通过字典数组来创建一个模型数组 */
+ (NSArray *)createModelArrayFromDictionaryArray:(NSArray *)dictArray {
    
    // 1.判断真实性
    if (![dictArray isKindOfClass:[NSArray class]]) return nil;
    
    // 2.创建数组
    NSMutableArray *modelArray = [NSMutableArray array];
    
    // 3.遍历
    for (NSDictionary *dict in dictArray) {
        // 如果不是字典，就继续循环；
        if (![dict isKindOfClass:[NSDictionary class]]) continue;
        // 通过字典来创建一个模型
        id model = [self createModelFromDictionary:dict];
        [modelArray addObject:model];
    }
    return modelArray;
}

/** 通过模型数组来创建一个字典数组 */
+ (NSArray *)createDictionaryArrayFromModelArray:(NSArray *)modelArray {
    
    // 1.判断真实性
    if (![modelArray isKindOfClass:[NSArray class]]) return nil;
    
    // 2.过滤
    if (![modelArray isKindOfClass:[NSArray class]]) return modelArray;
    if (![[modelArray lastObject] isKindOfClass:self]) return modelArray;
    
    // 3.创建数组
    NSMutableArray *dictArray = [NSMutableArray array];
    for (id model in modelArray) {
        [dictArray addObject:[model convertModelToDictionary]];
    }
    return dictArray;
}

/** 通过JSON数据来创建一个模型 */
+ (instancetype)createModelFromJsonData:(NSData *)jsonData {
    
    if (!jsonData) return nil;
    
    // 解析json数据转换成字典，并将字典转换成模型
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    return [self createModelFromDictionary:dict];
}

/** 通过JSON数据来创建一个模型数组 */
+ (NSArray *)createModelArrayFromJsonData:(NSData *)jsonData {
    
    if (!jsonData) return nil;
    
    NSArray *dictArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    return [self createModelArrayFromDictionaryArray:dictArray];
}

/** 通过plist来创建一个模型 (fileName文件名(仅限于mainBundle中的文件)) */
+ (instancetype)createModelFromPlistWithFileName:(NSString *)fileName {
    
    if (!fileName) return nil;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    return [self createModelFromPlistWithFilePath:filePath];
}

/** 通过plist来创建一个模型 (filePath文件全路径) */
+ (instancetype)createModelFromPlistWithFilePath:(NSString *)filePath {
    
    if (!filePath) return nil;
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    return [self createModelFromDictionary:dict];
}

/** 通过plist来创建一个模型数组 (fileName文件名(仅限于mainBundle中的文件)) */
+ (NSArray *)createModelArrayFromPlistWithFileName:(NSString *)fileName {
    
    if (!fileName) return nil;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    return [self createModelArrayFromPlistWithFilePath:filePath];
}

/** 通过plist来创建一个模型数组 (filePath文件全路径) */
+ (NSArray *)createModelArrayFromPlistWithFilePath:(NSString *)filePath {
    
    if (!filePath) return nil;
    
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:filePath];
    
    return [self createModelArrayFromDictionaryArray:dictArray];
}



/** 根据属性名获得对应的key */
- (NSString *)getKeyFromPropertyName:(NSString *)propertyName {
    
    if (!propertyName) return nil;
    
    NSString *key = nil;
    
    if ([self respondsToSelector:@selector(keyReplacedPropertyName)]) {
        
        key = [self keyReplacedPropertyName][propertyName];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}

@end



