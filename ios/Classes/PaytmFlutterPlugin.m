#import "PaytmFlutterPlugin.h"
#import "PaymentsSDK.h"

//判断手机型号
#define p_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define p_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define p_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define p_SCREEN_MAX_LENGTH (MAX(p_SCREEN_WIDTH, p_SCREEN_HEIGHT))
#define p_IPHONE_4_OR_LESS (p_IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define p_IPHONE_5 (p_IS_IPHONE && p_SCREEN_MAX_LENGTH == 568.0)
#define p_IPHONE_6 (p_IS_IPHONE && p_SCREEN_MAX_LENGTH == 667.0)
#define p_IPHONE_6P (p_IS_IPHONE && p_SCREEN_MAX_LENGTH == 736.0)
#define p_IPHONE_X ((p_IS_IPHONE && p_SCREEN_MAX_LENGTH == 812.0) || (p_IS_IPHONE && p_SCREEN_MAX_LENGTH == 896.0))
#define p_IPHONE_XSMaxAndXR (p_IS_IPHONE && p_SCREEN_MAX_LENGTH == 896.0)

#pragma mark 屏幕尺寸相关
#define p_kScreenW [UIScreen mainScreen].bounds.size.width
#define p_kScreenH [UIScreen mainScreen].bounds.size.height
#define p_kSafeAreaTopHeight  ((p_kScreenH == 812.0) || (p_kScreenH == 896.0) ? 88 : 64)
#define p_kSafeAreaTopHeightS  ((p_kScreenH == 812.0) || (p_kScreenH == 896.0) ? 44 : 20)
#define p_kSafeAreaBottomHeight ((p_kScreenH == 812.0) || (p_kScreenH == 896.0) ? 34 : 0)

// 屏幕尺寸
#define p_kScreemSize [UIScreen mainScreen].bounds.size
#define p_kScaleX(x) p_kScreemSize.width * ((x) / 375.0)
#define p_kScaleY(y)  (p_IPHONE_5 ? p_kScreemSize.height * ((y) / 667.0) : p_IPHONE_6 ? p_kScreemSize.height * ((y) / 667.0) : p_IPHONE_6P ? p_kScreemSize.height * ((y) / 667.0) : p_kScreemSize.height * ((y) / 812.0))

#define p_HEIGHT_64 ([[UIScreen mainScreen] bounds].size.height - 64)

@interface PaytmFlutterPlugin ()<PGTransactionDelegate>
@property (nonatomic,copy)NSString * returnUrl;
@property (nonatomic, copy) FlutterResult result;
@end

@implementation PaytmFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"paytm_flutter"
            binaryMessenger:[registrar messenger]];
  PaytmFlutterPlugin* instance = [[PaytmFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"goToPaytm" isEqualToString:call.method]) {
      _result = result;
      [self showPaytm:call.arguments];
      
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}
#pragma mark showPaytm
-(void)showPaytm:(NSDictionary *)di
{
    //
//    MID = CHANGS52506372368458;
//    "ORDER_ID" = 201910302;
//    "CUST_ID" = 3ae448e3591a75c3efc937fa7753b131;
//    "TXN_AMOUNT" = "4235.0";
//    "CHANNEL_ID" = WAP;
//    WEBSITE = WEBSTAGING;
//    "INDUSTRY_TYPE_ID" = Retail;
//    CHECKSUMHASH = "xL7ltn/IWRX5bhiNjeayJQdsbmQoiFR657xP8VWtid4gfSujkEYegTMGscb/YuHEstCvmxJ65D4e6gPLjNyDQA3Yhy09U4f16S7q4zlSGik=";
//    "CALLBACK_URL" = "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=201910302";
//    "MOBILE_NO" = 1234567085;
//    EMAIL = "809400022@163.com";
//
//    ReturnUrl = "http://paytest.oloan.in/ps/paytmReturn";
    

    NSMutableDictionary *orderDict = [NSMutableDictionary dictionary];
    orderDict[@"MID"] = [NSString stringWithFormat:@"%@",di[@"MID"]];
    orderDict[@"ORDER_ID"] = [NSString stringWithFormat:@"%@",di[@"ORDER_ID"]];
    orderDict[@"CUST_ID"] = [NSString stringWithFormat:@"%@",di[@"CUST_ID"]];
    orderDict[@"TXN_AMOUNT"] = [NSString stringWithFormat:@"%@",di[@"TXN_AMOUNT"]];
    orderDict[@"CHANNEL_ID"] = [NSString stringWithFormat:@"%@",di[@"CHANNEL_ID"]];
    orderDict[@"WEBSITE"] = [NSString stringWithFormat:@"%@",di[@"WEBSITE"]];
    orderDict[@"INDUSTRY_TYPE_ID"] = [NSString stringWithFormat:@"%@",di[@"INDUSTRY_TYPE_ID"]];
    orderDict[@"CHECKSUMHASH"] = [NSString stringWithFormat:@"%@",di[@"CHECKSUMHASH"]];
    orderDict[@"CALLBACK_URL"] = [NSString stringWithFormat:@"%@",di[@"CALLBACK_URL"]];
    orderDict[@"MOBILE_NO"] = [NSString stringWithFormat:@"%@",di[@"MOBILE_NO"]];
    orderDict[@"EMAIL"] = [NSString stringWithFormat:@"%@",di[@"EMAIL"]];
    //
    PGOrder *order = [PGOrder orderWithParams:orderDict];
    //
    PGTransactionViewController *txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
    
    #ifdef DEBUG // 开发

        txnController.serverType = eServerTypeStaging; // 测试环境

    #else // 生产
        txnController.serverType = eServerTypeProduction; // 生产环境
           
    #endif
    
    txnController.loggingEnabled = YES;
    txnController.merchant = [PGMerchantConfiguration defaultConfiguration];
    txnController.delegate = self;
    
    UIView * topBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, p_kScreenW, p_kSafeAreaTopHeight)];
//    topBar.backgroundColor = HEXCOLOR(0x3960B1);
    txnController.topBar = topBar;
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(p_kScaleX(7), p_kSafeAreaTopHeightS, p_kScaleX(40), p_kScaleY(40))];
    [cancelButton setImage:[UIImage imageNamed:@"nav返回"] forState:UIControlStateNormal];
    txnController.cancelButton = cancelButton;

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:txnController animated:YES completion:nil];
}
#pragma mark PGTransactionViewController delegate

-(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString
{
    //json字符串先去掉‘\’
    NSMutableString *response = [NSMutableString stringWithString:responseString];
    NSString *character = nil;
     for (int i = 0; i < response.length; i ++) {
         character = [response substringWithRange:NSMakeRange(i, 1)];
         if ([character isEqualToString:@"\\"])
            [response deleteCharactersInRange:NSMakeRange(i, 1)];
     }
    //转字典
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
//    BANKNAME = NULL;
//    BANKTXNID = 777001883383912;
//    CHECKSUMHASH = "ClK93IgxjMbsBe8nwtGRwLUTpbiopEJK4K+84PAuP+BPHIJnXN3RK+Z8pnq4LAg2aSf3AAwR4gS3Y+N/8V9jxc65iQa9pkFkYHvK4aCUIS4=";
//    CURRENCY = INR;
//    GATEWAYNAME = HDFC;
//    MID = CHANGS52506372368458;
//    ORDERID = 2019111517;
//    PAYMENTMODE = DC;
//    RESPCODE = 01;
//    RESPMSG = "Txn Success";
//    STATUS = "TXN_SUCCESS";
//    TXNAMOUNT = "8660.00";
//    TXNDATE = "2019-11-15 09:12:09.0";
//    TXNID = 20191115111212800110168804101022930;
    
    NSString * STATUS = [NSString stringWithFormat:@"%@",dict[@"STATUS"]];
    if ([STATUS isEqualToString:@"TXN_SUCCESS"]) {
        //成功
        _result(@"success");
    }else{
        NSString * msg = [NSString stringWithFormat:@"%@",dict[@"RESPMSG"]];
        _result(msg);
    }

}

- (void)errorMisssingParameter:(PGTransactionViewController *)controller error:(NSError *) error
{
    NSString * msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
    _result(msg);

}

-(void)didCancelTrasaction:(PGTransactionViewController *)controller
{
}


@end
