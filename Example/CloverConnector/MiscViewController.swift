//
//  MiscViewController.swift
//  ExamplePOS
//
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//
import Foundation
import UIKit
import GoConnector

class MiscViewController : UIViewController, UINavigationControllerDelegate {
    @IBOutlet var customActivityPayload: UITextField!
    @IBOutlet var customActivityAction: UITextField!
    @IBOutlet var nonBlockingSwitch: UISwitch!
    @IBOutlet var externalPaymentId: UITextField!
    @IBOutlet var sendMsgWithStatusSwitch: UISwitch!
    
    var appDelegate: AppDelegate? {
        get {
            return UIApplication.shared.delegate as? AppDelegate
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (FLAGS.isCloverGoMode){
            DispatchQueue.main.async {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.view.isHidden = true
                let alert = UIAlertController(title: "", message: "Not supported with CloverGo Connector", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    strongSelf.navigationController?.popViewController(animated: true)
                }))
                
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func welcomeClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.showWelcomeScreen()
    }
    
    @IBAction func thankYouClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.showThankYouScreen()
    }
    
    @IBAction func showMessageClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.showMessage("Hello iOS!")
    }
    
    @IBAction func resetClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.resetDevice()
    }
    
    @IBAction func readCardData(_ sender: UIButton) {
        let request:ReadCardDataRequest = ReadCardDataRequest()
        appDelegate?.cloverConnector?.readCardData(request);
    }
    
    @IBAction func openCashDrawer(_ sender: UIButton) {
        let cashDrawerRequest = OpenCashDrawerRequest("Cash Back", deviceId: nil)
        appDelegate?.cloverConnector?.openCashDrawer(cashDrawerRequest)
    }
    
    @IBAction func requestPendingPayments(_ sender: UIButton) {
        appDelegate?.cloverConnector?.retrievePendingPayments()
    }
    
    @IBAction func startCustomActivity(_ sender: UIButton) {
        let car = CustomActivityRequest(customActivityAction.text ?? "unk", payload: customActivityPayload.text)
        car.nonBlocking = nonBlockingSwitch.isOn
        appDelegate?.cloverConnector?.startCustomActivity(car)
    }
    
    @IBAction func sendMessageClicked(_ sender: UIButton) {
        let mta = MessageToActivity(action: customActivityAction.text ?? "unk", payload: customActivityPayload.text)
        appDelegate?.cloverConnector?.sendMessageToActivity(mta)
    }
    
    @IBAction func currentStatusClicked(sender: UIButton) {
        let dsr = RetrieveDeviceStatusRequest(sendLastMessage: sendMsgWithStatusSwitch.isOn)
        appDelegate?.cloverConnector?.retrieveDeviceStatus(dsr)
    }
    
    @IBAction func queryPayment(sender: UIButton) {
        guard let epi = externalPaymentId.text else {
            debugPrint("Invalid external Id")
            return
        }
        let rpr = RetrievePaymentRequest(epi)
        appDelegate?.cloverConnector?.retrievePayment(rpr)
    }
}
