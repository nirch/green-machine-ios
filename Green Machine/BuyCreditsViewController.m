//
//  BuyPicksViewController.m
//  King of the Riff
//
//  Created by Eyal Shpits on 2/3/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "BuyCreditsViewController.h"
#import "Data.h"

@interface BuyCreditsViewController ()

@end

@implementation BuyCreditsViewController

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

    buttonBuy1.enabled = buttonBuy2.enabled = buttonBuy3.enabled = buttonBuy4.enabled = false;

    imageviewThanks.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"thank"], [UIImage imageNamed:@"thank2"], nil];
    imageviewThanks.animationDuration = 1.5;
    [imageviewThanks startAnimating];

    
    productIdentifiers = [[Data shared] objectForKey:@"productids"];

    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
    
    
    // Do any additional setup after loading the view from its nib.
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    products = response.products;
    int i = 0;
    for ( SKProduct * product in response.products ) {
        NSInteger index = [productIdentifiers indexOfObject:product.productIdentifier];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
        switch (index) {
            case 0: {
                [indicator1 stopAnimating];
                [buttonBuy1 setTitle:formattedPrice forState:UIControlStateNormal];
                [buttonBuy1 setTitle:formattedPrice forState:UIControlStateHighlighted];
                labelBuy1.text = product.localizedTitle; //[[[Data shared] objectForKey:@"productcredits"] objectAtIndex:index];
                buttonBuy1.tag = i;
                buttonBuy1.enabled = true;
                buttonBuy1.titleLabel.font = [UIFont systemFontOfSize:13.0];
                break;
            }
            case 1: {
                [indicator2 stopAnimating];
                [buttonBuy2 setTitle:formattedPrice forState:UIControlStateNormal];
                [buttonBuy2 setTitle:formattedPrice forState:UIControlStateHighlighted];
                labelBuy2.text = product.localizedTitle; //[[[Data shared] objectForKey:@"productcredits"] objectAtIndex:index];
                buttonBuy2.tag = i;
                buttonBuy2.titleLabel.font = [UIFont systemFontOfSize:13.0];
                buttonBuy2.enabled = true;
                break;
            }
            case 2: {
                [indicator3 stopAnimating];
                [buttonBuy3 setTitle:formattedPrice forState:UIControlStateNormal];
                [buttonBuy3 setTitle:formattedPrice forState:UIControlStateHighlighted];
                labelBuy3.text = product.localizedTitle; //[[[Data shared] objectForKey:@"productcredits"] objectAtIndex:index];
                buttonBuy3.tag = i;
                buttonBuy3.titleLabel.font = [UIFont systemFontOfSize:13.0];
                buttonBuy3.enabled = true;
                break;
            }
            case 3: {
                [indicator4 stopAnimating];
                [buttonBuy4 setTitle:formattedPrice forState:UIControlStateNormal];
                [buttonBuy4 setTitle:formattedPrice forState:UIControlStateHighlighted];
                labelBuy4.text = product.localizedTitle; //[[[Data shared] objectForKey:@"productcredits"] objectAtIndex:index];
                buttonBuy4.tag = i;
                buttonBuy4.titleLabel.font = [UIFont systemFontOfSize:13.0];
                buttonBuy4.enabled = true;
                break;
            }
                
            default:
                break;
        }
        i++;
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [[[UIAlertView alloc]initWithTitle:@"AppStore issue" message:[NSString stringWithFormat:@"Your purchase has failed- %@,\nPlease try again" , error.description] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil]show ];
}

-(IBAction) restorePurchasesPressed:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
- (IBAction)buy:(UIButton *)sender {
    SKProduct *product = [products objectAtIndex:sender.tag];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) back:(id)sender {
    [self.view removeFromSuperview];
}

@end
