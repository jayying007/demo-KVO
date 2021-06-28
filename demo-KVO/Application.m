//
//  Application.m
//  demo-KVO
//
//  Created by jieying zhuang on 2021/6/29.
//

#import "Application.h"
#import "NSObject+KVO.h"
#import "Person.h"
#import <objc/runtime.h>

@implementation Application
- (void)run {
    Person *person = [[Person alloc] init];
    [person m_addObserver:self forKeyPath:@"name"];
    person.name = @"Jane";
    NSLog(@"调用class获取类名：%@", [person class]);
    NSLog(@"获取真实类名：%@", object_getClass(person));
    [person m_removeObserver:self forKeyPath:@"name"];
    NSLog(@"获取真实类名：%@", object_getClass(person));
    person.name = @"Jayying";
}

- (void)m_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object newValue:(id)newValue {
    NSLog(@"监听到发生变化，触发回调方法!!!");
    NSLog(@"keyPath: %@", keyPath);
    NSLog(@"object: %@", object);
    NSLog(@"newValue: %@", newValue);
}
@end
