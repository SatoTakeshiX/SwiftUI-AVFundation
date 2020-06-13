//
//  SimpleVideoCapturePresenter.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/13.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import Foundation
import AVKit
import Combine

final class SimpleVideoCapturePresenter: ObservableObject {

    final class Outputs: ObservableObject {
        var layer: CALayer = CALayer()
    }

    enum Inputs {
        case onAppear
        case tappedCameraButton
        case onDisappear
    }

    init() {
        self.outputs = Outputs()
    }

    var outputs: Outputs

    func apply(inputs: Inputs) {
        switch inputs {
            case .onAppear:
                bind()
                interactor.startSettion()
            case .tappedCameraButton:
            break
            case .onDisappear:
                interactor.stopSettion()
                cancellable?.cancel()
        }
    }

    // MARK: Privates
    private var cancellable: Cancellable?
    private let interactor = SimpleVideoCaptureInteractor()

    private func bind() {
        self.cancellable = interactor.$previewLayer.sink(receiveValue: { (previewLayer) in
            self.outputs.layer = previewLayer ?? CALayer()
        })
    }
}
