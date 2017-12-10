/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Original Inspiration & Author
 * Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

protocol MotionProgressRunnerDelegate: class {
    func update(elapsedTime: TimeInterval)
    func complete(isFinished: Bool)
}

class MotionProgressRunner {
    weak var delegate: MotionProgressRunnerDelegate?
    
    var isRunning: Bool {
        return displayLink != nil
    }
    
    internal var timePassed: TimeInterval = 0
    internal var duration: TimeInterval = 0
    internal var displayLink: CADisplayLink?
    internal var isReversed: Bool = false
    
    @objc
    func displayUpdate(_ link: CADisplayLink) {
        timePassed += isReversed ? -link.duration : link.duration
        
        if isReversed, timePassed <= 1.0 / 120 {
            delegate?.complete(isFinished: false)
            stop()
            return
        }
        
        if !isReversed, timePassed > duration - 1.0 / 120 {
            delegate?.complete(isFinished: true)
            stop()
            return
        }
        
        delegate?.update(elapsedTime: timePassed / duration)
    }
    
    func start(timePassed: TimeInterval, totalTime: TimeInterval, reverse: Bool) {
        stop()
        
        self.timePassed = timePassed
        self.isReversed = reverse
        self.duration = totalTime
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
        displayLink!.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
    }
    
    func stop() {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        displayLink = nil
    }
}
