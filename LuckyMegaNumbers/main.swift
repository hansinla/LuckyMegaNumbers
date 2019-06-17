//
//  main.swift
//  LuckyMegaNumbers
//
//  Created by Hans van Riet on 12/4/14.
//  Copyright (c) 2014 Hans van Riet. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


public extension String {
    var NS: NSString { return (self as NSString) }
}

// Downloading most recent file from CA lottery from address:
// http://www.calottery.com/sitecore/content/Miscellaneous/download-numbers/?GameName=mega-millions

// currently the MegaMillions lottery requires five winning numbers
let amountOfNumbersToPick = 5

print("Loading all winning numbers to date...", terminator: "")

let urlPath = "http://www.calottery.com/sitecore/content/Miscellaneous/download-numbers/?GameName=mega-millions"
let file = "DownloadAllMegaNumbers.txt"
let folder = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0] as String
let path = folder.NS.appendingPathComponent(file)

var fileData:String = ""

func HTTPsendRequest(_ request: NSMutableURLRequest,
    callback: @escaping (String, String?) -> Void) {
    
        let task = URLSession.dataTask(
            with: request,
            completionHandler: {
                data, response, error in
                if error != nil {
                    callback("", error!.localizedDescription)
                } else {
                    callback(
                        NSString(data: data!, encoding: String.Encoding.utf8)! as String,
                        nil
                    )
                }
        })
        
        task.resume()
}

func HTTPGet(_ url: String, callback: @escaping (String, String?) -> Void) {
    let request = NSMutableURLRequest(url: URL(string: url)!)
    HTTPsendRequest(request, callback: callback)
}

HTTPGet(urlPath) {
    (data: String, error: String?) -> Void in
    if error != nil {
        print(error ?? "Error!")
    } else {
        //println(data)
        fileData = data
    }
}

sleep(1)

print("Done!")

// Separating the file data in lottery drawings line items
var list = fileData.components(separatedBy: "\n")

// Delete the (5) header lines
for _ in 1...5 {
    list.remove(at: 0)
}

///////////////////     Print header     /////////////////////////////
var headerItems = list[0].components(separatedBy: " ") as [String]
var headerStrings = Array<String>()
var index = 0
while (headerStrings.count < 5) {
    if (headerItems[index] != "") {
        headerStrings.append(headerItems[index])
        //headerStrings.append(" ")
    }
    index += 1
}
print("Calculations based on the latest Mega millions drawing number \(headerStrings[0]) dated \(headerStrings[1]) \(headerStrings[2]) \(headerStrings[3]) \(headerStrings[4]).")

// Build an array of winning numbers and an array of winning Mega numbers
var arrayOfWinningNumbers = Array<Int>()
var arrayOfWinningMegaNumbers = Array<Int>()

for drawing in list{
    var drawingElements = Array<String>()
    var lineItems = drawing.components(separatedBy: " ") as [String]
    
    if (Int(lineItems[0]) >= 870) {
        // These are the new style drawings since October 19, 2013 and we'll use them
        for item in lineItems {
            if (item != "") {
                drawingElements.append(item)
            }
        }

        // now lose the first five items in the list, theses are drawing numbers and dates
        for _ in 1...5 {
            drawingElements.remove(at: 0)
        }
        
        // Add the winning numbers to the master arrays
        for index in 0...4 {
            arrayOfWinningNumbers.append(Int(drawingElements[index])!)
        }
        arrayOfWinningMegaNumbers.append(Int(drawingElements[5])!)

        
    } else {
        
        // These are old style drawings prior to October 19, 2013 and we disgard them
        
    }
}

let totalDrawings = arrayOfWinningMegaNumbers.count
print("Total number of drawings used for this analysis: \(totalDrawings)")

// Determining the frequency of winning numbers and mega numbers
// New Style numbers between 1 and 75 inclusive, mega number between 1 and 15 inclusive
var lotteryNumbers = Array(repeating: 0, count: 75)
var megaNumbers = Array(repeating: 0, count: 15)

// Tally up the winning lottery numbers
for winningNumber in arrayOfWinningNumbers {
    lotteryNumbers[winningNumber - 1] += 1
}

// Tally up the winning Mega Numbers
for megaNumber in arrayOfWinningMegaNumbers {
    megaNumbers[megaNumber - 1] += 1
}

// Now build new arrays based on the frequency of drawn numbers
var lotteryNumberPool = Array<Int>()
var megaNumberPool = Array<Int>()

//let lotMax = lotteryNumbers.reduce(Int.min, { max($0, $1) })
//let megaMax = megaNumbers.reduce(Int.min, { max($0, $1) })

// println("lotmax : \(lotMax)")
// println("megaMax : \(megaMax)")


// Fill the array with lottery numbers.
// Amount of occurences is total drawing minus amount of times the number has been drawn already.
for index in 0..<75 {
    var loopValue = totalDrawings - lotteryNumbers[index]
    for _ in 1...loopValue {
        lotteryNumberPool.append(index + 1)
    }
}

for index in 0..<15 {
    var loopValue = totalDrawings - megaNumbers[index]
    for _ in 1...loopValue {
        megaNumberPool.append(index + 1)
    }
}

// println(lotteryNumberPool)
// println(megaNumberPool)

// Finally, draw from the array our (hopefully) winning numbers
var lotteryPicks = Array<Int>()
var upperlimit = UInt32(lotteryNumberPool.count)

repeat {
    var currentPickIndex = Int(arc4random_uniform(upperlimit + 1))
    var currentPick = lotteryNumberPool[currentPickIndex]
    if !(lotteryPicks.contains(currentPick)) {
        lotteryPicks.append(currentPick)
    }
    
} while (lotteryPicks.count < amountOfNumbersToPick)

lotteryPicks.sort { $0 < $1 }
print("This week's winning numbers: \(lotteryPicks)")

var megaPicks = Array<Int>()
upperlimit = UInt32(megaNumberPool.count)

var currentPickIndex = Int(arc4random_uniform(upperlimit + 1))
var currentPick = megaNumberPool[currentPickIndex]

print("Meganumber: \(currentPick)")

// fileData.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
print("Done!")

