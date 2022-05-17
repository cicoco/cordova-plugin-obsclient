//
//
//  Created by 顾九 on 2020/5/11.
//


@interface HWCredential : NSObject {}
    @property (nonatomic, strong) NSString* ak;
    @property (nonatomic, strong) NSString* sk;
    @property (nonatomic, strong) NSString* endpoint;
    @property (nonatomic, strong) NSString* bucket;
    @property (nonatomic, strong) NSString* prefix;
    @property (nonatomic, strong) NSString* token;
@end
