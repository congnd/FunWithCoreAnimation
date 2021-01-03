//
//  ViewController.swift
//  FunWithCoreAnimation
//
//  Created by Nguyen, Cong on 2020/12/29.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let animationView = AnimationView(frame: UIScreen.main.bounds)
    animationView.backgroundColor = .white
    view.addSubview(animationView)

    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      animationView.emit()
    }
  }
}
