//
//  SampleViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 11/3/21.
//

import UIKit

class SampleViewController: UITableViewController {
    
    var gradientView : GradientView =  {
        let gv  = GradientView()
        gv.endColor = UIColor.rgb(red: 253, green: 187, blue: 45)
        gv.startColor = UIColor.rgb(red: 34, green: 193, blue: 195)
        gv.locations = [0, 1.75]
        return gv
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.backgroundView = gradientView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.backgroundColor = .orange
        
        // bubble
        let config = BackgroundConfig()
        config.color = .yellow
        let bubble = BackgroundFactory.shared.getBackground(config: config)
        
        // configure maskLayer to show gradient
        let bubbleMaskLayer = CALayer()
        bubbleMaskLayer.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        bubbleMaskLayer.contents = UIImage(systemName: "circle")?.cgImage
        //cell.contentView.layer.mask = bubbleMaskLayer
        // Configure the cell...

        cell.textLabel?.text = "Hello"
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
