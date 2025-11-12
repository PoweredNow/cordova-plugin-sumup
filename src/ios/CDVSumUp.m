#import "CDVSumUp.h"
#import <SumUpSDK/SumUpSDK.h>

@implementation CDVSumUp

-(void) login:(CDVInvokedUrlCommand *)command {
  [[NSBundle mainBundle] infoDictionary];
  NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
  NSString* apikey = [infoDict objectForKey:@"SUMUP_API_KEY"];
  [SMPSumUpSDK setupWithAPIKey:apikey];
  
  if (command.arguments && [command.arguments count] > 0) {
    NSString* accessToken = [command.arguments objectAtIndex:0];
    [SMPSumUpSDK loginWithToken:accessToken completion:^(BOOL success, NSError *error) {
      CDVPluginResult* pluginResult = nil;
      if (success) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      } else {
        NSInteger errorCode = [error code];
        NSDictionary *dict = @{
                               @"code" : @(errorCode),
                               @"message" : @"Login failed",
                               };
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
      }
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
  } else {
    [SMPSumUpSDK presentLoginFromViewController:self.viewController
        animated:YES
        completionBlock:^(BOOL success, NSError *error) {

        CDVPluginResult* pluginResult = nil;
        if (success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
  }
}

-(void) logout:(CDVInvokedUrlCommand *)command {
  [SMPSumUpSDK logoutWithCompletionBlock:^(BOOL success, NSError *error) {
      CDVPluginResult* pluginResult = nil;
      if (success) {
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      } else {
        NSDictionary *dict = @{
                               @"code" : @0,
                               @"message" : @"Logout failed"
                               };
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
      }
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

-(void) settings:(CDVInvokedUrlCommand *)command {
  [SMPSumUpSDK presentCheckoutPreferencesFromViewController:self.viewController
   animated:YES
   completion:^(BOOL success, NSError * _Nullable error) {
     CDVPluginResult* pluginResult = nil;
     if (success) {
       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
       NSInteger errorCode = [error code];
       NSString *msg = @"";
       
       if (errorCode == SMPSumUpSDKErrorAccountNotLoggedIn) {
         msg = @"User is not logged in";
       }
       
       NSDictionary *dict = @{
                              @"code" : @(errorCode),
                              @"message" : msg
                              };
       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
     }
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   }];
}

-(void) isLoggedIn:(CDVInvokedUrlCommand *)command {
  BOOL isLoggedIn = [SMPSumUpSDK isLoggedIn];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isLoggedIn];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) prepare:(CDVInvokedUrlCommand *)command {
  [SMPSumUpSDK prepareForCheckout];
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) auth:(CDVInvokedUrlCommand *)command {
  [[NSBundle mainBundle] infoDictionary];
  NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
  NSString* apikey = [infoDict objectForKey:@"SUMUP_API_KEY"];
  [SMPSumUpSDK setupWithAPIKey:apikey];
  
  if (command.arguments && [command.arguments count] > 0) {
    NSString* accessToken = [command.arguments objectAtIndex:0];
    [SMPSumUpSDK loginWithToken:accessToken completion:^(BOOL success, NSError *error) {
      CDVPluginResult* pluginResult = nil;
      if (success) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      } else {
        NSInteger errorCode = [error code];
        NSDictionary *dict = @{
                               @"code" : @(errorCode),
                               @"message" : @"Login failed",
                               };
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
      }
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
  } else {
    [SMPSumUpSDK presentLoginFromViewController:self.viewController
        animated:YES
        completionBlock:^(BOOL success, NSError *error) {

        CDVPluginResult* pluginResult = nil;
        if (success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
  }
}

-(void) close:(CDVInvokedUrlCommand *)command {
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) pay:(CDVInvokedUrlCommand *)command {
    NSDecimal total = [(NSNumber*)[command.arguments objectAtIndex:0] decimalValue];
    NSString* currency = [command.arguments objectAtIndex:1];
    NSString* title = [command.arguments objectAtIndex:2];

    [SMPSumUpSDK checkTapToPayAvailability:^(BOOL isAvailable, BOOL isActivated, NSError * _Nullable error) {
        if (error == nil && isAvailable) {
            [self showPaymentMethodSelectionForTotal:total currency:currency title:title isActivated:isActivated command:command];
        } else {
            [self processPaymentWithTotal:total currency:currency title:title paymentOption:SMPPaymentOptionCardReader command:command];
        }
    }];
}

-(void) showPaymentMethodSelectionForTotal:(NSDecimal)total currency:(NSString*)currency title:(NSString*)title isActivated:(BOOL)isActivated command:(CDVInvokedUrlCommand*)command {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Payment Method"
                                                                   message:@"Choose how to process this payment"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cardReaderAction = [UIAlertAction actionWithTitle:@"Card Reader"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
        [self processPaymentWithTotal:total currency:currency title:title paymentOption:SMPPaymentOptionCardReader command:command];
    }];

    UIAlertAction *tapToPayAction = [UIAlertAction actionWithTitle:@"Tap to Pay"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
        if (isActivated) {
            [self processPaymentWithTotal:total currency:currency title:title paymentOption:SMPPaymentOptionTapToPay command:command];
        } else {
            [SMPSumUpSDK presentTapToPayActivationFromViewController:self.viewController
                                                             animated:YES
                                                      completionBlock:^(BOOL success, NSError * _Nullable activationError) {
                if (success) {
                    [self processPaymentWithTotal:total currency:currency title:title paymentOption:SMPPaymentOptionTapToPay command:command];
                } else {
                    NSDictionary *dict = @{
                                           @"code" : @0,
                                           @"message" : @"Tap to Pay activation cancelled"
                                           };
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];
        }
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dict = @{
                               @"code" : @0,
                               @"message" : @"Payment cancelled"
                               };
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

    [alert addAction:cardReaderAction];
    [alert addAction:tapToPayAction];
    [alert addAction:cancelAction];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.viewController.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.viewController.view.bounds.size.width / 2.0, self.viewController.view.bounds.size.height / 2.0, 1.0, 1.0);
    }

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

-(void) processPaymentWithTotal:(NSDecimal)total currency:(NSString*)currency title:(NSString*)title paymentOption:(SMPPaymentOptions)paymentOption command:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    SMPCheckoutRequest *request = [SMPCheckoutRequest requestWithTotal:[NSDecimalNumber decimalNumberWithDecimal:total] title:title
        currencyCode:currency];

    [request setSkipScreenOptions:SMPSkipScreenOptionSuccess];
    [request setPaymentOptions:paymentOption];

    [SMPSumUpSDK checkoutWithRequest:request fromViewController:self.viewController completion:^(SMPCheckoutResult *result, NSError *error) {
        CDVPluginResult* pluginResult = nil;

        if (result.success) {
//          for(NSString *key in [result.additionalInfo allKeys]) {
//            NSLog(@"%@ : %@", key, [result.additionalInfo objectForKey:key]);
//          }
          NSDictionary *card = result.additionalInfo[@"card"];
          NSMutableDictionary *dict = [NSMutableDictionary new];

          NSArray *keysToCheck = @[@"transaction_code", @"merchant_code", @"amount", @"tip_amount", @"vat_amount",
                            @"currency", @"status", @"payment_type", @"entry_mode"];

          for (NSString *key in keysToCheck) {
              if (result.additionalInfo[key]) {
                  dict[key] = result.additionalInfo[key];
              }
          }

          if (card[@"type"]) {
              dict[@"card_type"] = card[@"type"];
          }
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        } else {
          NSInteger errorCode = [error code];
          NSDictionary *dict = @{
                                 @"code" : @(errorCode),
                                 @"message" : @"",
                                 };
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

    if (![SMPSumUpSDK checkoutInProgress]) {
      NSDictionary *dict = @{
                             @"code" : @51,
                             @"message" : @""
                             };
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void) checkTapToPayAvailability:(CDVInvokedUrlCommand *)command {
  [SMPSumUpSDK checkTapToPayAvailability:^(BOOL isAvailable, BOOL isActivated, NSError * _Nullable error) {
    CDVPluginResult* pluginResult = nil;

    if (error == nil) {
      NSDictionary *dict = @{
                             @"isAvailable" : @(isAvailable),
                             @"isActivated" : @(isActivated)
                             };
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    } else {
      NSInteger errorCode = [error code];
      NSDictionary *dict = @{
                             @"code" : @(errorCode),
                             @"message" : [error localizedDescription] ?: @"Error checking Tap to Pay availability"
                             };
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

-(void) presentTapToPayActivation:(CDVInvokedUrlCommand *)command {
  [SMPSumUpSDK presentTapToPayActivationFromViewController:self.viewController
                                                   animated:YES
                                            completionBlock:^(BOOL success, NSError * _Nullable error) {
    CDVPluginResult* pluginResult = nil;

    if (success) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
      NSInteger errorCode = error ? [error code] : 0;
      NSDictionary *dict = @{
                             @"code" : @(errorCode),
                             @"message" : [error localizedDescription] ?: @"Tap to Pay activation failed"
                             };
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

-(void) testSDKIntegration:(CDVInvokedUrlCommand *)command {
  [SMPSumUpSDK testSDKIntegration];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
