//
//  Person.m
//  demo-KVO
//
//  Created by jieying zhuang on 2021/6/28.
//

#import "Person.h"

@implementation Person
- (void)m_willChangeValueForKey:(NSString *)key {
    NSLog(@"%s 方法开始", __func__);
    [super m_willChangeValueForKey:key];
    NSLog(@"%s 方法结束", __func__);
}

- (void)m_didChangeValueForKey:(NSString *)key {
    NSLog(@"%s 方法开始", __func__);
    [super m_didChangeValueForKey:key];
    NSLog(@"%s 方法结束", __func__);
}
@end
