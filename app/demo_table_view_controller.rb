# demo_table_view_controller.rb
# Adapted for RubyMotion by Aaron Namba on 2012-05-12
# 
# //
# //  RootViewController.m
# //  PullToRefresh
# //
# //  Created by Leah Culver on 7/25/10.
# //  Copyright Plancast 2010. All rights reserved.
# //

class DemoTableViewController < PullRefreshTableViewController
  attr_accessor :items
  
  def viewDidLoad
    super
    
    self.title = "Pull to Refresh"
    self.items = ["What time is it?"]
  end
  
  def numberOfSectionsInTableView(tableView)
    1
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    items.size
  end
  
  CellIdentifier = "CellIdentifier"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CellIdentifier)
    cell.textLabel.text = items.objectAtIndex(indexPath.row)
    cell.selectionStyle = UITableViewCellSelectionStyleNone
    
    cell
  end
  
  def refresh
    self.performSelector(:addItem, withObject:nil, afterDelay:2.0)
  end
  
  def addItem
    # Add a new time
    items.unshift(Time.now.to_s)
    
    self.tableView.reloadData
    
    self.stopLoading
  end
  
end
