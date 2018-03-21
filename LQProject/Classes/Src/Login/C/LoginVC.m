//
//  LoginVC.m
//  PublicLawyerChat
//
//  Created by lawchat on 16/5/12.
//  Copyright © 2016 . All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *inputBackgroudView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UIView *userNameSubLine;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextFiled;
@property (weak, nonatomic) IBOutlet UIView *passwordSubLine;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)initViewData {
    /**
     *  填充已保存用户名密码
     */
    if (User_Center.ID.length > 0) {
        _userNameTextField.text = User_Center.ID;
    }
    if (User_Center.pass.length > 0) {
        _passwordTextFiled.text = User_Center.pass;
    }

    /**
     *  设置输入用户名密码交互
     */
    
    _userNameTextField.delegate = self;
    _passwordTextFiled.delegate = self;
    
    //用户名输入框信号通道
    RACSignal *validUsernameSignal =
    [self.userNameTextField.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidUsername:text]);
     }];
    
    RAC(self.userNameTextField, textColor) =
    [validUsernameSignal
     map:^id(NSNumber *userNameValid){
         return [userNameValid boolValue] ? UIColorBlue:UIColorDisabled;
     }];
    
    [[[_userNameTextField rac_signalForControlEvents:UIControlEventEditingDidEnd]
    flattenMap:^id(id x){
        return validUsernameSignal;
    }]
     subscribeNext:^(NSNumber *validUsername){

         BOOL success =[validUsername boolValue];
         if(success){
             _userNameTextField.textColor = UIColorBlue;
         }else{
             _userNameTextField.textColor = UIColorRed;
         }
     }];
    
    //密码输入框信号通道
    RACSignal *validPasswordSignal =
    [self.passwordTextFiled.rac_textSignal
     map:^id(NSString *text) {
         return @([self isValidPassword:text]);
     }];
    RAC(self.passwordTextFiled, textColor) =
    [validPasswordSignal
     map:^id(NSNumber *passwordValid){
         return [passwordValid boolValue] ? UIColorBlue:UIColorDisabled;
     }];
    [[[_passwordTextFiled rac_signalForControlEvents:UIControlEventEditingDidEnd]
      flattenMap:^id(id x){
          return validPasswordSignal;
      }]
     subscribeNext:^(NSNumber *validUsername){
         BOOL success =[validUsername boolValue];
         if(success){
             _passwordTextFiled.textColor = UIColorBlue;
         }else{
             _passwordTextFiled.textColor = UIColorRed;
         }
     }];
    
    
    //聚合用户名-密码 输入框信号通道
    RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber*usernameValid, NSNumber *passwordValid){
                          return @([usernameValid boolValue]&&[passwordValid boolValue]);
                      }];
    [signUpActiveSignal subscribeNext:^(NSNumber*signupActive){
        self.loginBtn.enabled = [signupActive boolValue];
        if ([signupActive boolValue]) {
            self.loginBtn.backgroundColor = UIColorBlue;
        }else{
            self.loginBtn.backgroundColor = UIColorDisabled;
        }
    }];
    
    /**
     *  登录交互
     */
    
    [[[[self.loginBtn
        rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(id x){
           self.loginBtn.enabled =NO;
           self.loginBtn.backgroundColor = UIColorDisabled;
       }]
      flattenMap:^id(id x){
          return [self signInSignal];
      }]
     subscribeNext:^(NSNumber*signedIn){
         self.loginBtn.enabled = YES;
         self.loginBtn.backgroundColor = UIColorBlue;
         BOOL success =[signedIn boolValue];
         if(success){
             //强制登录型
             //登录成功进入APP
             [PageRout_Maneger changeWindowRootToMainVC];
             //可选登录型
             //登录成功POP页面
//             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

#pragma mark - 用户名是否有效
- (BOOL)isValidUsername:(NSString *)text {
    
    return [text checkPhoneNumber];
}

#pragma mark - 密码是否有效
- (BOOL)isValidPassword:(NSString *)text {
    
    return [text checkPassword];
}

#pragma mark - 登录按钮消息通道
- (RACSignal *)signInSignal {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"phone"] = _userNameTextField.text;
        params[@"pass"] = _passwordTextFiled.text;
        
        
        [SVProgressHUD show];
        [RequestTool requestApiWithParams:params andRequestUrl:@"checkLoginSMSCode" completedBlock:^(ApiResponseModel *apiResponseModel, BOOL isSuccess) {
            
            //            if(apiResponseModel) {
            //                switch (apiResponseModel.status.code) {
            //                    case 1:
            //                    {
            //                        //保存用户名密码
            //                        User_Center.ID = params[@"phone"];
            //                        User_Center.pass = params[@"pass"];
            //                        //用户中心
            //                        [UserCenter resetUserCenterWithDictionary:apiResponseModel.data];
            //                        [subscriber sendNext:@(YES)];
            //                        [subscriber sendCompleted];
            //                    }
            //                        break;
            //                    default:
            //                        [SVProgressHUD dismiss];
            //                        [SVProgressHUD showErrorWithStatus:@"登录失败"];
            //                        [subscriber sendNext:@(NO)];
            //                        [subscriber sendCompleted];
            //                        break;
            //                }
            //            }else{
            //                [SVProgressHUD dismiss];
            //                [SVProgressHUD showErrorWithStatus:@"网络异常"];
            //                [subscriber sendNext:@(NO)];
            //                [subscriber sendCompleted];
            //            }
            
            //调试设置:(需删除这段代码)
            [SVProgressHUD dismiss];
            User_Center.ID = params[@"phone"];
            User_Center.pass = params[@"pass"];
            [subscriber sendNext:@(YES)];
            [subscriber sendCompleted];
            //调试设置:(需删除这段代码)
        }];
        return nil;
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
