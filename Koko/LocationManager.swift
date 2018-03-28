//
//  LocationManager.swift
//  Koko
//
//  Created by 青木佑弥 on 2018/01/08.
//  Copyright © 2018年 青木佑弥. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: CLLocationManager {
    private static let sharedInstance = LocationManager()
    
    override required init() {
        super.init()
        
        allowsBackgroundLocationUpdates = true
        delegate = self as? CLLocationManagerDelegate
    }
    
    /**
     位置情報取得の許可を確認
     */
    static func requestAlwaysAuthorization() {
        // バックグラウンドでも位置情報更新をチェックする
        sharedInstance.allowsBackgroundLocationUpdates = true
        sharedInstance.delegate = sharedInstance as? CLLocationManagerDelegate
        sharedInstance.requestAlwaysAuthorization()
    }
}
