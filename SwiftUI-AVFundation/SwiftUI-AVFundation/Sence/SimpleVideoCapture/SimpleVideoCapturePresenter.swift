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
    enum Inputs {
        case onAppear
        case tappedCameraButton
        case tappedCloseButton
        case onDisappear
    }

    init() {
        interactor.setupAVCaptureSession()
        bind()
    }

    deinit {
        canseables.forEach { (cancellable) in
            cancellable.cancel()
        }
    }

    var previewLayer: CALayer {
        return interactor.previewLayer!
    }

    @Published var photoImage: UIImage = UIImage()
    @Published var showSheet: Bool = false

    func apply(inputs: Inputs) {
        switch inputs {
            case .onAppear:
                interactor.startSettion()
            break
            case .tappedCameraButton:
                interactor.takePhoto()
            case .tappedCloseButton:
                showSheet = false
            case .onDisappear:
              interactor.stopSettion()
        }
    }

    // MARK: Privates
    private let interactor = SimpleVideoCaptureInteractor()
    private var canseables: [Cancellable] = []

    private func bind() {
        let photoImageObserver = interactor.$photoImage.sink { (image) in
            if let image = image {
                self.photoImage = image
            }
        }
        canseables.append(photoImageObserver)

        let showPhotoObserver = interactor.$showPhoto.assign(to: \.showSheet, on: self)
        canseables.append(showPhotoObserver)
    }
}

