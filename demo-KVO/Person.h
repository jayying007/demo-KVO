//
//  Person.h
//  demo-KVO
//
//  Created by jieying zhuang on 2021/6/28.
//

#import <Foundation/Foundation.h>
#import "NSObject+KVO.h"
NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
@property (nonatomic, strong) NSString *name;
@end

NS_ASSUME_NONNULL_END
