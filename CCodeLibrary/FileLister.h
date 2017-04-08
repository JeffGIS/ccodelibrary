//  FileLister.h
//  CCodeLibrary

@import Foundation;
@import MessageUI;

@interface FileLister : NSObject

+ (NSInteger)listFilesInDirectory:(NSString *)inPath
                         outputTo:(NSString *)outFile
                        totalSize:(NSInteger*)pTotSize;

@end
