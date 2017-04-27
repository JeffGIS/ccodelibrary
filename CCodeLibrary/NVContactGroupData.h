//  NVContactGroupData.h
//  CCodeLibrary

@interface NVContact : NSObject

@property (nonatomic, copy) NSString *email, *firstName, *lastName;

@end

@interface NVContactGroupData : NSObject

- (void)addContactEmail:(NSString *)email
              firstName:(NSString *)firstName
               lastName:(NSString *)lastName;

- (NSArray<NVContact *> *)getContactsArray;

@end
