//

//  ViewController.m
//  Green Machine
//
//  Created by Eyal Shpits on 5/29/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "RecorderViewController.h"
#import "DataBackground.h"


@interface RecorderViewController ()

@end

@implementation RecorderViewController


-(void) doneRecording {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"doneRecording" object:nil];
     [UIView animateWithDuration:0.5 animations:^{
        labelSeconds.text = @"";
        imageViewBackground.alpha = 1.0;
        buttonRecord.alpha = 1.0;
        buttonReady.alpha = 1.0;
    }];
}
-(IBAction)readyPressed:(UIButton *)sender {
    DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
    if ( background.isLocked.boolValue ) {
        [alertLockedBackground show];
        return;
    }

    // Hide siluevte
//    [self.view bringSubviewToFront:writerView.view];
    imageViewBackground.alpha = 0.0;
    writerView.seconds = [NSNumber numberWithInt:10];
    writerView.secondsLabel = labelSeconds;
    [writerView initGreenMachine];
    sender.alpha = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneRecording) name:@"doneRecording" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    useFrontCamera = true;
    controllerBuyCredit = [[BuyCreditsViewController alloc]initWithNibName:@"BuyCreditsViewController" bundle:nil];


    self.navigationController.navigationBarHidden = true;
    data = [Data shared];
    [buttonBuyCredit setTitle:[NSString stringWithFormat:@"%@", data.credits] forState:UIControlStateNormal];
    bgNameIndex = 1;
    menuIsOpened = false;
    [self updateBackgroundImage];

    alertUseCredits = [[UIAlertView alloc]initWithTitle:@"Using credits" message:@"You may purchase this background using your existing credits" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Use Credits", nil];
    alertBuyCredits = [[UIAlertView alloc]initWithTitle:@"Purchase credits" message:@"You need to get more credits" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Get Credits", nil];

    alertLockedBackground = [[UIAlertView alloc]initWithTitle:@"Locked background" message:@"This background is still locked. would you like to get it?" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Get it", nil];
    
    viewInstructionsPortraight.alpha = viewInstructionsLandscape.alpha = 0.0;
    
    NSString * skippedFirstTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"skippedFirstTime"];
    if ( !skippedFirstTime ) {
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"skippedFirstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        viewInstructionsLandscape.alpha = 1.0;
        else
        viewInstructionsPortraight.alpha = 1.0;
    }
    
    
    writerView = [[RosyWriterViewController alloc]initWithNibName:@"RosyWriterViewController" bundle:nil];
    writerView.view.frame = [UIScreen mainScreen].bounds;
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        writerView.view.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);

    [self.view insertSubview:writerView.view atIndex:0];

    
    // Hide siluevte
//    [self.view bringSubviewToFront:writerView.view];

    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(orientationChanged:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
//    [self orientationChanged:nil];


}

- (void) updateBackgroundImage {
    DataBackground * background = [data.backgrounds objectAtIndex:data.currentBackground.intValue];
    if ( background.isLocked.boolValue ) {
        [self fadeIn:viewLocked];
        [self fadeIn:viewLock];
    }
    else {
        [self fadeOut:viewLocked];
        [self fadeOut:viewLock];
    }

    NSString * format = [data.formats objectAtIndex:bgNameIndex];
    NSString * name = [NSString stringWithFormat:format, data.currentBackground.intValue+1];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        name = [name stringByReplacingOccurrencesOfString:@"port" withString:@"land"];

        
    imageViewBackground.image = [UIImage imageNamed:name];
    if ( !background.isLocked.boolValue ) {
        labelBackgroundCost.text = [NSString stringWithFormat:@"%@", background.cost];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)leftPressed:(id)sender {
    if ( data.currentBackground.intValue > 0) data.currentBackground = [NSNumber numberWithInt:data.currentBackground.intValue-1];
    else data.currentBackground = [NSNumber numberWithInt:22];
    [self updateBackgroundImage];
}
-(IBAction)rightPressed:(id)sender {
    if ( data.currentBackground.intValue < 22 ) data.currentBackground = [NSNumber numberWithInt:data.currentBackground.intValue+1];
    else data.currentBackground = [NSNumber numberWithInt:0];
    [self updateBackgroundImage];
}

-(IBAction)upPressed:(id)sender {
    if ( bgNameIndex < 4) bgNameIndex++;
    else bgNameIndex = 0;
    [self updateBackgroundImage];

}
-(IBAction)closeInstructionsPressed:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        viewInstructionsLandscape.alpha = 0.0;
        viewInstructionsPortraight.alpha = 0.0;
    } completion:nil];
}


-(void) refreshMovies {
    movies = [[[Data shared] objectForKey:@"movies"] mutableCopy];
    if ( [[scrollerMovies subviews] count] != [movies count] ) {
        for ( UIView * view in [scrollerMovies subviews] ) {
            [view removeFromSuperview];
        }
        
        int x = 10;
        int index=0;
        for ( NSData * dataMovie in movies ) {
            UIImage * image = [UIImage imageWithData:dataMovie];
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            int width = 200;
            int height = (int) ( 200.0 / image.size.width * image.size.height);
            button.frame = CGRectMake(x, 30, width, height);
            
            button.layer.shadowColor = [UIColor whiteColor].CGColor;
            button.layer.shadowOpacity = 0.5;
            button.layer.shadowRadius = 10;
            button.layer.shadowOffset = CGSizeMake(3.0f,3.0f);
            
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 5.0;
            [button setImage:image  forState:UIControlStateNormal];
            [button addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
            [scrollerMovies addSubview:button];
            
            UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(removePressed:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.frame = CGRectMake ( x+width-25, 5, 50, 50 );
            [scrollerMovies addSubview:deleteButton];
            
            x+= ( width  + 20 );
            button.tag = index++;
        }
        scrollerMovies.contentSize = CGSizeMake ( x, scrollerMovies.frame.size.height ) ;
        
    }
}
-(IBAction)menuTogglePressed:(UIButton *)sender {
    CGRect frame = [sender superview].frame;
    if ( menuIsOpened ) {
        [self fadeOut:bgResolutions];
        [self fadeOut:viewLocked];
        menuIsOpened = false;
        [UIView animateWithDuration:0.3 animations:^{
            [sender superview].frame = CGRectMake ( frame.origin.x, frame.origin.y+200, frame.size.width, frame.size.height-200 );
            secondsView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [sender setImage:[UIImage imageNamed:@"menuOpen"] forState:UIControlStateNormal];
        }];
    }
    else {
        menuIsOpened = true;
        
        [self refreshMovies];
        
        [UIView animateWithDuration:0.3 animations:^{
            secondsView.alpha = 0.0;
            [sender superview].frame = CGRectMake ( frame.origin.x, frame.origin.y-200, frame.size.width, frame.size.height+200 );
        } completion:^(BOOL finished) {
            [sender setImage:[UIImage imageNamed:@"menuClose"] forState:UIControlStateNormal];
        }];
    }
}

-(void) fadeOut:(UIView *) view {
    [UIView animateWithDuration:0.1 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        ;
    }];
}
-(void) fadeIn:(UIView *) view {
    [UIView animateWithDuration:0.1 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        ;
    }];
}
-(IBAction) buycreditPressed:(id)sender {
    [self fadeOut:bgResolutions];
    
    [self.view addSubview:controllerBuyCredit.view];
//    [self fadeIn:bgBuyCredit];
}
-(IBAction) upgradePressed:(id)sender {
    [self fadeOut:bgResolutions];
    
    [[[UIAlertView alloc]initWithTitle:@"Upgrade Not implemented yet" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
-(IBAction)resolution360Pressed:(UIButton * )sender {
    sender.selected = !sender.selected;
    [(UIButton *)[bgResolutions viewWithTag:720] setSelected:false];
    data.resolution = [NSNumber numberWithInt:360];
}
-(IBAction)resolution720Pressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [(UIButton *)[bgResolutions viewWithTag:360] setSelected:false];
    data.resolution = [NSNumber numberWithInt:720];
}
-(IBAction) resolutionPressed:(id)sender {
    int resolution = data.resolution.intValue; 
    [(UIButton *)[bgResolutions viewWithTag:resolution] setSelected:true];
    
    [self fadeIn:bgResolutions];
//    [self fadeOut:bgBuyCredit];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) return;
    if ( alertView == alertLockedBackground ) {
        [self buyBackgroundPressed:nil];
    }
    if ( alertView == alertBuyCredits ) {
        [self.view addSubview:controllerBuyCredit.view];
//        [self presentViewController:controller animated:YES completion:nil];
    }
    if ( alertView == alertUseCredits ) {
        DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
        background.isLocked = [NSNumber numberWithBool:false];
        data.credits = [NSNumber numberWithInt:data.credits.intValue - background.cost.intValue];
        [buttonBuyCredit setTitle:[NSString stringWithFormat:@"%@", data.credits] forState:UIControlStateNormal];
        if ( background.isLocked.boolValue ) {
            [self fadeIn:viewLocked];
            [self fadeIn:viewLock];
        }
        else {
            [self fadeOut:viewLocked];
            [self fadeOut:viewLock];
        }
    }
}

-(IBAction)buyBackgroundPressed:(id)sender {
    int credits = [data credits].intValue;
    DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
    int cost = background.cost.intValue;
    
    if ( credits >= cost )
        [alertUseCredits show];
    else
        [alertBuyCredits show];
}

-(IBAction)beginRecordPressed:(id)sender {
    writerView.recordButton = sender;
    [writerView toggleRecording:sender];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollerMovies;
}


//- (void)orientationChanged:(NSNotification *)notification
//{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation))
//    {
//        viewInstructionsPortraight.alpha = 0.0;
//        viewInstructionsLandscape.alpha = 1.0;
//    }
//    else
//    {
//        viewInstructionsPortraight.alpha = 1.0;
//        viewInstructionsLandscape.alpha = 0.0;
//    }
//    [self updateBackgroundImage];
//    if ( deviceOrientation == UIDeviceOrientationPortrait)
//        [self.view sendSubviewToBack:writerView.view];
//    if ( deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
//        [self.view bringSubviewToFront:writerView.view];
//}


-(IBAction)toggleCameraPressed:(id)sender {
    useFrontCamera = !useFrontCamera;
}

-(IBAction)helpPressed:(id)sender {
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        viewInstructionsLandscape.alpha = 1.0;
    else
        viewInstructionsPortraight.alpha = 1.0;    
}

-(void)playMovieFinished:(NSNotification*)aNotification
{
    MPMoviePlayerController* player=[aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
    
    player.view.frame = CGRectMake(0, 0, 0, 0);
    // Release the movie instance created in playMovieAtURL
}
-(IBAction)playMovie:(UIButton *)sender {
    selectedMovie = sender.tag;
    // The path for the video
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSURL * movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, [NSString stringWithFormat:@"Movie%d.MOV", selectedMovie]] isDirectory:false];
    NSLog ( @"Playing: %@", movieURL);
    
    
    MPMoviePlayerController * player = [[MPMoviePlayerController alloc] init];
    player.view.frame = self.view.bounds;
    [self.view addSubview:player.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playMovieFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    player.movieSourceType = MPMovieSourceTypeFile;
    player.shouldAutoplay = true;
    player.contentURL = movieURL;
    [player prepareToPlay];
    
    player.controlStyle = MPMovieControlStyleFullscreen;
    player.fullscreen = true;
    player.view.transform = CGAffineTransformConcat(player.view.transform, CGAffineTransformMakeRotation(M_PI_2));
}
-(IBAction)removePressed:(UIButton *)sender {
    selectedMovie = sender.tag;
    [[[UIAlertView alloc]initWithTitle:@"Delete this movie?" message:@"Do you want to delete this movie? You can not undo this action" delegate:self cancelButtonTitle:@"Keep" otherButtonTitles:@"Delete", nil]show ];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 1 ) {
        NSData * movie = [movies objectAtIndex:selectedMovie];
        [movies removeObject:movie];
        [[Data shared] setObject:movies forKey:@"movies"];
        [[Data shared] synchronize];
        [self refreshMovies];
    }
}




@end
