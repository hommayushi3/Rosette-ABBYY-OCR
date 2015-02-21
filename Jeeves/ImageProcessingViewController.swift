//
//  ImageProcessingViewController.swift
//  Jeeves
//
//  Created by Yushi Homma on 2/21/15.
//  Copyright (c) 2015 Yushi Homma. All rights reserved.
//

import UIKit

class ImageProcessingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    // define a UIImage property and the calling VC would be resonpsible for setting that
    */
    
    // HTTP Request
    let url = NSURL(string: "http://cloud.ocrsdk.com/processImage")
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    let applicationID = "ForeignLanguageImageReader"
    let applicationPassword = "OsPOyLN7+ZNyvIZ//kKiEp2y"
    let loginString = NSString(format: "%@:%@", applicationID, applicationPassword)
    let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)
    let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

}
