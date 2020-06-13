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

final class SimpleVideoCapturePresenter: NSObject, ObservableObject {

    //final class Outputs: ObservableObject {
        var previewLayer: CALayer = CALayer()
    //}

    enum Inputs {
        case onAppear
        case tappedCameraButton
        case onDisappear
    }

    //var outputs: Outputs
    override init() {
        super.init()
        self.prepareCamera()
        self.beginSession()
    }

    func apply(inputs: Inputs) {
        switch inputs {
            case .onAppear:
               startSession()
            break
            case .tappedCameraButton:
            break
            case .onDisappear:
              //  interactor.stopSettion()
                endSession()
                cancellable?.cancel()
        }
    }

    // MARK: Privates
    private var cancellable: Cancellable?
    private let captureSession = AVCaptureSession()
    private var capturepDevice:AVCaptureDevice!
    //private let interactor = SimpleVideoCaptureInteractor()

//    private func bind() {
//        self.cancellable = interactor.$previewLayer.sink(receiveValue: { (previewLayer) in
//            if let calayer = previewLayer {
//                self.previewLayer = calayer
//            }
//        })
//    }

    private func prepareCamera() {
        captureSession.sessionPreset = .photo

        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first {
            capturepDevice = availableDevice
        }
    }
    private func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: capturepDevice)

            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]

        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput) // -> ここをコメントアウトしたら、カメラボタンタップで画像を取得できなくなった。しかしカメラのライブ映像はそのまま取得できた。
        }

        captureSession.commitConfiguration()

        let queue = DispatchQueue(label: "FromF.github.com.AVFoundationSwiftUI.AVFoundation")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }

    func startSession() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }

    func endSession() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }
}

extension SimpleVideoCapturePresenter: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    }
}
