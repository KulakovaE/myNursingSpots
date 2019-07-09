//
//  UIDeviceExtension.swift
//  myNursingSpots
//
//  Created by Darko Kulakov on 2019-07-09.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit

extension UIDevice {
    var iPhone: Bool {
        return self.userInterfaceIdiom == .phone
    }
    
    var iPad: Bool {
        return self.userInterfaceIdiom == .pad
    }
}
