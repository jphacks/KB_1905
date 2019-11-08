//
//  LanchScreenViewController.swift
//  JPHACKS_team5.5G
//
//  Created by 神田章博 on 2019/11/03.
//  Copyright © 2019 KandaAkihiro. All rights reserved.
//

import UIKit
import LTMorphingLabel

class LanchScreenViewController: UIViewController {

    @IBOutlet weak var animoLogo: LTMorphingLabel!
    var timer:Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timer = Timer.scheduledTimer(timeInterval: 2.0,                            //
        target: self,
        selector: #selector(LanchScreenViewController.changeView),
        userInfo: nil,
        repeats: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animoLogo.morphingEffect = .anvil
        animoLogo.text = "A-nimo"
        
    }
    
    @objc func changeView() {
        performSegue(withIdentifier: "toMain", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
