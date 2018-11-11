//
//  ViewController.swift
//  http
//
//  Created by young on 10/11/2018.
//  Copyright © 2018 young. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        func jsonPost(_ sender:Any){
            
            let uid = NSUUID().uuidString
            let ocode = "testocode"
            let IMEI = "testIMEI"
            let param = ["uid":uid, "IMEI":IMEI, "ocode":ocode]
            let paramData = try! JSONSerialization.data(withJSONObject: param, options: [])
            
            let url = URL(string: "http://m.edutopik.com/myroom/AppCheck.asp")
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = paramData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
            
            let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
                
                guard let data = data, error == nil else{
                    print("error=\(error as Optional)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response as Optional?)")
                }
                
                let responseString = String(data : data, encoding: .utf8)
                print("responseString = \(responseString as String?)")
            }
            
            task.resume()
            
        }    }
    

}



