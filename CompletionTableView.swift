//
//  CompletionTableView.swift
//  completion-tableview
//
//  Created by Louis BODART on 04/08/2014.
//  Copyright (c) 2014 Louis BODART. All rights reserved.
//

import Foundation
import UIKit

class CompletionTableView : UITableView, UITableViewDelegate, UITableViewDataSource
{
    var relatedTextField : UITextField?
    var searchInArray : [String]!
    var tableCellIdentifier : String?
    var inView : UIView!
    
    var maxResultsToShow : Int = 5
    var maxSelectedElements : Int = 1
    var showSelected : Bool = false
    var resultsArray : [String] = []
    var selectedElements : [String] = []
    var completionsRegex : [String] = ["^#@"]
    var completionCellForRowAtIndexPath : ((tableView: CompletionTableView!, indexPath: NSIndexPath!) -> UITableViewCell!)? = nil
    var completionDidSelectRowAtIndexPath : ((tableView: CompletionTableView!, indexPath: NSIndexPath!) -> Void)? = nil
    
    init(relatedTextField: UITextField, inView: UIView, searchInArray: [String], tableCellNibName: String?, tableCellIdentifier: String?)
    {
        self.relatedTextField = relatedTextField
        self.searchInArray = searchInArray
        self.tableCellIdentifier = tableCellIdentifier
        self.inView = inView
        let customFrame = CGRectMake(self.relatedTextField!.frame.origin.x, self.relatedTextField!.frame.origin.y + self.relatedTextField!.frame.height, self.relatedTextField!.frame.width, 0)
        super.init(frame: customFrame, style: UITableViewStyle.Plain)
        self.rowHeight = 44.0
        
        if tableCellNibName != nil {
            self.registerNib(UINib(nibName: tableCellNibName!, bundle: nil), forCellReuseIdentifier: tableCellIdentifier!)
            if self.tableCellIdentifier == nil {
                fatalError("Identifier must be set when nib name is not nil")
            }
            var tmpCell: UITableViewCell? = self.dequeueReusableCellWithIdentifier(self.tableCellIdentifier!) as? UITableViewCell
            if (tmpCell) == nil {
                fatalError("No such object exists in the reusable-cell queue")
            }
            self.rowHeight = tmpCell!.frame.height
        }
        
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.layer.cornerRadius = 5.0
        self.delegate = self
        self.dataSource = self
        self.bounces = false
        self.inView.addSubview(self)
        self.relatedTextField!.addTarget(self, action: "onRelatedTextFieldEditingChanged:", forControlEvents: UIControlEvents.EditingChanged)
        self.relatedTextField!.addTarget(self, action: "onRelatedTextFieldEndEditing:", forControlEvents: UIControlEvents.EditingDidEnd)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func onRelatedTextFieldEditingChanged(sender: UITextField)
    {
        self.tryCompletion(sender.text, animated: true)
    }
    
    func onRelatedTextFieldEndEditing(sender: UITextField)
    {
        self.hide(true)
        self.relatedTextField!.text = ""
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
                
                let matches = regex!.matchesInString(entry, options: nil, range: NSMakeRange(0, count(entry)))
                if matches.count > 0 && !contains(self.resultsArray, entry) && (self.showSelected ? true : !contains(self.selectedElements, entry)) {
                    self.resultsArray.append(entry)
                }
            }
            
            if maxResultsReached {
                break
            }
        }
        
        self.reloadData()
        self.inView.bringSubviewToFront(self)
        self.show(animated)
    }
    
    func selectElement(element: String, maxSelectedElementsReached: (() -> Void)?) -> Bool
    {
        let tmpArray = NSArray(array: self.selectedElements)
        if tmpArray.indexOfObject(element) != NSNotFound {
            return true
        }
        if self.selectedElements.count >= self.maxSelectedElements && self.maxSelectedElements != 0 {
            if maxSelectedElementsReached != nil {
                maxSelectedElementsReached!()
            }
            return false
        }
        self.selectedElements.append(element)
        return true
    }
    
    func elementIsSelected(element: String) -> Bool
    {
        return contains(self.selectedElements, element)
    }
    
    func deselectElement(element: String)
    {
        let tmpArray = NSArray(array: self.selectedElements)
        let indexToRemove = tmpArray.indexOfObject(element)
        if indexToRemove == NSNotFound {
            return
        }
        self.selectedElements.removeAtIndex(indexToRemove)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.resultsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if self.completionCellForRowAtIndexPath == nil {
            var cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Identifier")
            
            cell.textLabel!.text = self.resultsArray[indexPath.row] as String
            return cell
        }
        return self.completionCellForRowAtIndexPath!(tableView: tableView as! CompletionTableView, indexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if self.completionDidSelectRowAtIndexPath != nil {
            self.completionDidSelectRowAtIndexPath!(tableView: tableView as! CompletionTableView, indexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
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
        let originRect = CGRect(x: self.relatedTextField!.frame.origin.x, y: self.relatedTextField!.frame.origin.y + self.relatedTextField!.frame.height, width: self.relatedTextField!.frame.width, height: self.frame.height)
        let finalRect = CGRect(x: originRect.origin.x, y: originRect.origin.y, width: originRect.width, height: 0)
        
        if !animated {
            self.frame = finalRect
            return
        }
        
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.frame = finalRect
        })
    }
}
