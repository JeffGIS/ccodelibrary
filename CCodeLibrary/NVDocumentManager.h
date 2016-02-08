//  NVDocumentManager.h
//  CCodeLibrary

@import UIKit;

@class NVTileCompiler;

@protocol NVDocumentManagerDelegate <NSObject>

@optional
- (void)documentManagerDidComplete;
- (void)documentManagerWasCancelled;

@end

@interface NVDocumentManager : NSObject

@property (nonatomic, weak) id <NVDocumentManagerDelegate> delegate;

- (void)exportDocumentFromFilepath:(NSString *)filepath
                          delegate:(id)delegate;

@end