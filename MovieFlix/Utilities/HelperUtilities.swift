//
//  HelperUtilities.swift
//  MovieFlix
//
//  Created by George on 28/4/24.
//

import Foundation
import Network
import UIKit

/// Connectivity checker
func checkInternetConnection(completion: @escaping (Bool) -> Void) {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetMonitor")
    
    monitor.start(queue: queue)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            completion(true)
        } else {
            completion(false)
        }
    }
}

/// Returns the date formatted in the format shown in the mockups
func dateFormatted(dateUnformatted: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    if let date = dateFormatter.date(from: dateUnformatted) {
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM dd yyyy"
        
        let formattedDate = outputFormatter.string(from: date)
        return formattedDate
    }
    
    return dateUnformatted
}

/// Shows a generic messag sheet
func showMessageSheet(in viewController: UIViewController, title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
        alertController.dismiss(animated: true)
    }
    
    alertController.addAction(okAction)
    viewController.present(alertController, animated: true, completion: nil)
}
