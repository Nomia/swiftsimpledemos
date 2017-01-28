//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by RowVincent on 2017/1/8.
//  Copyright © 2017年 Nimbosa. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate{
    @IBOutlet weak var cameraView: UIView!
    
    var session:AVCaptureSession?
    var hardware:AVCaptureDevice?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var fileOutput:AVCaptureFileOutput?
    var fileUrl:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVCaptureSession()
        
        let devices = AVCaptureDevice.devices()
        
        for device:AVCaptureDevice in devices! as! [AVCaptureDevice] {
            // 视频硬件设备
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == .back {
                    if hardware == nil {
                        hardware = device
                    }
                }
            }
        }
        
        if hardware != nil {
            do {
                try session?.addInput(AVCaptureDeviceInput(device: hardware))
                
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.frame = cameraView.bounds
                previewLayer?.isHidden = true
                cameraView.layer.addSublayer(previewLayer!)
                
                
                fileOutput = AVCaptureMovieFileOutput()
                
                do {
                    fileUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    //            var fileName:String = Date.timeIntervalSinceReferenceDate as String
                    //            fileName.append(".mov")
                    //            fileUrl?.appendPathComponent(fileName)
                    
                    fileUrl?.appendPathComponent("temp.mov")
                    
                    print(fileUrl)
                    
                    if FileManager.default.fileExists(atPath: fileUrl!.relativeString) {
                        print("exists")
                    } else {
                        print("nonexist")
                    }
                    session?.addOutput(fileOutput)
                } catch {
                    print("error")
                }
            } catch {
                print("add input failed")
            }
            
            
        } else {
            print("未找到视频拍摄设备")
        }
    }
    
    func startRecord () {
        previewLayer?.isHidden = false
        session?.startRunning()
        fileOutput?.startRecording(toOutputFileURL: fileUrl!, recordingDelegate: self)
    }
    
    func stopRecord () {
        previewLayer?.isHidden = true
        fileOutput?.stopRecording()
        session?.stopRunning()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("finished")

        print(outputFileURL)
        
        //@link http://stackoverflow.com/questions/29482738/swift-save-video-from-nsurl-to-user-camera-roll
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }, completionHandler: { saved, error in
                if saved {
                    print("saved")
                } else {
                    print(error)
                }
            })
        
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("here")
    }
    
    
    @IBAction func record(_ sender: AnyObject) {
        if !session!.isRunning {
            self.startRecord()
        }
    }

    @IBAction func stopRecord(_ sender: AnyObject) {
        if session!.isRunning {
            self.stopRecord()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

