# YBJson  https://github.com/xxzizixx/YBJson
字典转模型的小框架，使用只需要导入YBJson即可；
只有一个文件YBJSon文件，里面包涵了需要的所有方法；

例子里面有主要的使用方法，方法名都是非常好识别的；

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


##   如果喜欢，请右上角给一颗星，谢谢！ 

