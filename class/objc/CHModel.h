//
//  CHModel.h
//  BaseModel简单使用
//
//  Created by jhtxch on 16/2/1.
//  Copyright © 2016年 jhtxch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "AFNetworking.h"

typedef void(^cmpBlock)(BOOL isSuccess);
@interface CHModel : NSObject

//property
@property (nonatomic, strong)        AFHTTPSessionManager *sessionManager;
//请求参数
@property (nonatomic, strong)        NSMutableDictionary *parameters;

//用于接收返回的消息
@property (nonatomic, copy)          NSString *message;
@property (nonatomic, assign)        NSInteger code;
//失败后的errcode 用于判断失败的原因
@property (nonatomic, assign, readonly)        NSInteger errcode;
//--------------method----------
//instance
- (instancetype)initWithJson:(id)object;

//fetch
- (void)GET:(NSString *)url CompletionBlcok:(cmpBlock)compBlock;
- (void)POST:(NSString *)url CompletionBlcok:(cmpBlock)compBlock;

//映射子弹
- (NSDictionary *)setMapperDic;

//需要解析哪一层的数据
- (id)parsingWithObj:(id)obj;

//最终的请求参数是什么样子的
- (NSDictionary *)finialParameters;

@end
