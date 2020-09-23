//
//  TapGridView.swift
//  TapGrid
//
//  Created by Ben Mikailenko on 3/9/20.
//  Copyright © 2020 Ben Mikailenko. All rights reserved.
//

import UIKit

@IBDesignable

class TapGridView: UIView {
    
    var tapGrid = [[0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0],
                   [0,0,0,2,1,0,0,0],
                   [0,0,0,1,2,0,0,0],
                   [0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0]]
    
    var turn = 1
    var score = [0,2,2]
    var chipsFlipped = 0
    var gameOver = false
        
    override func draw(_ rect: CGRect) {
        // dimensions of each individual square
        let sqHeight = bounds.height / 8
        let sqWidth  = bounds.width / 8
        
        // temporary text and attributes to make text fit snug into the frame
        let temptext = "0" as NSString
        let tempattributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 30),
            .foregroundColor: UIColor.black
        ]
        
        // text attributes based on temporary text and attributes
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize:
                (30 * min(
                    sqWidth/temptext.size(withAttributes: tempattributes).width,
                    sqHeight/temptext.size(withAttributes: tempattributes).height))),
        .foregroundColor: UIColor.black
        ]
        
        // bold text attributes based on temporary text and attributes
        let boldAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.boldSystemFont(ofSize:
                (30 * min(
                    sqWidth/temptext.size(withAttributes: tempattributes).width,
                    sqHeight/temptext.size(withAttributes: tempattributes).height))),
        .foregroundColor: UIColor.black
        ]
        
        // draw the outside border
        let border = UIBezierPath()
        border.lineWidth = 3
        border.move(to: CGPoint(x: 0, y: 0))
        border.addLine(to: CGPoint(x: bounds.width, y: 0))
        border.move(to: CGPoint(x: 0, y: bounds.height))
        border.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        border.move(to: CGPoint(x: 0, y: 0))
        border.addLine(to: CGPoint(x: 0, y: bounds.height))
        border.move(to: CGPoint(x: bounds.width, y: 0))
        border.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        UIColor.black.setStroke()
        border.stroke()
        
        // score for player 1
        var blackScoreText = String(score[1]) as NSString
        if (gameOver == true) {
            if (winner() == 1) {
                blackScoreText = "W" as NSString
            }
            if (winner() == 2) {
                blackScoreText = "L" as NSString
            }
            if (winner() == 0) {
                blackScoreText = "T" as NSString
            }
        }
        if (turn == 1) {
            blackScoreText.draw(at: CGPoint(
            x: (CGFloat(0) * sqWidth)  + (sqWidth  - blackScoreText.size(withAttributes: boldAttributes).width ) / 2,
            y: (CGFloat(7) * sqHeight) + (sqHeight - blackScoreText.size(withAttributes: boldAttributes).height) / 2),
                        withAttributes: boldAttributes)
        }
        else {
            blackScoreText.draw(at: CGPoint(
            x: (CGFloat(0) * sqWidth)  + (sqWidth  - blackScoreText.size(withAttributes: attributes).width ) / 2,
            y: (CGFloat(7) * sqHeight) + (sqHeight - blackScoreText.size(withAttributes: attributes).height) / 2),
                        withAttributes: attributes)
        }
        
        
        // score for player 2
        var redScoreText = String(score[2]) as NSString
        if (gameOver == true) {
            if (winner() == 1) {
                redScoreText = "L" as NSString
            }
            if (winner() == 2) {
                redScoreText = "W" as NSString
            }
            if (winner() == 0) {
                redScoreText = "T" as NSString
            }
        }
        if (turn == 2) {
            redScoreText.draw(at: CGPoint(
            x: (CGFloat(7) * sqWidth)  + (sqWidth  - redScoreText.size(withAttributes: boldAttributes).width ) / 2,
            y: (CGFloat(7) * sqHeight) + (sqHeight - redScoreText.size(withAttributes: boldAttributes).height) / 2),
                        withAttributes: boldAttributes)
        }
        else {
            redScoreText.draw(at: CGPoint(
            x: (CGFloat(7) * sqWidth)  + (sqWidth  - redScoreText.size(withAttributes: attributes).width ) / 2,
            y: (CGFloat(7) * sqHeight) + (sqHeight - redScoreText.size(withAttributes: attributes).height) / 2),
                        withAttributes: attributes)
        }
        
        
        // for every element in tapGrid
        for k in 0...7 {
            for i in 0...7 {
                // make an appropriate size chip
                let chip = UIBezierPath(ovalIn: CGRect(x: (CGFloat(k) * sqWidth) + (sqWidth - (sqWidth/2.3))/3,
                y: (CGFloat(i) * sqHeight) + (sqHeight - (sqHeight/2.3))/3,
                width:sqWidth/1.7, height: sqHeight/1.7))
                
                // place the black chips
                if (tapGrid[k][i] == 1) {
                    UIColor.black.setFill()
                    chip.fill()
                    chip.stroke()
                }

                // place the red chips
                if (tapGrid[k][i] == 2) {
                    UIColor.red.setFill()
                    chip.fill()
                    chip.stroke()
                }
                
                // draw the squares in the board
                let square = CGRect(x: CGFloat(k) * sqWidth, y: CGFloat(i) * sqHeight, width: sqWidth, height: sqHeight)
                let rect = UIBezierPath(rect: square)
                rect.lineWidth = 3
                rect.stroke()
                
            }
        }
    }
    
    @IBAction func handleTap(_ sender: UIGestureRecognizer) {
        // get index x and y
        // where tap location is in domains [0, 8] (tapGrid domain)
        let tapPoint = sender.location(in: self)
        let x = Int((tapPoint.x / self.bounds.width) * 8)
        var y = Int((tapPoint.y / self.bounds.height) * 8)
        
        // because x has only 8 pixels to edge, its fine
        // but y has alot of headroom
        // so when converting tapPoint.y / self.bounds.height
        // it can make the area above the grid still tappable
        // revert y to -1 when -1 < y < 0 to fix this
        if ((tapPoint.y / self.bounds.height) < 0) {
            y = -1
        }
        
        if (gameOver) {
            resetBoard()
            gameOver = false
            score = [0,0,0]
        }
        else {
            // if x and y is in the domain of tapGrid
            // increment the tapGrid value at tap
            if (0 <= x && x <= 7 && 0 <= y && y <= 7) {
                // value = 0 if 8
                if (tapGrid[x][y] == 0) {
                    if (turn == 1){ // player 1's turn
                        tapGrid[x][y] = 1 // place the chip
                        if (flipChips(x: x, y: y) > 0) { // if the chips flipped atleast one chip
                            score[1] += chipsFlipped // update score
                            score[2] -= chipsFlipped - 1
                            if (boardFull()) {
                                gameOver = true
                            }
                            turn = 2 // change to player 2's turn
                        }
                        else { // else undo and still player 1's turn
                            tapGrid[x][y] = 0
                        }
                    } else { // player 2's turn
                        tapGrid[x][y] = 2 // place the chip
                        if (flipChips(x: x, y: y) > 0) { // if the chips flipped atleast one chip
                            score[1] -= chipsFlipped - 1 // update score
                            score[2] += chipsFlipped
                            if (boardFull()) {
                                gameOver = true
                            }
                            turn = 1 // change to player 1's turn
                        }
                        else { // else undo and still player 2's turn
                            tapGrid[x][y] = 0
                        }
                    }
                }
            }
        }
        setNeedsDisplay()
    }
    
    // function returns the other player's number
    func otherPlayer() -> Int {
        if (turn == 1) {
            return 2
        }
        if (turn == 2) {
            return 1
        }
        return 0
    }
    
    func boardFull() -> Bool {
        for i in 0...7 {
            for k in 0...7 {
                if (tapGrid[i][k] == 0) {
                    return false
                }
            }
        }
        return true
    }
    
    func resetBoard() {
        tapGrid = [[0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0],
        [0,0,0,2,1,0,0,0],
        [0,0,0,1,2,0,0,0],
        [0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0]]
    }
    
    func winner() -> Int {
        if (score[1] > score[2]) {
            return 1
        }
        if (score[2] > score[1]) {
            return 2
        }
        return 0
    }
    
    //
    // function flips chips in game board
    // returns the number of chips flipped to other color
    //
    func flipChips(x: Int , y: Int) -> Int{
        var xCheck = x
        var yCheck = y
        let tempTapGrid = tapGrid
        var chipFlipCount = 0
        
        // flip right side of placed chip
        while xCheck < 7 {
            xCheck += 1
            if (tapGrid[xCheck][y] == turn) {
                while xCheck > x {
                    xCheck -= 1
                    if (tapGrid[xCheck][y] != 0) {
                        if (tapGrid[xCheck][y] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[xCheck][y] = turn
                    }
                }
            break
            }
        }
        
        // flip left side of placed chip
        xCheck = x
        while xCheck > 0 {
            xCheck -= 1
            if (tapGrid[xCheck][y] == turn) {
                while xCheck < x {
                    xCheck += 1
                    if (tapGrid[xCheck][y] != 0) {
                        if (tapGrid[xCheck][y] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[xCheck][y] = turn
                    }
                }
            break
            }
        }
        
        // flip above placed chip
        while yCheck < 7 {
            yCheck += 1
            if (tapGrid[x][yCheck] == turn) {
                while yCheck > y {
                    yCheck -= 1
                    if (tapGrid[x][yCheck] != 0) {
                        if (tapGrid[x][yCheck] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[x][yCheck] = turn
                    }
                }
            break
            }
        }
        
        // flip below placed chip
        yCheck = y
        while yCheck > 0 {
            yCheck -= 1
            if (tapGrid[x][yCheck] == turn) {
                while yCheck < y {
                    yCheck += 1
                    if (tapGrid[x][yCheck] != 0) {
                        if (tapGrid[x][yCheck] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[x][yCheck] = turn
                    }
                }
            break
            }
        }
        
        // flip NW side of chip
        xCheck = x
        yCheck = y
        while xCheck < 7 && yCheck < 7 {
            xCheck += 1
            yCheck += 1
            if (tapGrid[xCheck][yCheck] == turn) {
                while xCheck > x && yCheck > y {
                    xCheck -= 1
                    yCheck -= 1
                    if (tapGrid[xCheck][yCheck] != 0) {
                        if (tapGrid[xCheck][yCheck] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[xCheck][yCheck] = turn
                    }
                }
            break
            }
        }
        
        // flip SE side of chip
        xCheck = x
        yCheck = y
        while xCheck > 0 && yCheck > 0 {
            xCheck -= 1
            yCheck -= 1
            if (tapGrid[xCheck][yCheck] == turn) {
                while xCheck < x && yCheck < y {
                    xCheck += 1
                    yCheck += 1
                    if (tapGrid[xCheck][yCheck] != 0) {
                        if (tapGrid[xCheck][yCheck] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[xCheck][yCheck] = turn
                    }
                }
            break
            }
        }
        
        // flip SW side of chip
        xCheck = x
        yCheck = y
        while xCheck < 7 && yCheck > 0 {
            xCheck += 1
            yCheck -= 1
            if (tapGrid[xCheck][yCheck] == turn) {
                while xCheck > x && yCheck < y {
                    xCheck -= 1
                    yCheck += 1
                    if (tapGrid[xCheck][yCheck] != 0) {
                        if (tapGrid[xCheck][yCheck] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[xCheck][yCheck] = turn
                    }
                }
            break
            }
        }
        
        // flip NE side of chip
        xCheck = x
        yCheck = y
        while xCheck > 0 && yCheck < 7 {
            xCheck -= 1
            yCheck += 1
            if (tapGrid[xCheck][yCheck] == turn) {
                while xCheck < x && yCheck > y {
                    xCheck += 1
                    yCheck -= 1
                    if (tapGrid[xCheck][yCheck] != 0) {
                        if (tapGrid[xCheck][yCheck] == otherPlayer()) {
                            chipFlipCount += 1
                        }
                        tapGrid[xCheck][yCheck] = turn
                    }
                }
            break
            }
        }
        
        if (chipFlipCount == 0) {
            chipsFlipped = 0
            tapGrid = tempTapGrid
            return 0
        }
        
        else {
            chipsFlipped = chipFlipCount + 1
            print("chips flipped = " + String(chipsFlipped))
            return chipFlipCount
        }
    }
}
