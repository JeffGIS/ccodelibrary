//  NVContactGroupData.h
//  CCodeLibrary

@interface NVContact : NSObject

@property (nonatomic, copy) NSString *email, *firstName, *lastName;

@end

@interface NVContactGroupData : NSObject

- (void)addContactEmail:(NSString *)email
              firstName:(NSString *)firstName
               lastName:(NSString *)lastName;

- (void)addEmail:(NSString *)email
  toContactGroup:(NSString *)contactGroup;

- (NSArray *)getContactGroupsArray;
- (NSArray<NVContact *> *)getContactsArray;
- (NSArray<NVContact *> *)getContactsArrayInContactGroup:(NSString *)contactGroup;

@end
