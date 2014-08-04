//
//  CompletionTableView.swift
//  Eagolf
//
//  Created by Louis BODART on 04/08/2014.
//  Copyright (c) 2014 Louis BODART. All rights reserved.
//

import Foundation
import UIKit

class CompletionTableView : UITableView, UITableViewDataSource
{
    let relatedTextField : UITextField
    let searchInArray : [String]
    
    var maxResultsToShow : Int = 0
    var resultsArray : [String] = []
    var selectedElements : [String] = []
    var completionsRegex : [String] = ["^#@"]
    
    init(relatedTextField: UITextField, searchInArray: [String])
    {
        self.relatedTextField = relatedTextField
        self.searchInArray = searchInArray
        let customFrame = CGRectMake(self.relatedTextField.frame.origin.x, self.relatedTextField.frame.origin.y + self.relatedTextField.frame.height, self.relatedTextField.frame.width, 0)
        super.init(frame: customFrame, style: UITableViewStyle.Plain)
        self.hidden = true
        self.dataSource = self
    }
    
    func tryCompletion(withValue: String, animated: Bool)
    {
        if withValue.isEmpty {
            self.hide(true)
            return
        }
        
        self.resultsArray.removeAll(keepCapacity: false)
        var maxResultsReached = false
        for regexString in self.completionsRegex {
            let pattern = regexString.stringByReplacingOccurrencesOfString("#@", withString: withValue, options: nil, range: nil)
            let regex = NSRegularExpression(pattern: pattern as String, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
            
            for entry in self.searchInArray {
                if self.resultsArray.count >= self.maxResultsToShow && self.maxResultsToShow != 0 {
                    maxResultsReached = true
                    break
                }
                
                let matches = regex.matchesInString(entry, options: nil, range: NSMakeRange(0, countElements(entry)))
                if matches.count > 0 && !contains(self.resultsArray, entry) && !contains(self.selectedElements, entry) {
                    self.resultsArray.append(entry)
                }
            }
            
            if maxResultsReached {
                break
            }
        }
        
        self.reloadData()
        self.hidden = false
        
        self.show(animated)
    }
    
    func selectElement(element: String)
    {
        let tmpArray = self.selectedElements.bridgeToObjectiveC()
        if tmpArray.indexOfObject(element) != NSNotFound {
            return
        }
        self.selectedElements.append(element)
    }
    
    func deselectElement(element: String)
    {
        let tmpArray = self.selectedElements.bridgeToObjectiveC()
        let indexToRemove = tmpArray.indexOfObject(element)
        if indexToRemove == NSNotFound {
            return
        }
        self.selectedElements.removeAtIndex(indexToRemove)
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.resultsArray.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var cell : UITableViewCell = UITableViewCell()
        cell.textLabel.text = self.resultsArray[indexPath.row] as String
        return cell
    }
    
    func show(animated: Bool)
    {
        var newRect = self.frame
        newRect.size.height = self.rowHeight * CGFloat(self.resultsArray.count)
        
        if !animated {
            self.frame = newRect
            return
        }
        
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.frame = newRect
        })
    }
    
    func hide(animated: Bool)
    {
        let originRect = CGRect(x: self.relatedTextField.frame.origin.x, y: self.relatedTextField.frame.origin.y + self.relatedTextField.frame.height, width: self.relatedTextField.frame.width, height: self.frame.height)
        let finalRect = CGRect(x: originRect.origin.x, y: originRect.origin.y, width: originRect.width, height: 0)
        
        if !animated {
            self.frame = finalRect
            self.hidden = true
            return
        }
        
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.frame = finalRect
        }, completion: {(finished : Bool) -> Void in
            self.hidden = true
        })
    }
}
