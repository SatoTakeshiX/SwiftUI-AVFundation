//
//  SimpleVideoCaptureInteractor.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/13.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import Foundation
import AVKit

final class SimpleVideoCaptureInteractor: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    @Published var showPhoto: Bool = false
    @Published var photoImage: UIImage?

    /// - Tag: CreateCaptureSession
     func setupAVCaptureSession() {
         print(#function)
         captureSession.sessionPreset = .photo
         if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first {
             captureDevice = availableDevice
         }

         do {
             let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
             captureSession.addInput(captureDeviceInput)
         } catch let error {
             print(error.localizedDescription)
         }

         let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.name = "CameraPreview"
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.backgroundColor = UIColor.black.cgColor
         self.previewLayer = previewLayer

         let dataOutput = AVCaptureVideoDataOutput()
         dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]

         if captureSession.canAddOutput(dataOutput) {
             captureSession.addOutput(dataOutput)
         }
         captureSession.commitConfiguration()
     }

    func startSettion() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }

    func stopSettion() {
        if !captureSession.isRunning { return }
        captureSession.stopRunning()
    }

    func takePhoto() {
        showPhoto = true
    }

    private func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> UIImage.Orientation {

        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored

        case .landscapeLeft:
            return .downMirrored

        case .landscapeRight:
            return .upMirrored

        default:
            return .leftMirrored
        }
    }
    private func exifOrientationForCurrentDeviceOrientation() -> UIImage.Orientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
}


extension SimpleVideoCaptureInteractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if showPhoto {
            showPhoto = false
            if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()

                let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

                if let image = context.createCGImage(ciImage, from: imageRect) {
                    photoImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: exifOrientationForCurrentDeviceOrientation())
                }
            }
        }
    }
}
