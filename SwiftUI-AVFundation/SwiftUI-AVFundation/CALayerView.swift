//
//  CALayerView.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/07.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import SwiftUI

struct CALayerViewController: UIViewControllerRepresentable {
    var caLayer:CALayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerViewController>) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerViewController>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}

struct CALayerView2: UIViewRepresentable {

    var caLayer: CALayer
    typealias UIViewType = UIView

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(caLayer)
        caLayer.frame = view.layer.frame
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        caLayer.frame = uiView.layer.frame
    }
}
