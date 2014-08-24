//
//  RenderingViewController.m
//  Green Machine
//
//  Created by Eyal Shpits on 8/19/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "RenderingViewController.h"

@interface RenderingViewController ()

@end

@implementation RenderingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewMovieBG.layer.cornerRadius = 15.0;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) donePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
