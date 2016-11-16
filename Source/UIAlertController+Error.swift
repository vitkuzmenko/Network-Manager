//
//  UIAlertController+Error.swift
//  Network Manager
//
//  Created by Vitaliy Kuzmenko on 16/11/2016.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
    
    extension UIAlertController {
        
        class func show(error: ResponseError, in vc: UIViewController) {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
        
    }
    
#else
    
#endif
