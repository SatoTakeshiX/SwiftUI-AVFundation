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

    var previewLayer: CALayer {
        return interactor.previewLayer!
    }

    enum Inputs {
        case onAppear
        case tappedCameraButton
        case onDisappear
    }

    init() {
        interactor.setupAVCaptureSession()
    }

    func apply(inputs: Inputs) {
        switch inputs {
            case .onAppear:
                interactor.startSettion()
            break
            case .tappedCameraButton:
            break
            case .onDisappear:
              interactor.stopSettion()
        }
    }

    // MARK: Privates
    private let interactor = SimpleVideoCaptureInteractor()
}

