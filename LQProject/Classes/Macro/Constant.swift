//
//  Constant.swift
//  LawChatForLawyer
//
//  Created by Juice on 2017/7/7.
//  Copyright © 2017年 就问律师. All rights reserved.
//

import Foundation


let S_APP_Version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]


func S_RGBCOLOR(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat = 1.0) -> UIColor
{
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}

let S_SCREEN_WIDTH = UIScreen.main.bounds.size.width
let S_SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let S_StatusBarHeight = UIApplication.shared.statusBarFrame.size.height

let S_APPColor_NavigationBar = UIColor.white

let S_APPColor_BackgroudView = UIColor.init(hexString: "F8F8F8")

let S_APPColor_Button_Normal = UIColor.init(hexString: "3682ff")

let S_APPColor_Button_Disable = S_RGBCOLOR(r: 136.0, g:178.0, b:250.0)

let S_APPColor_Green = UIColor.init(hexString: "5FD072")

let S_APPColor_Blue = UIColor.init(hexString: "3682ff")

let S_APPColor_Red = S_RGBCOLOR(r: 221.0, g:72.0, b:71.0)

let S_APPColor_GreenDot = UIColor.init(hexString: "6FD16E")

let S_APPColor_RedDot = UIColor.init(hexString: "E4593F")

let S_APPColor_Text_35 = UIColor.init(hexString: "353535")

let S_APPColor_Text_333 = UIColor.init(hexString: "333333")

let S_APPColor_Text_5a = UIColor.init(hexString: "5a5a5a")

let S_APPColor_Text_aaa = UIColor.init(hexString: "aaaaaa")

let S_APPColor_Text_B2 = UIColor.init(hexString: "B2B2B2")

let S_APPColor_Text_f9 = UIColor.init(hexString: "f9f9f9")

let S_APPColor_Text_888 = UIColor.init(hexString: "888")

let S_APPColor_Text_ccc = UIColor.init(hexString: "CCCCCC")

let S_APPColor_Text_ddd = UIColor.init(hexString: "dddddd")

let S_APPColor_Text_eee = UIColor.init(hexString: "eeeeee")

let kDeviceIs4S = S_SCREEN_HEIGHT == 480
let kDeviceIs5S = S_SCREEN_HEIGHT == 568
let kDeviceIs6S = S_SCREEN_HEIGHT == 667
let kDeviceIs6SPlusMore = S_SCREEN_HEIGHT >= 736
