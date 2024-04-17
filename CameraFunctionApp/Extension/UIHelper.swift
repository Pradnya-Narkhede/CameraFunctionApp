//
//  UIHelper.swift
//  CameraFunctionApp
//
//  Created by Apple on 17/04/24.
//

import Foundation
import UIKit

class UIHelper {
    
    static func showAlert(_ vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
