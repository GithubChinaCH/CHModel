# CHModel
1进行网络请求 获取对象属性  2解析自定义json格式

CHModel是基于‘AFNetworling’（3.0.4） 使用前请添加AFNetworking     pod 'AFNetworking', '~> 3.0'

#方法属性说明
```
//property
@property(nonatomic, strong) NSMutableDictionary *parameters;//请求参数
@property(nonatomic, copy) NSString *baseUrl; //baseUrl


//--------------method----------
//instance
- (instancetype)initWithJson:(id)object; //构造方法

//fetch 进行网络请求
- (void)GET:(NSString *)url CompletionBlcok:(void(^)(BOOL isSuccess, NSError *error))compBlock;
- (void)POST:(NSString *)url CompletionBlcok:(void(^)(BOOL isSuccess, NSError *error))compBlock;
```

#功能1 进行网络请求 获取对象属性

可以在CHModel.m文件的- (void)settingDefaultHttpRequest方法中进行一些基本的网络请求的设置
```
- (void)settingDefaultHttpRequest
```

根据网络请求返回的数据格式修改“re Data”的值
```
- (void)POST:(NSString *)url CompletionBlcok:(void (^)(BOOL, NSError *error))compBlock
{
    [self.sessionManager POST:url parameters:self.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"request success");
        NSLog(@"%@",responseObject);
        //[self analyticalObjectData:responseObject];
        [self analyticalObjectData:responseObject objectForKey:@"retData"];//根据返回数据的值 删除或者修改"retData"
        compBlock(YES, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request fail");
        NSLog(@"error:%@",error);
        compBlock(NO, error);
    }];
}
```
使用方法

1创建一个继承于CHModel的子类  
2设置子类的属性
3进行网络请求

#例子

注意返回名字和参数名不一样要设置映射字典- (NSDictionary *)setMapperDic
```
- (NSDictionary *)setMapperDic
```
参照 http://apistore.baidu.com/apiworks/servicedetail/112.html
```
url:"https://apis.baidu.com/apistore/weatherservice/citylist"
requestHeader: apikey = 8f8418050c74865be891e1dcb66ec3f2
paramters: cityname = 杭州
```
```
@protocol chSubM <NSObject>
@end

@interface chSubM : CHModel
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cityID;
@end


@interface chSubModel : CHModel
@property (nonatomic, strong) NSArray<chSubM> *citys;
@end
```
```
chSubModel *mdoel = [[chSubModel alloc] init]; //创建
mdoel.parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"cityname":@"杭州"}];   //设置请求参数
//进行请求  可以在子类中自己分装请求方法 也可以使用父类的请求方法
[mdoel GET:@"https://apis.baidu.com/apistore/weatherservice/citylist" CompletionBlcok:^(BOOL isSuccess, NSError *error) {
    NSLog(@"%@",mdoel);
}];
```
```
CHModel.m
- (void)settingDefaultHttpRequest
{
    //do some default setting
    [_sessionManager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:@"application/json;charset=utf-8"forHTTPHeaderField:@"Content-Type"];
    [_sessionManager.requestSerializer setValue:@"8f8418050c74865be891e1dcb66ec3f2" forHTTPHeaderField:@"apikey"];
}
```
解析完毕后返回的数据

![1111](https://github.com/GithubChinaCH/CHModel/raw/master/1111.png)

#功能2 解析自定义
使用方法- (instancetype)initWithJson:(id)object 构造对象即可进行解析
```
- (instancetype)initWithJson:(id)object;
```

