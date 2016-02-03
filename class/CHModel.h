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

@interface CHModel : NSObject

//property
@property(nonatomic, strong) NSMutableDictionary *parameters;
@property(nonatomic, copy) NSString *baseUrl;


//--------------method----------
//instance
- (instancetype)initWithJson:(id)object;

//fetch
- (void)GET:(NSString *)url CompletionBlcok:(void(^)(BOOL isSuccess, NSError *error))compBlock;
- (void)POST:(NSString *)url CompletionBlcok:(void(^)(BOOL isSuccess, NSError *error))compBlock;


@end
