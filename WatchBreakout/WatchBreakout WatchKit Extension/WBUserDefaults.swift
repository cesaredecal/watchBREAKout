//
//  WBUserDefaults.swift
//  WatchBreakout
//
//  Created by Leo Mehlig on 6/13/15.
//  Copyright © 2015 Scholar Watch Hackathon. All rights reserved.
//

import Foundation
import UIKit
 var brickAry: [[Brick]] = WBUserDefaults.randomBreakoutStatusAry
struct WBUserDefaults {
    private struct Keys {
        static let ScoreHistory = "HighscoreHistory"
        static let BricksStatus = "BricksStatus"
        
    }
    
    struct BrickTypes {
        static let SpeedUp = UIColor(red:0.204, green:0.596, blue:0.859, alpha:1.0)
        static let SlowDown = UIColor(red:0.906, green:0.298, blue:0.235, alpha:1.0)
        static let BonusPoints = UIColor(red:0.608, green:0.349, blue:0.714, alpha:1.0)
        ////            private static let greenBrick = UIColor(red:0.086, green:0.627, blue:0.522, alpha:1.0)
        static let Normal = UIColor.whiteColor()
        static var randomBrickType: UIColor {
            let rnd = randomInt(0, max: 100)
            if (rnd >= 0 && rnd <= 15){
                return BrickTypes.SlowDown
            } else if (rnd >= 20 && rnd <= 37){
                return BrickTypes.SpeedUp
            }else if (rnd >= 40 && rnd <= 45){
                return BrickTypes.BonusPoints
            }
            return BrickTypes.Normal
        }
        private static func randomInt(min: Int, max:Int) -> Int {
            return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        }
    }
    
    
    private static let userDefault = NSUserDefaults.standardUserDefaults()
    private static let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
        }()
    
    static var scoreHistory: [NSDate : Int] {
        get {
        var dict: [NSDate : Int] = [:]
        for (str, number) in userDefault.dictionaryForKey(Keys.ScoreHistory) ?? [:] {
        if let date = dateFormatter.dateFromString(str), let i = number as? Int {
        dict[date] = i
        }
        }
        return dict
        }
        set {
            var dict: [String : NSNumber] = [:]
            for (date, i) in newValue {
                dict[dateFormatter.stringFromDate(date)] = NSNumber(integer: i)
                
            }
            userDefault.setObject(dict, forKey: Keys.ScoreHistory)
        }
    }
    
    static var earliestScoreDate: NSDate? {
        let sortedDateAry = Array(scoreHistory.keys).sort { (first, last) -> Bool in
            return first.earlierDate(last) == first
        }
        return sortedDateAry.first
        
    }
    
    static var highscore: Int {
        let sortedDateAry = Array(scoreHistory.values).sort { (first, last) -> Bool in
            return first < last
        }
        return sortedDateAry.last ?? 0
    }
    
    
    
    static var bricksStatusAry: [[Brick]] {
        get {
            return brickAry
        }
        set {
            if newValue.count == 5 {
                if newValue.filter({ $0.count != 4 }).isEmpty {
                    brickAry = newValue
                }
            }
        }
    }
    
    static var randomBreakoutStatusAry: [[Brick]] {
        return (0..<5).map { _ in return (0..<5).map { _ in return Brick(BrickTypes.randomBrickType)  } }
    }
    
    static func breakoutImageOfSize(size: CGSize, inSize: CGSize? = nil, ballcontroller: BallController? = nil, add: Bool) -> UIImage {
        let bricksStatus = WBUserDefaults.bricksStatusAry
        let brickHeight = (size.height - CGFloat(bricksStatus.count) * 2) / CGFloat(bricksStatus.count)
        let brickWidth = (size.width - CGFloat(bricksStatus.first?.count ?? 0) * 2) / CGFloat(bricksStatus.first?.count ?? 0)
        UIGraphicsBeginImageContext(inSize ?? size)
        for (row, rowAry) in WBUserDefaults.bricksStatusAry.enumerate() {
            for (column, brick) in rowAry.enumerate() {
                if brick.visible {
                    let x = CGFloat(column) * brickWidth + CGFloat(column) * 2
                    let y = CGFloat(row) * brickHeight + CGFloat(row) * 2
                    //print("\(x), \(y)")
                    let path = UIBezierPath(rect: CGRect(x: x, y: y, width: brickWidth, height: brickHeight))
                    if add {
                        ballcontroller?.obstacles.append(CGRect(x: x, y: y, width: brickWidth, height: brickHeight))
                    }
                    
                    brick.color.setFill()
                    path.fill()
                }
            }
        }
        
        let image =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        return image
        
    }

    
    
    
    
}

class Brick: CustomDebugStringConvertible {
    var visible: Bool
    let color: UIColor
    init(_ c: UIColor, visible v: Bool = true) {
        visible = v
        color = c
    }
    
    var debugDescription: String {
        get {
            return "\(visible)"
        }
    }
}

class Shared {
    static let sharedInstance = Shared()
    
    
}