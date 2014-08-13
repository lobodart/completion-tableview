CompletionTableView
====================

An auto-completion UITableView related to an UITextField written in Swift. Please report me any issues you have so that I can correct them.

_I'm open to any suggestion, question or anything else (especially my english if needed :p) ! Just ask me !_

##Getting started
The CompletionTableView is very simple to implement in all your projects. Let's take an example with a field which search some fruit names in a list.
First, you need to create 3 class variables:

The related text field (should be an IBOutlet),
```Swift
var searchTextField: UITextField!
```
the CompletionTableView,
```Swift
var fruitsCompletionView: CompletionTableView!
```
and the array which contains the values you want to search
```Swift
let allFruits: [String] = ["Orange", "Lemon", "Strawberry", "Apple", "Lime", "Raspberry"]
```

Then, you just have to instantiate your CompletionTableView anywhere you want. Usually, it's in the `viewDidLoad()` function.

```Swift
self.fruitsCompletionView = CompletionTableView(relatedTextField: self.searchTextField, inView: self.view, searchInArray: self.allFruits, tableCellNibName: nil, tableCellIdentifier: nil)
```
That's all ! Your CompletionTableView is ready !

##Use custom cells
If you want to use custom cells, just change the two lasts parameters of the CompletionTableView constructor and implement your own `cellForRowAtIndexPath()` function. Let's do this with the previous example.

- Create your own TableViewCell class and xib and link them together. For the example, we will call them respectively `CompletionTableViewCell.swift` and `CompletionTableViewCell.xib`.
- Open your xib file and add an identifier on your custom cell. We will call it `CellIdentifier`.
- Add any objects you want in your custom cell and don't forget to link them with the *File's Owner*. For the example, we will only add a label called `fruitNameLabel`.
- Now, you can instantiate your CompletionTableView.
```Swift
self.fruitsCompletionView = CompletionTableView(relatedTextField: self.searchTextField, inView: self.view, searchInArray: self.allFruits, tableCellNibName: "CompletionTableViewCell", tableCellIdentifier: "CellIdentifier")
```
- In the class which contains the CompletionTableView, create a function with the following prototype `(tableView: CompletionTableView!, indexPath: NSIndexPath!) -> UITableViewCell!`. Here there is an example:
```Swift
func fruitsCellForRowAtIndexPath(tableView: CompletionTableView!, indexPath: NSIndexPath!) -> UITableViewCell!
{
    var cell : CompletionTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.fruitsCompletion.tableCellIdentifier) as CompletionTableViewCell
    
    // You can custom your cell here
    cell.fruitNameLabel.text = self.fruitsCompletion.resultsArray[indexPath.row] as String
    return cell
}
```
- Finally, set the CompletionTableView attribute named `completionCellForRowAtIndexPath` to your custom function.
```Swift
self.fruitsCompletion.completionCellForRowAtIndexPath = self.fruitsCellForRowAtIndexPath
```
Your CompletionTableView with custom cells is now ready to use !

##Custom the `didSelectRowAtIndexPath()` function
Coming soon ...

##Additional features
Coming soon ...
