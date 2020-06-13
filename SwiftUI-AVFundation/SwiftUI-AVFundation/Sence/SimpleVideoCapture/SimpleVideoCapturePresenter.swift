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
        var layer: AVCaptureVideoPreviewLayer?
    }

    enum Inputs {
        case onAppear
        case tappedCameraButton
        case disAppear
    }

    init() {
        self.outputs = Outputs()
        self.cancellable = interactor.$previewLayer.assign(to: \.layer, on: self.outputs)
    }

    var outputs: Outputs

    func apply(inputs: Inputs) {
        switch inputs {
            case .onAppear:
                interactor.startSettion()
            case .tappedCameraButton:
            break
            case .disAppear:
                interactor.stopSettion()
                cancellable.cancel()
        }
    }

    // MARK: Privates
    private var cancellable: Cancellable
    private let interactor = SimpleVideoCaptureInteractor()
}
