//  CustomRampTypeBuilder.m
//  CCodeLibrary

#import "CustomRampTypeBuilder.h"
#import "DPoint.h"
#import "NVAlertView.h"
#import "UserDefaults.h"

@implementation CustomRampElement

- (NSString *)description
{
    return [NSString stringWithFormat:@"<CustomRampElement: %p> "
            "Type: %d, Position: (%f,%f)",
            self, _type, _position.x, _position.y];
}

@end

@implementation CustomRampType

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n<CustomRampType: %p>"
            "\n\tPhoto: %@,\n\tElements: %@",
            self, _photo, _elements];
}

@end

@interface CustomRampTypeBuilder () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIButton *returnButton, *photoButton;
@property (nonatomic) UIImageView *photoView;
@property (nonatomic) UIImagePickerController *picker;
@property (nonatomic) UIView *elementsView;
@property (nonatomic) UILabel *ramps, *flares, *landings, *sdwks;
@property CGFloat buttonSize;
@property CGPoint originalPosition;
@property (nonatomic, copy) NSString *photo;

@end

@implementation CustomRampTypeBuilder

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    _buttonSize = 60.0;
    _originalPosition = CGPointZero;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [NVAlertView showLargeAlertViewinView:self.view
                                     delegate:self
                                        title:@"No camera available on device."
                              buttonTextArray:@[@"OK"]
                             destructiveIndex:0];
        return;
    }
    
    CGFloat margin = 20.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_returnButton constrainTopToAnchor:self.view.topAnchor constant:(margin * 0.5)];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _photoButton.translatesAutoresizingMaskIntoConstraints = NO;
    _photoButton.backgroundColor = UIColor.clearColor;
    [_photoButton setTitle:@"Retake Photo" forState:UIControlStateNormal];
    [_photoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_photoButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _photoButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    [self.view addSubview:_photoButton];
    [_photoButton constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_photoButton constrainTopToAnchor:_returnButton.topAnchor];
    
    [_photoButton addTarget:self
                      action:@selector(photoButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _photoView = UIImageView.new;
    _photoView.userInteractionEnabled = YES;
    _photoView.translatesAutoresizingMaskIntoConstraints = NO;
    _photoView.clipsToBounds = YES;
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_photoView];
    [_photoView constrainTopToAnchor:_returnButton.bottomAnchor constant:(margin * 0.5)];
    [_photoView constrainLeadingToAnchor:self.view.leadingAnchor];
    [_photoView constrainTrailingToAnchor:self.view.trailingAnchor];
    [_photoView constrainHeightToAnchor:_photoView.widthAnchor];
    
    _picker = UIImagePickerController.new;
    _picker.delegate = self;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _picker.showsCameraControls = YES;
    _picker.allowsEditing = NO;
    _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    _picker.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    _elementsView = UIView.new;
    _elementsView.backgroundColor = UIColor.clearColor;
    _elementsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_elementsView];
    [_elementsView constrainTopToAnchor:_photoView.bottomAnchor constant:margin];
    [_elementsView constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_elementsView constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_elementsView constrainBottomToAnchor:self.view.bottomAnchor constant:-margin];
    
    _ramps = UILabel.new;
    [self setupLabel:_ramps];
    _ramps.tag = RampElementTypeRamp;
    _ramps.backgroundColor = UIColor.redColor;
    _ramps.text = @"Ramp";
    [_ramps constrainLeadingToAnchor:_elementsView.leadingAnchor];
    [_ramps constrainTopToAnchor:_elementsView.topAnchor];
    [_ramps constrainHeightToConstant:_buttonSize];
    [_ramps constrainWidthToConstant:(_buttonSize * 1.5)];
    
    _flares = UILabel.new;
    [self setupLabel:_flares];
    _flares.tag = RampElementTypeFlare;
    _flares.backgroundColor = UIColor.orangeColor;
    _flares.text = @"Flare";
    [_flares constrainLeadingToAnchor:_ramps.trailingAnchor constant:margin];
    [_flares constrainTopToAnchor:_elementsView.topAnchor];
    [_flares constrainHeightToConstant:_buttonSize];
    [_flares constrainWidthToConstant:(_buttonSize * 1.5)];
    
    _landings = UILabel.new;
    [self setupLabel:_landings];
    _landings.tag = RampElementTypeLanding;
    _landings.backgroundColor = UserDefaults.defaults.darkGreen;
    _landings.text = @"Lndg";
    [_landings constrainLeadingToAnchor:_flares.trailingAnchor constant:margin];
    [_landings constrainTopToAnchor:_elementsView.topAnchor];
    [_landings constrainHeightToConstant:_buttonSize];
    [_landings constrainWidthToConstant:(_buttonSize * 1.5)];
    
    _sdwks = UILabel.new;
    [self setupLabel:_sdwks];
    _sdwks.tag = RampElementTypeSdwk;
    _sdwks.backgroundColor = UIColor.grayColor;
    _sdwks.text = @"Sdwk";
    [_sdwks constrainLeadingToAnchor:_landings.trailingAnchor constant:margin];
    [_sdwks constrainTopToAnchor:_elementsView.topAnchor];
    [_sdwks constrainHeightToConstant:_buttonSize];
    [_sdwks constrainWidthToConstant:(_buttonSize * 1.5)];
    
    [self presentPhotoInterface];
}

- (void)setupLabel:(UILabel *)label
{
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:24.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = (_buttonSize * 0.5);
    label.layer.borderColor = UIColor.blackColor.CGColor;
    label.layer.borderWidth = 4.0;
    label.textColor = UIColor.whiteColor;
    [_elementsView addSubview:label];
    [self addPanGR:label];
}

- (void)addPanGR:(UILabel *)label
{
    UIPanGestureRecognizer *pan = UIPanGestureRecognizer.new;
    [pan addTarget:self action:@selector(labelDragged:)];
    [label addGestureRecognizer:pan];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)presentPhotoInterface
{
    _photoButton.hidden = YES;
    
    for (UILabel *labels in _elementsView.subviews)
        labels.hidden = YES;
    
    [self.view addSubview:_picker.view];
    [_picker.view constrainToView:_photoView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    [self addChildViewController:_picker];
    [_picker didMoveToParentViewController:self];
}

- (void)dismissPhotoInterface
{
    [_picker.view removeFromSuperview];
    [_picker removeFromParentViewController];
    _photoButton.hidden = NO;
    
    for (UILabel *labels in _elementsView.subviews)
        labels.hidden = NO;
}

- (void)returnButtonTapped
{
    CustomRampType *ramp = CustomRampType.new;
    NSMutableArray<CustomRampElement *> *elements = NSMutableArray.array;
    CGFloat width = _photoView.frame.size.width;
    CGFloat height = _photoView.frame.size.height;
    
    for (UILabel *label in _photoView.subviews)
    {
        if ([label isKindOfClass:UILabel.class])
        {
            DPOINT position = {0};
            position.x = (label.center.x / width);
            position.y = (label.center.y / height);
            CustomRampElement *element = CustomRampElement.new;
            element.position = position;
            element.type = label.tag;
            [elements addObject:element];
        }
    }
    
    ramp.photo = _photo;
    ramp.elements = elements.copy;
    
    NSLog(@"%@", ramp);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoButtonTapped
{
    [self presentPhotoInterface];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissPhotoInterface];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _photoView.image = image;
    [self dismissPhotoInterface];
    UIImage *output = [_photoView imageOfFrame:_photoView.bounds];
    _photoView.image = output;
}

- (void)labelDragged:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    CGFloat xPos = (gesture.view.center.x + translation.x);
    CGFloat yPos = (gesture.view.center.y + translation.y);
    
    if (gesture.view.superview == _photoView)
    {
        CGFloat width = (gesture.view.frame.size.width * 0.5);
        CGFloat height = (gesture.view.frame.size.height * 0.5);
        xPos = max(xPos, width);
        xPos = min(xPos, (_photoView.frame.size.width - width));
        yPos = max(yPos, height);
        yPos = min(yPos, (_photoView.frame.size.height - height));
    }
    
    gesture.view.center = CGPointMake(xPos, yPos);
    [gesture setTranslation:CGPointZero inView:gesture.view.superview];
    
    if (gesture.view.superview == _elementsView)
    {
        switch (gesture.state)
        {
            case UIGestureRecognizerStateBegan:
                _originalPosition = gesture.view.center;
                [gesture.view.superview bringSubviewToFront:gesture.view];
                break;
            case UIGestureRecognizerStateEnded:{
                CGRect frame = [_elementsView convertRect:gesture.view.frame
                                                   toView:_photoView];
                
                frame.origin.y += _photoView.frame.origin.y;
                
                if (CGRectContainsRect(_photoView.frame, frame))
                {
                    UILabel *label = (UILabel *)gesture.view;
                    
                    CGPoint center = [label.superview convertPoint:label.center
                                                            toView:_photoView];
                    
                    UILabel *newLabel = UILabel.new;
                    newLabel.frame = label.frame;
                    newLabel.tag = label.tag;
                    newLabel.userInteractionEnabled = label.userInteractionEnabled;
                    newLabel.textAlignment = label.textAlignment;
                    newLabel.backgroundColor = label.backgroundColor;
                    newLabel.layer.cornerRadius = label.layer.cornerRadius;
                    newLabel.layer.borderColor = label.layer.borderColor;
                    newLabel.layer.borderWidth = label.layer.borderWidth;
                    newLabel.layer.masksToBounds = label.layer.masksToBounds;
                    newLabel.font = label.font;
                    newLabel.text = label.text;
                    newLabel.textColor = label.textColor;
                    newLabel.center = center;
                    [_photoView addSubview:newLabel];
                    [self addPanGR:newLabel];
                }
                
                gesture.view.center = _originalPosition;
                break;}
            default:break;
        }
    }
}

@end
