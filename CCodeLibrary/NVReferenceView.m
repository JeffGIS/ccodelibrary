//  NVReferenceView.m
//  CCodeLibrary

#import "NVReferenceView.h"
#import "UserDefaults.h"
#import "DriverDefinitions.h"

@implementation NVReferenceView

+ (void)showReference:(NSString *)reference
               inView:(UIView *)view
{
    for (UIView *subviews in view.subviews)
    {
        if ([subviews isKindOfClass:NVReferenceView.class])
        {
            NSLog(@"NVReferenceView ERROR:Cannot present reference view when one already exists in superview");
            return;
        }
    }
    
    CGFloat margin = 20.0;
    NVReferenceView *nvrv = NVReferenceView.new;
    nvrv.translatesAutoresizingMaskIntoConstraints = NO;
    nvrv.backgroundColor = UserDefaults.defaults.appleBlue;
    [view addSubview:nvrv];
    [nvrv constrainToView:view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    returnButton.backgroundColor = UIColor.clearColor;
    [returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    [nvrv addSubview:returnButton];
    [returnButton constrainLeadingToAnchor:nvrv.leadingAnchor constant:margin];
    [returnButton constrainTopToAnchor:nvrv.topAnchor constant:margin];
    
    [returnButton addTarget:nvrv
                     action:@selector(returnButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIView *containerView = UIView.new;
    containerView.frame = CGRectMake(20.0, 148.0, 728.0, 728.0);
    containerView.backgroundColor = UIColor.clearColor;
    [nvrv addSubview:containerView];
    
    DriverDefinitions *dd = DriverDefinitions.new;
    PDFPARM parms = {0};
    DPOINT ul = {0}, lr = {0};
    
    if ([dd getPDFParamters:reference
                       parm:&parms
                defaultType:@"ITEM"])
    {
        ul.x = parms.ULX;
        ul.y = parms.ULY;
        lr.x = parms.LRX;
        lr.y = parms.LRY;
        
        NVPDFDrawing *drawing = [NVPDFDrawing drawingWithID:reference
                                                       name:[NSString stringWithUTF8String:parms.NAME]
                                                       type:@"ITEM"
                                                       page:parms.PAGE
                                                  upperLeft:ul lowerRight:lr];
        
        [NVWebView showPDFDrawing:drawing
                     fromDocument:NVPDFDocumentMNAccessbility
                           inView:containerView
                   withHighlights:@""
                      enableSwipe:NO];
    }
    
    else
    {
        [nvrv removeFromSuperview];
        showAlert([NSString stringWithFormat:@"Reference with ID '%@' does not exist.", reference]);
    }
}

- (void)returnButtonTapped
{
    [self removeFromSuperview];
}

@end
