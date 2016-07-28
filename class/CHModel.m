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

@property (nonatomic, strong) NSDictionary *mapper;//映射字典

@end

#define typeCode     @"typeCode"
#define className    @"className"
#define protocolName @"protocolName"

static NSString *propertyDicKey;
static NSString *propertyAryKey;

@implementation CHModel

#pragma mark - init

- (instancetype)init
{
    if (self = [super init]) {
        [self initDefalt];
    }
    return self;
}

- (instancetype)initWithJson:(id)object
{
    self = [super init];
    if (self) {
        [self initDefalt];
        [self analyzeData:object];
    }
    return self;
}

#pragma mark - init default

- (void)initDefalt
{
    self.parsingStr = nil;
    [self setMapperDic];
    [self setProperty];
}

- (void)setProperty
{
    if (objc_getAssociatedObject(self, &propertyDicKey) == nil || objc_getAssociatedObject(self, &propertyAryKey) == nil) {
        unsigned int count = 0;
        objc_property_t *propertys = class_copyPropertyList(self.class, &count);
        NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
        NSMutableArray *propertyAry = [NSMutableArray array];
        for (int i = 0; i < count ; i ++) {
            NSString *attribute = [NSString stringWithUTF8String:property_getAttributes(propertys[i])];
            NSString *name = [NSString stringWithUTF8String:property_getName(propertys[i])];
            [propertyAry addObject:name];
            [propertyDic setValue:attribute forKey:name];
        }
        if (count > 0) {
            objc_setAssociatedObject(self, &propertyAryKey, propertyAry, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, &propertyDicKey, propertyDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        free(propertys);
    }
}

- (void)setMapperDictionary
{
    self.mapper = [self setMapperDic];
}

- (NSDictionary *)setMapperDic
{
    return @{};
}

#pragma mark - network
- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        [self configurationSessionManager];
    }
    return _sessionManager;
}

- (void)configurationSessionManager
{
    //do some setting
    //    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [_sessionManager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:@"application/json;charset=utf-8"forHTTPHeaderField:@"Content-Type"];
}

- (void)POST:(NSString *)url CompletionBlcok:(cmpBlock)compBlock
{
    [self.sessionManager POST:url parameters:self.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //set error string
        //        _errorStr = [responseObject objectForKey:@"key"];
        //analyze data
        NSLog(@"%@",responseObject);
        if (self.parsingStr) {
            id data = [responseObject objectForKey:self.parsingStr];
            [self analyzeData:data];
        }else{
            [self analyzeData:responseObject];
        }
        compBlock(YES);
        [self releaseSession:self.sessionManager];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@",error);
        compBlock(NO);
        [self releaseSession:self.sessionManager];
    }];
}

- (void)GET:(NSString *)url CompletionBlcok:(cmpBlock)compBlock
{
    [self.sessionManager GET:url parameters:self.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //set error string
        //        _errorStr = [responseObject objectForKey:@"key"];
        //analyze data
        NSLog(@"%@",responseObject);
        if (self.parsingStr) {
            id data = [responseObject objectForKey:self.parsingStr];
            [self analyzeData:data];
        }else{
            [self analyzeData:responseObject];
        }
        compBlock(YES);
        [self releaseSession:self.sessionManager];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@",error);
        compBlock(NO);
        [self releaseSession:self.sessionManager];
    }];
}

//完成任务后释放session 不然会造成内存泄漏
- (void)releaseSession:(AFURLSessionManager *)manager
{
    if (manager.session) {
        [manager.session finishTasksAndInvalidate];
    }
}


#pragma mark - analyze data

- (void)analyzeData:(id)data
{
    if ([data isKindOfClass:[NSArray class]]) {
        [self analyzeAry:data];
    }else if ([data isKindOfClass:[NSDictionary class]]){
        [self analyzeDic:data];
    }
}

- (void)analyzeAry:(NSArray *)data
{
    NSMutableArray *propertyAry = objc_getAssociatedObject(self, &propertyAryKey);
    NSMutableArray *propertyDic = objc_getAssociatedObject(self, &propertyDicKey);
    for (NSString *name in propertyAry) {
        NSString *attribute = [propertyDic valueForKey:name];
        NSDictionary *typeDic = [self propertyType:attribute];
        //        NSString *key = [_mapper objectForKey:name] ?: name;
        NSString *class = [typeDic valueForKey:className];
        NSString *protocol = [typeDic valueForKey:protocolName];
        Class cls = NSClassFromString(class);
        Class proCls = NSClassFromString(protocol);
        if ([cls isSubclassOfClass:[NSArray class]] && [proCls isSubclassOfClass:[CHModel class]]) {
            NSArray *ary = [self analyzeAryFrom:data withClass:proCls];
            [self setValue:ary forKey:name];
        }else if ([cls isSubclassOfClass:[NSArray class]]){
            [self setValue:data forKey:name];
        }
    }
    
    
}

- (void)analyzeDic:(NSDictionary *)data
{
    NSMutableArray *propertyAry = objc_getAssociatedObject(self, &propertyAryKey);
    NSMutableArray *propertyDic = objc_getAssociatedObject(self, &propertyDicKey);
    for (NSString *name in propertyAry) {
        NSString *attribute = [propertyDic valueForKey:name];
        NSDictionary *typeDic = [self propertyType:attribute];
        NSString *key = [_mapper objectForKey:name] ?: name;
        id value = [data objectForKey:key];
        NSString *code = [typeDic objectForKey:typeCode];
        if ([code isEqualToString:@"@"]) {
            //该属性是oc对象
            NSString *class = [typeDic objectForKey:className];
            NSString *protocol = [typeDic objectForKey:protocolName];
            Class objClass = NSClassFromString(class);
            Class proClass = NSClassFromString(protocol);
            if ([objClass isSubclassOfClass:[CHModel class]]) {
                //是CHModel的子类
                id obj = [[objClass alloc] initWithJson:value];
                [self setValue:obj forKey:name];
            }else if ([objClass isSubclassOfClass:[NSArray class]] && [proClass isSubclassOfClass:[CHModel class]]){
                //是数组且<>中是CHModel的子类
                NSArray *ary = [self analyzeAryFrom:(NSArray *)value withClass:proClass];
                [self setValue:ary forKey:name];
            }else{
                //其他oc对象
                [self setValue:value forKey:name];
            }
            
        }else{
            //不是oc对象
            [self setValue:value forKey:name];
        }
    }
}

- (NSArray *)analyzeAryFrom:(NSArray *)ary withClass:(Class)Cls
{
    NSMutableArray *returnAry = [NSMutableArray array];
    for (id value in ary) {
        id object = [[Cls alloc] initWithJson:value];
        [returnAry addObject:object];
    }
    return returnAry;
}


//获取属性的基本信息
- (NSDictionary *)propertyType:(NSString *)str
{
    NSString *code = nil;
    NSString *class = nil;
    NSString *protocol = nil;
    NSScanner *scaner = [NSScanner scannerWithString:str];
    [scaner scanUpToString:@"T" intoString:nil];
    [scaner scanString:@"T" intoString:nil];
    code = [str substringWithRange:NSMakeRange(scaner.scanLocation, 1)];
    if ([code isEqualToString:@"@"]) {
        [scaner scanUpToString:@"\"" intoString:NULL];
        [scaner scanString:@"\"" intoString:NULL];
        [scaner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&class];
        if ([scaner scanString:@"<" intoString:NULL]) {
            [scaner scanUpToString:@">" intoString:&protocol];
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (code) {
        [dic setObject:code forKey:typeCode];
    }
    if (class) {
        [dic setObject:class forKey:className];
    }
    if (protocol) {
        [dic setObject:protocol forKey:protocolName];
    }
    
    return dic;
}

@end
