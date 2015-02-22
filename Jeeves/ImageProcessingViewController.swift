//
//  ImageProcessingViewController.swift
//  Jeeves
//
//  Created by Yushi Homma on 2/21/15.
//  Copyright (c) 2015 Yushi Homma. All rights reserved.
//

import UIKit


class ImageProcessingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var originalText: UITextView!
    
    var photo : UIImage?
    
    var OCRText : NSString?
    var apiTranslatedText : NSString?
    
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func copyTranslatedText(sender: UIButton) {
        var copyString = translatedText.text
        var pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = copyString
    }
    
    @IBAction func copyOriginalText(sender: UIButton) {
        var copyString = originalText.text
        var pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = copyString
    }
    
    @IBAction func cameraStart(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.hidesWhenStopped = true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: nil)
        self.photo = info[UIImagePickerControllerOriginalImage] as UIImage?
        if self.photo != nil {
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
            println("Photo is not nil")
            // HTTP Request
            let url1 = NSURL(string: "http://cloud.ocrsdk.com/processImage?language=English&exportFormat=txt")
            let request1 = NSMutableURLRequest(URL: url1!)
            request1.HTTPMethod = "POST"
            let applicationID = "Jeeves03"
            let applicationPassword = "OYpzPTcU7kSWeFdwpgP/XMBO"
            let loginString = NSString(format: "%@:%@", applicationID, applicationPassword)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
            request1.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            request1.setValue("applicaton/octet-stream", forHTTPHeaderField: "Content-Type")
            
            let IMAGE_QUALITY = 1.0 as CGFloat
            request1.HTTPBody = UIImageJPEGRepresentation(photo!, IMAGE_QUALITY)
            
            var session1 = NSURLSession.sharedSession()
            
            println(url1!)
            
            var task1 = session1.dataTaskWithRequest(request1, completionHandler: {data1, response1, error -> Void in
//                println("Response: \(response1)")
                let xmlData1 = Task(data: data1)
                let taskID = xmlData1.ID
                println("id= \(taskID) \n")
//                var strData1 = NSString(data: data1, encoding: NSUTF8StringEncoding)
//                println("Body: \(strData1!) \n")
                
                
                // HTTP Request
                let url2 = NSURL(string: "http://cloud.ocrsdk.com/getTaskStatus?taskId=\(taskID)")
                let request2 = NSMutableURLRequest(URL: url2!)
                request2.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                
                var response2: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
                var err2: NSErrorPointer = nil
                
                var taskDownloadURL: NSURL?
                
                while taskDownloadURL == nil {
                    var data2 = NSURLConnection.sendSynchronousRequest(request2, returningResponse: response2, error: err2)!
                    
//                    println("Response: \(response2)")
                    let xmlData2 = Task(data: data2)
                    taskDownloadURL = xmlData2.downloadURL
                    println("downloadURL= \(taskDownloadURL) \n")
//                    var strData2 = NSString(data: data2, encoding: NSUTF8StringEncoding)
//                    println("Body: \(strData2!) \n")
                }
                
                
                // HTTP Request
                let url3 = NSURL(string: "\(taskDownloadURL!)")
                let request3 = NSMutableURLRequest(URL: url3!)
                
                var session3 = NSURLSession.sharedSession()
                
                var task3 = session3.dataTaskWithRequest(request3, completionHandler: {data3, response3, error -> Void in
                    println("Response: \(response3)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.OCRText = NSString(data: data3, encoding: NSUTF8StringEncoding)
                        if self.OCRText != nil {
                            self.originalText.text = self.OCRText!
                        }
                        
                        println("Body: \n\(self.OCRText!) \n")
                        
                        // ATTEMPT WITH WATSON
//                        let conversion = "mt-enus-eses"
//                        let textToConvert = self.OCRText!
//                        let encodedText = textToConvert.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
//                        let parameters = "sid=\(conversion)&txt=\(encodedText!)&rt=text"
//                        let URLEncodedParameters = parameters.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//
//                        //                        println(encodedText)
//                        //                        println(parameters)
//                        //                        println(URLEncodedParameters)
//
//                        let url = NSURL(string: "https://gateway.watsonplatform.net/machine-translation-beta/api/v1/smt/0")
//                        
//                        let request = NSMutableURLRequest(URL: url!)
//                        let username = "d428f9e3-e2f8-44d3-ace9-4a8a58134902"
//                        let password = "U6OzCASC3sty"
//                        let bluemixLoginString = NSString(format: "%@:%@", username, password)
//                        let bluemixLoginData: NSData = bluemixLoginString.dataUsingEncoding(NSUTF8StringEncoding)!
//                        let bluemixBase64LoginString = bluemixLoginData.base64EncodedStringWithOptions(nil)
//                        request.setValue("Basic \(bluemixBase64LoginString)", forHTTPHeaderField: "Authorization")
//                        request.HTTPMethod = "POST"
//                        //                        println(parameters)
//                        request.HTTPBody = URLEncodedParameters
//                        var session = NSURLSession.sharedSession()
//                        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//                            //                    println("Response: \(response)")
//                            dispatch_async(dispatch_get_main_queue()) {
//                                self.apiTranslatedText = NSString(data: data, encoding: NSUTF8StringEncoding)
//                                if self.apiTranslatedText != nil {
//                                    self.translatedText.text = self.apiTranslatedText!
//                                    self.activityIndicatorView.stopAnimating()
//                                    self.activityIndicatorView.hidden = true
//                                }
//                                //
//                                println("Body: \n\(self.apiTranslatedText!) \n")
//                            }
//                        })
//                        task.resume()
                        
                        
                        
                        

                        // ATTEMPT WITH BING
                        // GET AUTHENTICATION TOKEN
                        let windowsClientID = "MA3Z8UwFvUERdHY"
                        let windowsClientPassword = "bffi5E/b+d83B1HcqWrXFmxKnkDku8xmudcZQMhH7wE="
                        let parameters = "grant_type=client_credentials&client_id=MA3Z8UwFvUERdHY&client_secret=bffi5E%2Fb%2Bd83B1HcqWrXFmxKnkDku8xmudcZQMhH7wE%3D&scope=http://api.microsofttranslator.com"
                        let URLEncodedParameters = parameters.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                        
                        
                        let url = NSURL(string: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13")
                        let request = NSMutableURLRequest(URL: url!)
                        request.HTTPMethod = "POST"
                        request.HTTPBody = URLEncodedParameters
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        
                        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
                        var err: NSErrorPointer = nil
                        
                        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: err)!
                        var jsonErr: NSError?
                        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonErr) as? NSDictionary
                        
                        var accessToken:NSString = json?["access_token"] as NSString
//                        println("accessToken=\n\(accessToken)\n")
                        
                        
                        // USING AUTHENTICATION TOKEN TO TRANSLATE
                        let fromLanguage = "en"
                        let toLanguage = "es"
                        let textToConvert = self.OCRText!
                        
                        let urlComponents = NSURLComponents()
                        urlComponents.scheme = "http"
                        urlComponents.host = "api.microsofttranslator.com"
                        urlComponents.path = "/v2/Http.svc/Translate"
                        urlComponents.queryItems = [
                            NSURLQueryItem(name: "text", value: textToConvert),
                            NSURLQueryItem(name: "from", value: fromLanguage),
                            NSURLQueryItem(name: "to", value: toLanguage)
                        ]
                        
                        let translationRequest = NSMutableURLRequest(URL: urlComponents.URL!)
                        translationRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        var translationSession = NSURLSession.sharedSession()
                        var translationTask = translationSession.dataTaskWithRequest(translationRequest, completionHandler: {translationData, translationResponse, translationError -> Void in
                            dispatch_async(dispatch_get_main_queue()) {
                                self.apiTranslatedText = NSString(data: translationData, encoding: NSUTF8StringEncoding)
                                println(NSString(data: translationData, encoding: NSUTF8StringEncoding))
                                if self.apiTranslatedText != nil {
                                    self.translatedText.text = self.apiTranslatedText!
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                }
                                println("Body: \n\(self.apiTranslatedText!) \n")
                            }
                        })
                        translationTask.resume()

                        
                    }
                })
                task3.resume()
                
            })
            task1.resume()
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
