//
//  AppDelegate.m
//  Green Machine
//
//  Created by Eyal Shpits on 5/29/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "AppDelegate.h"
#import "Data.h"
#import "Localytics.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Localytics autoIntegrate:@"70424e1ab6f163aeba16863-4d895c5a-9b7a-11e4-2a6c-004a77f8b47f" launchOptions:launchOptions];
    if (application.applicationState != UIApplicationStateBackground)
    {
        [Localytics openSession];
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [Localytics dismissCurrentInAppMessage];
    [Localytics closeSession];
    [Localytics upload];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [Localytics dismissCurrentInAppMessage];
    [Localytics closeSession];
    [Localytics upload];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Localytics openSession];
    [Localytics upload];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [Localytics openSession];
    [Localytics upload];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased: {
                Data * data = [Data shared];
                NSArray * productIdentifiers = [data objectForKey:@"productids"];
                NSArray * productPicks = [data objectForKey:@"productpicks"];
                NSString * productid = transaction.payment.productIdentifier;
                
                NSDictionary *dictionary =
                [NSDictionary dictionaryWithObjectsAndKeys:
                 productid,
                 @"Product ID",
                 nil];
                [Localytics tagEvent:@"Payment Successfull" attributes:dictionary];

                
                int index = [productIdentifiers indexOfObject:productid];
                int currnetpicks = [[data objectForKey:@"currentPicks"] intValue];
                currnetpicks += [[productPicks objectAtIndex:index]intValue];
                [data setObject:[NSString stringWithFormat:@"%d", currnetpicks] forKey:@"currentPicks"];
                [data synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePicks" object:nil];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                [[[UIAlertView alloc]initWithTitle:@"AppStore" message:@"Your purchase was successfull." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                [Localytics tagEvent:@"Payment Failed"];
                [[[UIAlertView alloc]initWithTitle:@"AppStore issue" message:[NSString stringWithFormat:@"Your purchase has failed, please try again. erorr: %@", transaction.error.description] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil]show ];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:
                break;
            default:
                break;
        }
    }
}


@end
