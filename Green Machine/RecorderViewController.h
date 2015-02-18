//
//  ViewController.h
//  Green Machine
//
//  Created by Eyal Shpits on 5/29/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data.h"
#import "RosyWriter/RosyWriterViewController.h"
#import "BuyCreditsViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface RecorderViewController : UIViewController <UIAlertViewDelegate,UIScrollViewDelegate> {
    MPMoviePlayerController * moviePlayer;
    
    RosyWriterViewController * writerView;
    BuyCreditsViewController * controllerBuyCredit;
    
    NSMutableArray * movies;
    NSInteger selectedMovie;
    
    IBOutlet UIButton * buttonToggleMenu;
    
    IBOutlet UIButton * buttonRecord;
    IBOutlet UIButton * buttonReady;
    IBOutlet UIImageView * imageViewBackground;
    IBOutlet UIView * viewInstructionsPortraight;
    IBOutlet UIView * viewInstructionsLandscape;
    IBOutlet UIView * viewLocked;
    IBOutlet UIView * secondsView;
    IBOutlet UIView * previewView;
    IBOutlet UILabel * labelSeconds;
    
    IBOutlet UIView * bgBuyCredit;
    
    IBOutlet UIButton * buttonBuyCredit;
    IBOutlet UIButton * buttonToggleCamera;
    
    IBOutlet UILabel * labelBackgroundCost;
    IBOutlet UIView * viewLock;
    IBOutlet UIView * viewDone;
    
    IBOutlet UIScrollView * scrollerMovies;
    
    Data * data;
    NSInteger bgNameIndex;
    bool   menuIsOpened;
    
    UIAlertView * alertLockedBackground;
    UIAlertView * alertUseCredits;
    UIAlertView * alertBuyCredits;
    
    UIButton * cancelRecordingButton;
}

-(IBAction)leftPressed:(id)sender;
-(IBAction)rightPressed:(id)sender;
-(IBAction)upPressed:(id)sender;

-(IBAction)closeInstructionsPressed:(id)sender;
-(IBAction)menuTogglePressed:(id)sender;

-(IBAction) buycreditPressed:(id)sender;

-(IBAction)buyBackgroundPressed:(id)sender;

-(IBAction)readyPressed:(id)sender;
-(IBAction)beginRecordPressed:(id)sender;
-(IBAction)toggleCameraPressed:(id)sender;
-(IBAction)helpPressed:(id)sender;
-(IBAction)appReferelPressed:(id)sender;


-(IBAction) createMoviePressed:(id)sender;
-(IBAction) retakeMoviePressed:(id)sender;
@end
