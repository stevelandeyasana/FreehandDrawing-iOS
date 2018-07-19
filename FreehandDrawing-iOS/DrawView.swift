/*
 The MIT License (MIT)
 
 Copyright (c) 2015-present Badoo Trading Limited.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

class DrawView : UIView, Canvas, DrawCommandReceiver {
    
    // MARK: Canvas
    
    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    func reset() {
        self.buffer = nil
        self.layer.contents = nil
    }
    
    // MARK: DrawCommandReceiver
    
    func executeCommands(commands: [DrawCommand]) {
        autoreleasepool {
            self.buffer = drawInContext { context in
                commands.forEach { $0.execute(canvas: self) }
            }
            
            self.layer.contents = self.buffer?.cgImage ?? nil
        }
    }
    
    // MARK: General setup to draw. Reusing a buffer and returning a new one
    
    private func drawInContext(code:(_ context: CGContext) -> Void) -> UIImage {
        let size = self.bounds.size
        
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context!.fill(self.bounds)
        
        // Draw previous buffer first
        if let buffer = buffer {
            buffer.draw(in: self.bounds)
        }
        
        // Execute draw code
        code(context!)
        
        // Grab updated buffer and return it
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private var buffer: UIImage?
}
