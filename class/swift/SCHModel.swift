//
//  SCHModel.swift
//  OOP到POP
//
//  Created by APPLE on 2018/1/18.
//  Copyright © 2018年 HaRi. All rights reserved.
//

import UIKit

/**
 1. 定义属性的时候,如果是对象,通常都是可选的(类后面加’?’)
 - 在需要的时候创建
 - 避免写构造函数,可以简化代码
 2. 如果是基本数据类型,不能设置为可选的,而且要设置初始值,否则KVC崩溃
 3. 若果需要使用KVC设置属性,属性不能是private的
 4. 使用KVC方法之前,应该调用 super.init 保证对象实例化完成
 */

/**
 注意1:基本数据类型不能使用可选值
 2：数组 字典等 使用swfit的结构体  不要用oc的NSArray NSDictionary
 */

class SCHModel: NSObject {
    
    var propertyAry:Array<(String,String)> = [] // 属性名称,属性类型
    
    override init() {
        super.init()
        self.initDefault()
    }
    
    required init(json:AnyObject) {
        super.init()
        self.initDefault()
        self.parseData(json: json)
    }
    
    func initDefault(){
        self.getAllProperty()
    }
    
    
    //MARK:解析 属性 使用反射Mirror
    func parseData(json:AnyObject){
        
        if json is Array<Any> {
            self.parseAryData(json: json as! Array)
        }else if json is Dictionary<String,Any>{
            self.parseDicData(json: json as! Dictionary)
        }
    }
    
    // 解析数组
    func parseAryData(json:Array<Any>){
        if json.count == 0 || propertyAry.count == 0 {
            return
        }
        //这种情况基本不存在（只有一个属性）
        let info = propertyAry.last
        
        let name = info!.0
        let type = self.getAryClassNameAndItem(aryTitle: info!.1).1
        
        if let clsName = self.judgeIsSubClassofSCHmodel(cls: type!){
            let modelClass = clsName as! SCHModel.Type
            //是SCHModel的子类
            let valueAry = json
            var itemDatas:Array<Any> = []
            for subItem in valueAry{
                let itemInstance = modelClass.init(json:subItem as AnyObject)
                itemDatas.append(itemInstance)
            }
            self.setValue(itemDatas, forKey: name)
            return
        }
        
        self.setValue(json, forKey: name)
    }
    
    //解析字典
    func parseDicData(json:Dictionary<String,Any>){
        if json.count == 0{
//            return
        }
        let mapdic = self.setMapperDic()
        
        for (name, type) in propertyAry {
            //获取json中的key值
            var realKey = name
            if let key:String = mapdic[name]{
                realKey = key
            }
            
            let value = json[realKey]
            
            //如果没有值 进行下一个属性赋值
            if value == nil {
                continue
            }

            
            //1.==========判断是否是数组 且数组中存储的是什么==========
            //Array<SubItem>
            if self.judgeIsArray(aryTitle: type){
                //如果是数组
                let info = self.getAryClassNameAndItem(aryTitle: type)
                if let aryType = info.1{
                    //判断是否是SCHModel的子类
                    if let clsName = self.judgeIsSubClassofSCHmodel(cls: aryType){
                        let modelClass = clsName as! SCHModel.Type
                        //是SCHModel的子类
                        let valueAry = value as! Array<Any>
                        var itemDatas:Array<Any> = []
                        for subItem in valueAry{
                            let itemInstance = modelClass.init(json:subItem as AnyObject)
                            itemDatas.append(itemInstance)
                        }
                        self.setValue(itemDatas, forKey: name)
                        continue
                    }
                }
            }
            //2.=========判断是否是schmodel的子类==========
            if let clsName = self.judgeIsSubClassofSCHmodel(cls: type){
                let modelClass = clsName as! SCHModel.Type
                let itemInstance = modelClass.init(json: value as AnyObject)
                self.setValue(itemInstance, forKey: name)
                continue
            }
            
            
            //3.==========其他情况==========
            self.setValue(value, forKey: name)
            continue
        }
    }
    
    
    //MARK: 获取所有属性类型和名称
    func getAllProperty(){
        let mirror = Mirror.init(reflecting: self)
        for child in mirror.children {
            if let property = child.label{
                let proMirror = Mirror.init(reflecting: child.value)
                let name = property
                let type = self.getTypeFromOption(optStr: String.init(describing: proMirror.subjectType))
                propertyAry.append((name, type))
            }
        }
    }
    
    func getTypeFromOption(optStr:String) -> String{
        // optStr exp : Optional<String>
        if !optStr.hasPrefix("Optional") {
            return optStr
        }else{
            let length = optStr.count
            let  range = NSMakeRange(9, length - 10)
            let str =  (optStr as NSString).substring(with:range)
            return str
        }
    }
    
    //获取数组名称和数组中存储的类型
    func getAryClassNameAndItem(aryTitle:String) -> (String,String?){
        let scanner:Scanner = Scanner.init(string: aryTitle)
        var aryStr:NSString?
        var itemStr:NSString?
        if scanner.scanUpTo("<", into: &aryStr){
            scanner.scanString("<", into: nil)
            scanner.scanUpTo(">", into: &itemStr)
        }else{
            aryStr = aryTitle as NSString
        }
        
        return (aryStr! as String,itemStr as String?)
    }
    
    //判断是否是SCHmodel的子类
    func judgeIsSubClassofSCHmodel(cls:String) -> NSObject.Type?{
        //获取包名
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let clstr = namespace + "." + cls
        if let clsName = NSClassFromString(clstr) as? NSObject.Type{
            if clsName.init().isKind(of: SCHModel.classForCoder()){
                return clsName
            }
        }
        
        return nil
    }
    
    
    //判断是否是数组
    func judgeIsArray(aryTitle:String)->Bool{
        return aryTitle.hasPrefix("Array")
    }
    
    //MARK: 映射字典
    //should override
    func setMapperDic()->Dictionary<String,String>{
        return [:]
    }
    
    
    //MARK: =================NET WORK=========================
    
    typealias cmpBlock = (Bool)->Void
    
    func POST(urlstr:String, parameters:[String:Any]?,cmp:@escaping cmpBlock){
        self.NetWork(method: "POST", urlstr: urlstr, parameters: parameters, cmp: cmp)
    }
    func GET(urlstr:String, parameters:[String:Any]?,cmp:@escaping cmpBlock){
        self.NetWork(method: "GET", urlstr: urlstr, parameters: parameters, cmp: cmp)
    }
    
    
    private func NetWork(method:String, urlstr:String, parameters:[String:Any]?,cmp:@escaping cmpBlock){
        let url = URL.init(string: urlstr)
        var request = URLRequest.init(url: url!)
        request.httpMethod = method
        
        let task = URLSession.shared.dataTask(with: request) { (data, respon, error) in
            do{
                let dic = try JSONSerialization.jsonObject(with: data!, options:
                    JSONSerialization.ReadingOptions.allowFragments)
                //======print======
                print(dic)
                
                self.parseData(json: dic as AnyObject)
            }catch{
                
            }
            cmp(error == nil)
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
    
}
