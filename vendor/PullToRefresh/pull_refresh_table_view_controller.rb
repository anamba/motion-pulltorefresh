# pull_refresh_table_view_controller.rb
# Adapted for RubyMotion by Aaron Namba on 2012-05-12
# 
# //
# //  PullRefreshTableViewController.m
# //  Plancast
# //
# //  Created by Leah Culver on 7/2/10.
# //  Copyright (c) 2010 Leah Culver
# //
# //  Permission is hereby granted, free of charge, to any person
# //  obtaining a copy of this software and associated documentation
# //  files (the "Software"), to deal in the Software without
# //  restriction, including without limitation the rights to use,
# //  copy, modify, merge, publish, distribute, sublicense, and/or sell
# //  copies of the Software, and to permit persons to whom the
# //  Software is furnished to do so, subject to the following
# //  conditions:
# //
# //  The above copyright notice and this permission notice shall be
# //  included in all copies or substantial portions of the Software.
# //
# //  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# //  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# //  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# //  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# //  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# //  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# //  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# //  OTHER DEALINGS IN THE SOFTWARE.
# //

class PullRefreshTableViewController < UITableViewController
  attr_accessor :isLoading, :isDragging, :textPull, :textRelease, :textLoading, :refreshHeaderView, :refreshLabel, :refreshArrow, :refreshSpinner
  
  REFRESH_HEADER_HEIGHT = 52.0
  
  def initWithStyle(style)
    obj = super(style)
    obj.setupStrings if obj
    obj
  end
  
  def initWithCoder(aDecoder)
    obj = super(aDecoder)
    obj.setupStrings if obj
    obj
  end
  
  def initWithNibName(nibNameOrNil, bundle:nibBundleOrNil)
    obj = super(nibNameOrNil, bundle:nibBundleOrNil)
    obj.setupStrings if obj 
    obj
  end
  
  def viewDidLoad
    super
    addPullToRefreshHeader
  end
  
  def setupStrings
    self.textPull = "Pull down to refresh..."
    self.textRelease = "Release to refresh..."
    self.textLoading = "Loading..."
  end
  
  def addPullToRefreshHeader
    self.refreshHeaderView = UIView.alloc.initWithFrame(CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT))
    refreshHeaderView.backgroundColor = UIColor.clearColor
    
    self.refreshLabel = UILabel.alloc.initWithFrame(CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT))
    refreshLabel.backgroundColor = UIColor.clearColor
    refreshLabel.font = UIFont.boldSystemFontOfSize(12.0)
    refreshLabel.textAlignment = UITextAlignmentCenter
    
    self.refreshArrow = UIImageView.alloc.initWithImage(UIImage.imageNamed("arrow.png"))
    refreshArrow.frame = CGRectMake(((REFRESH_HEADER_HEIGHT - 27) / 2).floor,
                                    ((REFRESH_HEADER_HEIGHT - 44) / 2).floor,
                                    27, 44)
    
    self.refreshSpinner = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    refreshSpinner.frame = CGRectMake(((REFRESH_HEADER_HEIGHT - 20) / 2).floor,
                                      ((REFRESH_HEADER_HEIGHT - 20) / 2).floor,
                                      20, 20);
    refreshSpinner.hidesWhenStopped = true;
    
    refreshHeaderView.addSubview(refreshLabel)
    refreshHeaderView.addSubview(refreshArrow)
    refreshHeaderView.addSubview(refreshSpinner)
    self.tableView.addSubview(refreshHeaderView)
  end
  
  def scrollViewWillBeginDragging(scrollView)
    return if isLoading
    self.isDragging = true
  end
  
  def scrollViewDidScroll(scrollView)
    if isLoading
      # Update the content inset, good for section headers
      if scrollView.contentOffset.y > 0
        self.tableView.contentInset = UIEdgeInsetsZero
      elsif scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT
        self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
      end
    elsif isDragging && scrollView.contentOffset.y < 0
      # Update the arrow direction and label
      UIView.beginAnimations(nil, context:nil)
      if scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT
        # User is scrolling above the header
        refreshLabel.text = textRelease
        refreshArrow.layer.transform = CATransform3DMakeRotation(Math::PI, 0, 0, 1)
      else # User is scrolling somewhere within the header
        refreshLabel.text = textPull
        refreshArrow.layer.transform = CATransform3DMakeRotation(Math::PI * 2, 0, 0, 1)
      end
      UIView.commitAnimations
    end
  end
  
  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    return if isLoading
    self.isDragging = false
    if scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT
      # Released above the header
      self.startLoading
    end
  end
  
  def startLoading
    self.isLoading = true
    
    # Show the header
    UIView.beginAnimations(nil, context:nil)
    UIView.setAnimationDuration(0.3)
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0)
    refreshLabel.text = self.textLoading
    refreshArrow.hidden = true
    refreshSpinner.startAnimating
    UIView.commitAnimations
    
    # Refresh action!
    refresh
  end
  
  def stopLoading
    self.isLoading = false
    
    # Hide the header
    UIView.beginAnimations(nil, context:nil)
    UIView.setAnimationDelegate(self)
    UIView.setAnimationDuration(0.3)
    UIView.setAnimationDidStopSelector('stopLoadingComplete:finished:context:')
    self.tableView.contentInset = UIEdgeInsetsZero
    tableContentInset = self.tableView.contentInset
    tableContentInset.top = 0.0
    self.tableView.contentInset = tableContentInset
    refreshArrow.layer.transform = CATransform3DMakeRotation(Math::PI * 2, 0, 0, 1)
    UIView.commitAnimations
  end
  
  def stopLoadingComplete(animationID, finished:finished, context:context)
    # Reset the header
    refreshLabel.text = self.textPull
    refreshArrow.hidden = false
    refreshSpinner.stopAnimating
  end
  
  def refresh
    # This is just a demo. Override this method with your custom reload action.
    # Don't forget to call stopLoading at the end.
    self.performSelector(:stopLoading, withObject:nil, afterDelay:2.0)
  end
  
end