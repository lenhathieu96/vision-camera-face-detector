//
//  File.swift
//  VisionCameraFaceDetectorPlugin
//
//  Created by Lê Nhật Hiếu on 14/11/2023.
//

import Foundation

struct FaceBoundingBox {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    
    var top: Double {
        return y
    }

    var left: Double {
        return x
    }

    var bottom: Double {
        return y + height
    }

    var right: Double {
        return x + width
    }
    
    var centerX: Double {
        return x + (width / 2)
    }
    
    var centerY: Double {
        return y + (height / 2)
    }
    
    init(rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }
}

