//
//  AppDelegate.swift
//  CloverConnector
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit
import GoConnector
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PairingDeviceConfiguration {

    var window: UIWindow?
    
    public var cloverConnector:ICloverConnector?
    public var cloverConnectorListener:CloverConnectorListener?
    public var testCloverConnectorListener:TestCloverConnectorListener?
    public var store:POSStore?
    fileprivate var token:String?

    fileprivate let PAIRING_AUTH_TOKEN_KEY:String = "PAIRING_AUTH_TOKEN"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        store = POSStore()
        store?.availableItems.append(POSItem(id: "1", name: "Cheeseburger", price: 579, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "2", name: "Hamburger", price: 529, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "3", name: "Bacon Cheeseburger", price: 619, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "4", name: "Chicken Nuggets", price: 569, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "5", name: "Large Fries", price: 239, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "6", name: "Small Fries", price: 179, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "7", name: "Vanilla Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "8", name: "Chocolate Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "9", name: "Strawberry Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "10", name: "$25 Gift Card", price: 2500, taxRate: 0.00, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "11", name: "$50 Gift Card", price: 5000, taxRate: 0.000, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "12", name: "Coke 250ml", price: 100, taxRate: 0.000, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "13", name: "Coke 330ml", price: 200, taxRate: 0.000, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "14", name: "Coke 500ml", price: 300, taxRate: 0.000, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "15", name: "Coke 1.25ltr", price: 500, taxRate: 0.000, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "16", name: "Coke 1.75ltr", price: 1000, taxRate: 0.000, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "17", name: "Coupon1", price: 1, taxRate: 0.000, taxable: true))
        store?.availableItems.append(POSItem(id: "18", name: "Coupon2", price: 2, taxRate: 0.000, taxable: true))
        store?.availableItems.append(POSItem(id: "19", name: "Coupon3", price:5, taxRate: 0.000, taxable: true))
        store?.availableItems.append(POSItem(id: "20", name: "Coupon4", price: 10, taxRate: 0.000, taxable: true))
        
        if let tkn = UserDefaults.standard.string( forKey: PAIRING_AUTH_TOKEN_KEY) {
            token = tkn
        }

        return true
    }
    
    override func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int) -> Bool {
        debugPrint((error as NSError).domain)
        return true
    }
    
    func onPairingCode(_ pairingCode: String) {
        debugPrint("Pairing Code: " + pairingCode)
        self.cloverConnectorListener?.onPairingCode(pairingCode)
    }
    func onPairingSuccess(_ authToken: String) {
        debugPrint("Pairing Auth Token: " + authToken)
        self.cloverConnectorListener?.onPairingSuccess(authToken)
        self.token = authToken
        UserDefaults.standard.set(self.token, forKey: PAIRING_AUTH_TOKEN_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func clearConnect(_ url:String) {
        self.token = nil
        connect(url)
    }
    
    func connect(_ url:String) {
        cloverConnector?.dispose()
        
        var endpoint = url
        if let components = URLComponents(string: url), let _ = components.url { //Make sure the URL is valid, and break into URL components
            self.token = components.queryItems?.first(where: { $0.name == "authenticationToken"})?.value //we can skip the pairing code if we already have an auth token
            
            endpoint = components.scheme ?? "wss"
            endpoint += "://"
            endpoint += components.host ?? ""
            endpoint += ":" + String(components.port ?? 80)
            endpoint += String(components.path)
        }

        let config:WebSocketDeviceConfiguration = WebSocketDeviceConfiguration(endpoint:endpoint, remoteApplicationID: "com.clover.ios.example.app", posName: "iOS Example POS", posSerial: "POS-15", pairingAuthToken: self.token, pairingDeviceConfiguration: self)
//        config.maxCharInMessage = 2000
//        config.pingFrequency = 1
//        config.pongTimeout = 6
//        config.reportConnectionProblemTimeout = 3
        
        let validCloverConnector = CloverConnectorFactory.createICloverConnector(config: config)
        self.cloverConnector = validCloverConnector
        let validCloverConnectorListener = CloverConnectorListener(cloverConnector: validCloverConnector)
        self.cloverConnectorListener = validCloverConnectorListener
        
        self.testCloverConnectorListener = TestCloverConnectorListener(cloverConnector: validCloverConnector)
        validCloverConnectorListener.viewController = self.window?.rootViewController
        validCloverConnector.addCloverConnectorListener(validCloverConnectorListener)
        validCloverConnector.initializeConnection()
    }
    
//    func connectToCloverGoReader() {
//        let config : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: "Lht4CAQq8XxgRikjxwE71JE20by5dzlY", secret: "7ebgf6ff8e98d1565ab988f5d770a911e36f0f2347e3ea4eb719478c55e74d9g", env: .test).accessToken("0a7637b3-66eb-623c-7d9b-2acfb90d8237").deviceType(.RP450).allowDuplicateTransaction(true).allowAutoConnect(true).build()
//
//        cloverConnector = CloverGoConnector(config: config)
//
//        cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector!)
//        cloverConnectorListener?.viewController = self.window?.rootViewController
//        (cloverConnector as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
//
//        cloverConnector!.initializeConnection()
//
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
}

