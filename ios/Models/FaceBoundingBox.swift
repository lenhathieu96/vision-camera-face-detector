//
//  File.swift
//  VisionCameraFaceDetectorPlugin
//
//  Created by Lê Nhật Hiếu on 14/11/2023.
//

import Foundation
struct BoundingBox {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    
    var top: CGFloat {
        return y
    }

    var left: CGFloat {
        return x
    }

    var bottom: CGFloat {
        return y + height
    }

    var right: CGFloat {
        return x + width
    }
    
    var centerX: Double {
        return x + (width / 2)
    }
    
    var centerY: Double {
        return y + (height / 2)
    }
    
    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

