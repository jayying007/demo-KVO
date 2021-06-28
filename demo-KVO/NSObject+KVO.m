//
//  NSObject+KVO.m
//  demo-KVO
//
//  Created by jieying zhuang on 2021/6/28.
//

#import "NSObject+KVO.h"
#import <objc/message.h>

#define KVO_PREFIX @"KVO_"

static void *KVOAssiociateKey = &KVOAssiociateKey;


//从get方法获取set方法的名称 name ===>>> setName:
static NSString * genSetterFromGetter(NSString *getter){
    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];
    
    return [NSString stringWithFormat:@"set%@%@:",firstString,leaveString];
}

//从set方法获取getter方法的名称 setName:===> name
static NSString * genGetterFromSetter(NSString *setter){
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    
    return getter;
}

//重写子类的class方法
static Class m_Class(id self, SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}

//重写子类的Setter方法
static void m_setter(id self, SEL _cmd, id value){
    NSString *keypath = genGetterFromSetter(NSStringFromSelector(_cmd));
    //将要改变属性的值
    [self m_willChangeValueForKey:keypath];
    //调用父类 setter 方法 设置新值
    struct objc_super super_cls = {
            .receiver = self,
            .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*msgDispatcher)(struct objc_super*, SEL, id) = (void(*)(struct objc_super*, SEL, id))objc_msgSendSuper;
    msgDispatcher(&super_cls, _cmd, value);
    //改变监听属性值后 调用 didChangeValueForKey 并在内部 调用
    [self m_didChangeValueForKey:keypath];
}


@implementation NSObject (KVO)

- (void)m_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    // 1: 是否有setter方法
    NSString *setterMethodName = genSetterFromGetter(keyPath);
    SEL setterSel = NSSelectorFromString(setterMethodName);
    // method
    Method method = class_getInstanceMethod([self class], setterSel);
    if (!method) {
        @throw [[NSException alloc] initWithName:NSExtensionItemAttachmentsKey reason:@"没有setter方法" userInfo:nil];
    }
    //2: 动态生成子类
    Class childClass = [self createChildClassWithKeypath:keyPath];
    if (!childClass) {
        NSLog(@"创建失败");
    }
    // 3.0 消息转发
    // observer
    // 关联对象
    objc_setAssociatedObject(self, KVOAssiociateKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)m_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    //如果observer没有监控哪一个keyPath，则object变回其父类
    object_setClass(self, [self class]);
}

- (Class)createChildClassWithKeypath:(NSString *)keyPath{
    //1. 类名
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *childClassName = [NSString stringWithFormat:@"%@%@", KVO_PREFIX, oldClassName];
    //2: 动态生成子类
    //2.1 申请类
    Class childClass = objc_allocateClassPair([self class], childClassName.UTF8String, 0);
    //2.2 注册类
    objc_registerClassPair(childClass);
    //2.3 添class
    SEL classSel = NSSelectorFromString(@"class");
    Method classMethod = class_getClassMethod([self class], classSel);
    const char *classType = method_getTypeEncoding(classMethod);
    class_addMethod(childClass, classSel, (IMP)m_Class, classType);
    //2.4 setter : setName:
    SEL setterSel = NSSelectorFromString(genSetterFromGetter(keyPath));
    Method setterMethod = class_getClassMethod([self class], setterSel);
    const char *setterType = method_getTypeEncoding(setterMethod);
    class_addMethod(childClass, setterSel, (IMP)m_setter, setterType);
    //2.5 isa 指向
    object_setClass(self, childClass);
    return childClass;
}

- (void)m_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object newValue:(id)newValue {
    NSLog(@"%s", __func__);
}


- (void)m_willChangeValueForKey:(NSString *)key {
    NSLog(@"%s", __func__);
}

- (void)m_didChangeValueForKey:(NSString *)key {
    NSLog(@"%s", __func__);
    id observer = objc_getAssociatedObject(self, KVOAssiociateKey);
    SEL handleSEL = @selector(m_observeValueForKeyPath:ofObject:newValue:);
    id value = [self valueForKey:key];
    
    void (*msgDispatcher)(id, SEL, NSString *, id, id) = (void(*)(id, SEL, NSString *, id, id))objc_msgSend;
    msgDispatcher(observer, handleSEL, key, self, value);
}
@end
