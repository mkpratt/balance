//
//  SplashViewController.swift
//  Balance
//
//  Created by Michael on 4/4/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.performSegueToLocationsView), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func performSegueToLocationsView() {
        self.performSegue(withIdentifier: "SplashToLocations", sender: nil)
    }

}
