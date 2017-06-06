//  NVContactGroupData.h
//  CCodeLibrary

@interface NVContact : NSObject

@property (nonatomic, copy) NSString *email, *firstName, *lastName;

@end

@interface NVContactGroupData : NSObject

- (void)addEmail:(NSString *)email
       firstName:(NSString *)firstName
        lastName:(NSString *)lastName
  toContactGroup:(NSString *)contactGroup;

- (void)removeEmail:(NSString *)email
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
   fromContactGroup:(NSString *)contactGroup;

- (void)removeContactGroup:(NSString *)contactGroup;
- (NSArray *)getContactGroupsArray;
- (NSArray<NVContact *> *)getContactsArray;
- (NSArray<NVContact *> *)getContactsArrayInContactGroup:(NSString *)contactGroup;

@end
