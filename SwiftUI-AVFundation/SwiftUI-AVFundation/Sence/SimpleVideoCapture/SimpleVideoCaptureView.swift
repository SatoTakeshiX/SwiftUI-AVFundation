//
//  SimpleVideoCaptureView.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/13.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import SwiftUI

extension CALayer: ObservableObject {}

struct SimpleVideoCaptureView: View {
    @ObservedObject
    var presenter: SimpleVideoCapturePresenter
    var body: some View {
        ZStack {
            CALayerView(caLayer: presenter.previewLayer)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.presenter.apply(inputs: .onAppear)
        }
        .onDisappear {
            self.presenter.apply(inputs: .onDisappear)
        }
        .sheet(isPresented: $presenter.showSheet) {
            VStack {
                Image(uiImage: self.presenter.photoImage)
                .resizable()
                .frame(width: 200, height: 200)
                Button(action: {
                    self.presenter.apply(inputs: .tappedCloseButton)
                }) {
                    Text("Close")
                }
            }
        }
    }
}

struct SimpleVideoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleVideoCaptureView(presenter: SimpleVideoCapturePresenter())
    }
}

struct CALayerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    var caLayer: CALayer

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}
