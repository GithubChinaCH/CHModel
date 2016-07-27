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
#import <AFNetworking.h>

typedef void(^cmpBlock)(BOOL isSuccess);
@interface CHModel : NSObject

//property
@property (nonatomic, strong)        AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong)        NSMutableDictionary *parameters;
@property (nonatomic, copy,readonly) NSString *errorStr;
@property (nonatomic, copy)          NSString *parsingStr;

//--------------method----------
//instance
- (instancetype)initWithJson:(id)object;

//fetch
- (void)GET:(NSString *)url CompletionBlcok:(cmpBlock)compBlock;
- (void)POST:(NSString *)url CompletionBlcok:(cmpBlock)compBlock;

//other
- (NSDictionary *)setMapperDic;


@end
