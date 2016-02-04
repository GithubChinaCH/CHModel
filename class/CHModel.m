//
//  CHModel.m
//  BaseModel简单使用
//
//  Created by jhtxch on 16/2/1.
//  Copyright © 2016年 jhtxch. All rights reserved.
//

#import "CHModel.h"
#import "AFNetworking.h"

@interface CHModel ()
@property(nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property(nonatomic, strong) NSDictionary *mapper;//映射字典
@end

static const char *propertyAryKey;
static const char *propertyDicKey;

@implementation CHModel

#pragma mark - HTTPRequest

- (void)setBaseUrl:(NSString *)baseUrl
{
    if (_baseUrl != baseUrl) {
        _baseUrl = baseUrl;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        [self settingDefaultHttpRequest];
    }
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        [self settingDefaultHttpRequest];
    }
    return _sessionManager;
}

- (void)settingDefaultHttpRequest
{
    //do some default setting
    [_sessionManager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:@"application/json;charset=utf-8"forHTTPHeaderField:@"Content-Type"];
//    [_sessionManager.requestSerializer setValue:@"8f8418050c74865be891e1dcb66ec3f2" forHTTPHeaderField:@"apikey"];
}



- (void)POST:(NSString *)url CompletionBlcok:(void (^)(BOOL, NSError *error))compBlock
{
    [self.sessionManager POST:url parameters:self.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"request success");
        NSLog(@"%@",responseObject);
        id value = [responseObject objectForKey:@"retData"];
        [self analyticalObjectData:value];
        compBlock(YES, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request fail");
        NSLog(@"error:%@",error);
        compBlock(NO, error);
    }];
}

- (void)GET:(NSString *)url CompletionBlcok:(void (^)(BOOL, NSError *))compBlock
{
    [self.sessionManager GET:url parameters:self.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"request success");
        NSLog(@"%@",responseObject);
        id value = [responseObject objectForKey:@"retData"];
        [self analyticalObjectData:value];
        compBlock(YES, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request fail");
        NSLog(@"error:%@",error);
        compBlock(NO, error);
    }];
}



#pragma mark - instance
- (id)init
{
    if (self = [super init]) {
        [self initDefault];
    }
    return self;
}

- (id)initWithJson:(id)object
{
    if (self = [super init]) {
        [self initDefault];
        [self analyticalObjectData:object];
    }
    return self;
}


#pragma mark - initDefault
- (void)initDefault
{
    [self setMapperDictionary];
    [self setPropertyAry];
}


- (NSDictionary *)setMapperDic
{
    return @{};
}

- (void)setMapperDictionary
{
    if (_mapper == nil) {
        _mapper = [self setMapperDic];
    }
}

- (void)setPropertyAry
{
    if (objc_getAssociatedObject(self, &propertyAryKey) == nil || objc_getAssociatedObject(self, &propertyDicKey) == nil) {
        unsigned int index = 0;
        objc_property_t *property = class_copyPropertyList(self.class, &index);
        NSMutableArray *propertyAry = [NSMutableArray array];
        NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < index; i ++) {
            NSString *name = [NSString stringWithUTF8String:property_getName(property[i])];
            NSString *attribute = [NSString stringWithUTF8String:property_getAttributes(property[i])];
            [propertyAry addObject:name];
            [propertyDic setObject:attribute forKey:name];
        }
        if (index > 0) {
            objc_setAssociatedObject(self, &propertyAryKey, propertyAry, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, &propertyDicKey, propertyDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        free(property);
    }
}


#pragma mark - analyticalData
//---------------analytical---------------
//data
- (void)analyticalObjectData:(id)data
{
    if (![data isKindOfClass:[NSDictionary class]]) {
        [self analyticalAryData:data];
    }
    else{
        [self analyticalDicData:data];
    }
}

//ary
- (void)analyticalAryData:(id)data
{
    NSDictionary *propertyDic = objc_getAssociatedObject(self, &propertyDicKey);
    NSArray *propertyAry = objc_getAssociatedObject(self, &propertyAryKey);
    if ([propertyAry count] == 1) {
        NSString *name = [propertyAry lastObject];
        NSString *attribute = [propertyDic objectForKey:name];
        NSDictionary *typeDic = [self propertyType:attribute];
        NSString *typeCode = [typeDic objectForKey:@"typeCode"];
        Class aryClass = NSClassFromString([typeDic objectForKey:@"className"]);
        if ([aryClass isSubclassOfClass:[NSArray class]]) {
            Class protocolClass = NSClassFromString([typeDic objectForKey:@"protocolName"]);
            if ([protocolClass isSubclassOfClass:[CHModel class]]) {
                NSArray *modelAry = [self modelAry:data WithClassName:protocolClass];
                [self setValue:modelAry forKey:name];
            }
            else{
                [self setValue:data forKey:name];
            }
        }else{
            if ([typeCode isEqualToString:@"@"]) {
                [self setValue:data forKey:name];
            }else{
                SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[self upTofirstCharacterIn:name]]);
                [self setValue:data WithTypeCode:typeCode SEL:sel];
            }
        }
    }
    
}


//dictionary
//属性类型： https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1

- (void)analyticalDicData:(NSDictionary *)data
{
    NSArray *propertyAry = objc_getAssociatedObject(self, &propertyAryKey);
    NSDictionary *propertyDic = objc_getAssociatedObject(self, &propertyDicKey);
    
    for (NSString *name in propertyAry) {
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[self upTofirstCharacterIn:name]]);
        NSString *attritute = [propertyDic objectForKey:name];
        NSDictionary *typeDic = [self propertyType:attritute];
        NSString *typeCode = typeDic[@"typeCode"];
        NSString *mapperKey = [_mapper objectForKey:name];
        NSString *finialKey = mapperKey ?: name;
        id value = [data objectForKey:finialKey];
        if (![typeCode isEqualToString:@"@"]) {
            [self setValue:value WithTypeCode:typeCode SEL:sel];
        }else{
            NSString *className = typeDic[@"className"];
            NSString *protocolName = typeDic[@"protocolName"];
            Class ObjectClass = NSClassFromString(className);
            if ([ObjectClass isSubclassOfClass:[self class]]) {
                id object = [[ObjectClass alloc] initWithJson:value];
                [self setValue:object forKey:name];
            }else{
                Class ProtocolClass = NSClassFromString(protocolName);
                if ([ProtocolClass isSubclassOfClass:[CHModel class]] && [ObjectClass isSubclassOfClass:[NSArray class]]) {
                    NSArray *ary = [self modelAry:value WithClassName:ProtocolClass];
                    [self setValue:ary forKey:name];
                }
                else{
                    [self setValue:value forKey:name];
                }
            }
        }
    }
}

- (void)setValue:(id)value WithTypeCode:(NSString *)typeCode SEL:(SEL)sel
{
    if ([typeCode  isEqual: @"i"] || [typeCode  isEqual: @"I"] || [typeCode  isEqual: @"s"] || [typeCode  isEqual: @"S"]) {
        if ([self respondsToSelector:sel]) {
            ((void(*)(id,SEL,...))objc_msgSend)(self,sel,[(NSString *)value intValue]);
        }
    }
    else if ([typeCode  isEqual: @"q"] || [typeCode  isEqual: @"Q"] || [typeCode  isEqual: @"l"] || [typeCode  isEqual: @"L"])
    {
        if ([self respondsToSelector:sel]) {
            ((void(*)(id,SEL,...))objc_msgSend)(self,sel,[(NSString *)value longLongValue]);
        }
    }
    else if ([typeCode  isEqual: @"f"])
    {
        if ([self respondsToSelector:sel]) {
            ((void(*)(id,SEL,...))objc_msgSend)(self,sel,[(NSString *)value floatValue]);
        }
    }
    else if ([typeCode isEqualToString: @"d"])
    {
        if ([self respondsToSelector:sel]) {
            ((void(*)(id,SEL,...))objc_msgSend)(self,sel,[(NSString *)value doubleValue]);
        }
    }
    else if ([typeCode  isEqual: @"B"])
    {
        if ([self respondsToSelector:sel]) {
            ((void(*)(id,SEL,...))objc_msgSend)(self,sel,[(NSString *)value boolValue]);
        }
    }
}


- (NSArray *)modelAry:(NSArray *)ary WithClassName:(Class)cls
{
    NSMutableArray *modelAry = [NSMutableArray array];
    for (id object in ary) {
        id model = [[cls alloc] initWithJson:object];
        [modelAry addObject:model];
    }
    return modelAry;
}



#pragma mark - otherMethod
//获取类型
- (NSDictionary *)propertyType:(NSString *)str
{
    NSString *typeCode = nil;
    NSString *className = nil;
    NSString *protocolName = nil;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanUpToString:@"T" intoString:NULL];
    [scanner scanString:@"T" intoString:NULL];
    typeCode = [str substringWithRange:NSMakeRange(scanner.scanLocation, 1)];
    if ([typeCode isEqualToString:@"@"]) {
        [scanner scanUpToString:@"\"" intoString:NULL];
        [scanner scanString:@"\"" intoString:NULL];
        [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&className];
        if ([scanner scanString:@"<" intoString:NULL]) {
            [scanner scanUpToString:@">" intoString:&protocolName];
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (typeCode) {
        [dic setObject:typeCode forKey:@"typeCode"];
    }
    if (className) {
        [dic setObject:className forKey:@"className"];
    }
    if (protocolName) {
        [dic setObject:protocolName forKey:@"protocolName"];
    }
    return dic;
    
}

//使首字母大写其他字母不变
- (NSString *)upTofirstCharacterIn:(NSString *)str
{
    NSMutableString *mutableStr = [NSMutableString stringWithString:str];
    [mutableStr replaceCharactersInRange:NSMakeRange(0, 1) withString:[[str substringToIndex:1] uppercaseString]];
    return mutableStr;
}



@end
