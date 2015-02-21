//
//  ImageProcessingViewController.swift
//  Jeeves
//
//  Created by Yushi Homma on 2/21/15.
//  Copyright (c) 2015 Yushi Homma. All rights reserved.
//

import Foundation
import UIKit

class ImageProcessingViewController: UIViewController {
    
    var photo : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if photo != nil {
            println("Photo is not nil")
        }
        
        // HTTP Request
        let url = NSURL(string: "http://cloud.ocrsdk.com/processImage")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let applicationID = "Jeeves01"
        let applicationPassword = "qk6XJKf91+ZQ6DP2a39C/uI2"
        let loginString = NSString(format: "%@:%@", applicationID, applicationPassword)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        var err: NSError?
        request.HTTPBody = UIImageJPEGRepresentation(photo!, 1.0)
        
        var session = NSURLSession.sharedSession()

        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData!)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
        
        let urlConnection = NSURLConnection(request: request, delegate: self)
        if urlConnection != nil {
            println("UrlConnection is not nil")
        }
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
    */
    


}
