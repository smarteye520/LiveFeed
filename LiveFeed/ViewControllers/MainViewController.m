//
//  MainViewController.m
//  LiveFeed
//
//  Created by echoLive on 11/20/20.
//  Copyright © 2020 Smart Eye. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FVVerticalSlideView.h"
#import "GStreamerBackendDelegate.h"
#import "GStreamerBackend.h"

@interface MainViewController ()<FVVerticalSliderViewDelegate, UITextFieldDelegate, GStreamerBackendDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfURL;
@property (weak, nonatomic) IBOutlet UIButton *btnChannel1;
@property (weak, nonatomic) IBOutlet UIButton *btnChannel2;
@property (weak, nonatomic) IBOutlet UIView *uvChannel1;
@property (weak, nonatomic) IBOutlet UIView *uvChannel2;

@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;
@property (weak, nonatomic) IBOutlet UIButton *btnError;
@property (weak, nonatomic) IBOutlet UILabel *lblStreamStatus;

@property (nonatomic, assign) NSInteger iChannel;
@property (nonatomic, assign) NSString *strURL;
@property (nonatomic, assign) NSString *strStatus;

@end

@implementation MainViewController{
    FVVerticalSlideView *sliderC1;
    FVVerticalSlideView *sliderC2;
    GStreamerBackend *gst_backend;
}

@synthesize tfURL, btnChannel1, btnChannel2, lblStreamStatus, uvChannel1, uvChannel2, btnPlay, btnPause, btnError;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.strURL = @"rtsp://nzas1.livefeed.co.nz:554/test";
    tfURL.delegate = self;
    [tfURL setText:_strURL];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Type your rtsp address" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    self.tfURL.attributedPlaceholder = str;
    
    gst_backend = [[GStreamerBackend alloc] init:self url:_strURL];
    
    [self initialView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setVolumeSliders];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (gst_backend){
        [gst_backend deinit];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBOutlets

- (IBAction)onClickChannel1Button:(id)sender {
    _iChannel = 0;
    [self setChannelButtons];
}

- (IBAction)onClickChannel2Button:(id)sender {
    _iChannel = 1;
    [self setChannelButtons];
}

- (IBAction)onClickPlay:(id)sender {
    [gst_backend play];
}

- (IBAction)onClickPause:(id)sender {
    [gst_backend pause];
}

- (IBAction)onClickError:(id)sender {
}

- (void)initialView {
    
    btnChannel1.layer.cornerRadius = 17.5;
    btnChannel1.clipsToBounds = YES;
    btnChannel1.backgroundColor = UIColor.blackColor;
    btnChannel1.layer.borderWidth = 0.6f;
    btnChannel1.layer.borderColor = [UIColor whiteColor].CGColor;
    
    btnChannel2.layer.cornerRadius = 17.5;
    btnChannel2.clipsToBounds = YES;
    btnChannel2.backgroundColor = UIColor.blackColor;
    btnChannel2.layer.borderWidth = 0.6f;
    btnChannel2.layer.borderColor = [UIColor whiteColor].CGColor;
    _iChannel = 0;
    [self setChannelButtons];
    
    btnPlay.enabled = FALSE;
    btnPause.enabled = FALSE;
    btnError.enabled = FALSE;
    
    self.strStatus = @"Please type your rtsp address.";
    [self setStreamStatus];
}

- (void)setChannelButtons {
    [tfURL resignFirstResponder];
    if (_iChannel == 0) {
        [btnChannel1 setBackgroundImage:[UIImage imageNamed:@"grad_rectangle"] forState:UIControlStateNormal];
        [btnChannel2 setBackgroundImage:nil forState:UIControlStateNormal];
    }else {
        [btnChannel1 setBackgroundImage:nil forState:UIControlStateNormal];
        [btnChannel2 setBackgroundImage:[UIImage imageNamed:@"grad_rectangle"] forState:UIControlStateNormal];
    }
}

- (void)setVolumeSliders {
    CGFloat top = 20;
    CGFloat bottom = (uvChannel1.frame.size.height - 20) * 0.1;
    
    sliderC1 = [[FVVerticalSlideView alloc] initWithTop:top bottom:bottom translationView:uvChannel1];
    [sliderC1 setBackgroundColor:[UIColor colorNamed:@"CBlueColor"]];
    [sliderC1 setTopY:top];
    sliderC1.delegate = self;
    [uvChannel1 addSubview:sliderC1];
    uvChannel1.layer.cornerRadius = 5.0f;

    sliderC2 = [[FVVerticalSlideView alloc] initWithTop:top bottom:bottom translationView:uvChannel2];
    [sliderC2 setBackgroundColor:[UIColor colorNamed:@"CGreenColor"]];
    [sliderC2 setTopY:top];
    sliderC2.delegate = self;
    [uvChannel2 addSubview:sliderC2];
    uvChannel2.layer.cornerRadius = 5.0f;
}

- (void)setStreamStatus {
    if ([_strStatus isEqualToString:@"PLAYING"] || [_strStatus isEqualToString:@"PAUSED"] || [_strStatus isEqualToString:@"Ready"] ) {
        [lblStreamStatus setText:[NSString stringWithFormat:@"Stream is %@", _strStatus]];
    } else {
        [lblStreamStatus setText:[NSString stringWithFormat:@"%@", _strStatus]];
    }
}

#pragma mark - UItextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSLog(@"%@", textField.text);
    _strURL = [NSString stringWithFormat:@"%@", textField.text];
    [gst_backend setUri:_strURL];
    
//    if (gst_backend){
//        [gst_backend deinit];
//        gst_backend = nil;
//        gst_backend = [[GStreamerBackend alloc] init:self url:_strURL];
//    } else {
//        gst_backend = [[GStreamerBackend alloc] init:self url:_strURL];
//    }
        
    btnPlay.enabled = TRUE;
    btnPause.enabled = TRUE;
    
    return NO;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor lightGrayColor] setFill];
}

#pragma mark - FVVerticalSliderViewDelegate

-(void) startMovingSliderView
{
    NSLog(@"Start Slider");
}

-(void) movingSliderView:(float)calculatedPosition
{
    NSLog(@"calculatedPosition %f",calculatedPosition);
}

-(void) stopMovingSliderView:(float)calculatedPosition
{
    NSLog(@"Current Slider Value is %f",calculatedPosition);
}

-(void) closeTopPositionSliderView:(float)calculatedPosition
{
    NSLog(@"calculatedPosition %f",calculatedPosition);
}

-(void) closeBottomPositionSliderView:(float)calculatedPosition
{
    NSLog(@"closeBottomPositionSliderView %f",calculatedPosition);
}

#pragma mark - GstreamerBackendDelegate

-(void) gstreamerInitialized
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.btnPlay.enabled = TRUE;
        self.btnPause.enabled = TRUE;
        
        self.strStatus = @"Ready";
        [self setStreamStatus];
    });
}

-(void) gstreamerSetUIMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.strStatus = message;
        [self setStreamStatus];
    });
}

@end
