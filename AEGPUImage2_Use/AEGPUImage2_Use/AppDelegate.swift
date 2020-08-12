//
//  AppDelegate.swift
//  AEGPUImage2_Use
//
//  Created by 锋 on 2020/8/12.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension UIView {
    // MARK:- X, Y,xWidth, Height
    
    /// X axis value of UIView
    var x: CGFloat {
        set { self.frame = CGRect(x: newValue, y: self.y, width: self.width, height: self.height) }
        get { return self.frame.origin.x }
    }
    
    /// Y axis value of UIView
    var y: CGFloat {
        set { self.frame = CGRect(x: self.x, y: newValue, width: self.width, height: self.height) }
        get { return self.frame.origin.y }
    }
    
    /// Width of UIView
    var width: CGFloat {
        set { self.frame = CGRect(x: self.x, y: self.y, width: newValue, height: self.height) }
        get { return self.frame.size.width }
    }
    
    /// Height of UIView
    var height: CGFloat {
        set { self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: newValue) }
        get { return self.frame.size.height }
    }
    
    // MARK:- Origin, Size
    
    /// Origin of UIView
    var origin: CGPoint {
        set { self.frame = CGRect(x: newValue.x, y: newValue.y, width: self.width, height: self.height) }
        get { return self.frame.origin }
    }
    
    /// Size of UIView
    var size: CGSize {
        set { self.frame = CGRect(x: self.x, y: self.y, width: newValue.width, height: newValue.height) }
        get { return self.frame.size }
    }
    
    // MARK:- Top, Bottom, Left, Right, CenterX, CenterY
    
    /// Top edge of UIView: y
    var top: CGFloat {
        set { self.y = newValue }
        get { return self.y }
    }
    
    /// bottom edge of UIView: y + height
    var bottom: CGFloat {
        set { self.y = newValue - self.height }
        get { return self.y + self.height }
    }
    
    /// Left edge of UIView: x
    var left: CGFloat {
        set { self.x = newValue }
        get { return self.x }
    }
    
    /// Right edge of UIView: x + width
    var right: CGFloat {
        set { self.x = newValue - self.width }
        get { return self.x + self.width }
    }
    
    /// Center X of UIView: center.x
    var centerX: CGFloat {
        set { self.center = CGPoint(x: newValue, y: self.centerY) }
        get { return self.center.x }
    }
    
    /// Center Y of UIView: center.y
    var centerY: CGFloat {
        set { self.center = CGPoint(x: self.centerX, y: newValue) }
        get { return self.center.y }
    }
}
