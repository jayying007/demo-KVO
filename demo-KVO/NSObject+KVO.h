//
//  NSObject+KVO.h
//  demo-KVO
//
//  Created by jieying zhuang on 2021/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)
- (void)m_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object newValue:(id)newValue;

- (void)m_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)m_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)m_willChangeValueForKey:(NSString *)key;
- (void)m_didChangeValueForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
