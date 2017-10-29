//
//  ListenTagsViewController.swift
//  RWExample
//
//  Created by Joe Zobkiw on 9/23/17.
//  Copyright © 2017 Roundware. All rights reserved.
//

import UIKit
import Foundation
import RWFramework

class ListenTagsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // getUIConfig provides a simplified UIConfig struct that allows the UI to get to what it needs without complex parsing
    var uiconfig = RWFramework.sharedInstance.getUIConfig()
    // getListenTagsSet provides a Set of the currently selected tag IDs within the UIConfig struct
    var selectedTagIDs = RWFramework.sharedInstance.getListenTagsSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update the UI by adding the proper number of segments named appropriately, select the first one and update the header label.
        segmentedControl.removeAllSegments()
        if let uiconfig = self.uiconfig {
            for listen in uiconfig.listen {
                segmentedControl.insertSegment(withTitle: listen.group_short_name, at: segmentedControl.numberOfSegments, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 0
            updateHeaderLabel()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.performSegue(withIdentifier: "unwindToListenViewController", sender: self)
    }
    
    // When the segment is tapped, update the table and header label for that item
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        updateHeaderLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    
    func updateHeaderLabel() {
        guard uiconfig != nil else {
            return
        }
        headerLabel.text = uiconfig!.listen[segmentedControl.selectedSegmentIndex].header_display_text
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard uiconfig != nil, segmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment else {
            return 0
        }
        return uiconfig!.listen[segmentedControl.selectedSegmentIndex].display_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        guard uiconfig != nil, selectedTagIDs != nil, segmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment else {
            return cell
        }
        
        // Populate the cell with tag_display_text and checkmark if needed
        let group = uiconfig!.listen[segmentedControl.selectedSegmentIndex]
        cell.textLabel?.text = group.display_items[indexPath.row].tag_display_text
        let selected = selectedTagIDs!.contains(group.display_items[indexPath.row].tag_id)
        cell.accessoryType = selected == true ? .checkmark : .none
        
        // Tell the table the cell is selected or not so didDeselectRowAt is called on first tap
        if selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard uiconfig != nil, selectedTagIDs != nil else {
            return
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none

            // take into account single/min_one

            // Remove the newly deselected tag from the set
            let group = uiconfig!.listen[segmentedControl.selectedSegmentIndex]
            selectedTagIDs!.remove(group.display_items[indexPath.row].tag_id)
            RWFramework.sharedInstance.setListenTagsSet(selectedTagIDs!)

            // take into account single/min_one

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard uiconfig != nil, selectedTagIDs != nil else {
            return
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            
            // take into account single/min_one
            
            // Add the newly selected tag to the set
            let group = uiconfig!.listen[segmentedControl.selectedSegmentIndex]
            selectedTagIDs!.insert(group.display_items[indexPath.row].tag_id)
            RWFramework.sharedInstance.setListenTagsSet(selectedTagIDs!)
        
            // take into account single/min_one

        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
