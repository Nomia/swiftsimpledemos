//
//  ViewController.swift
//  AddAnimToVideoDemo
//
//  Created by RowVincent on 2017/1/29.
//  Copyright © 2017年 Nimbosa. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var videoAsset:AVAsset?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    /// 添加动画到视频合成
    ///
    /// - parameter composition: 动画合成
    func addAnimToComposition(composition : AVMutableVideoComposition, rect : CGSize) -> AVMutableVideoComposition{
        let winWidth:CGFloat = rect.width
        let winHeight:CGFloat = rect.height
        
        let parentLayer:CALayer = CALayer()
        parentLayer.frame = CGRect(x: 0.0, y: 0.0, width: winWidth, height: winHeight)
        
        let animLayer:CALayer = CALayer()
        animLayer.backgroundColor = UIColor.blue.cgColor
        animLayer.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        
        // 定义动画
        let anim:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        anim.beginTime = AVCoreAnimationBeginTimeAtZero
        anim.duration = 1.0
        anim.fromValue = 0.0
        anim.toValue = 1.0
        anim.autoreverses = true
        anim.repeatCount = 5
        
        
        animLayer.add(anim, forKey: "animOpacity")
        animLayer.masksToBounds = true

        
        let videoLayer:CALayer = CALayer()
        videoLayer.frame = CGRect(x: 0.0, y: 0.0, width: winWidth, height: winHeight)
        
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(animLayer)
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        return composition
        
    }
    
    
    /// 从相册中选择视频
    func chooseVideo(){
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"];
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    /// 选择取消
    ///
    /// - parameter picker:
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel select")
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    /// 视频选择
    ///
    /// - parameter picker: 选择器
    /// - parameter info:   选择的视频
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        videoAsset = AVAsset(url: info[UIImagePickerControllerMediaURL]! as! URL)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    /// 添加动画到视频中
    /// 步骤:
    /// 创建一个mutableComposition
    /// 从mutableComposition中提出一个addMutableTrack视频或者音频
    /// 然后使用videoAsset填充音视频轨道
    /// 创建一个mutableVideoComposition
    /// 为mutableVideoComposition添加layer动画,使用animationTool
    /// 导出时使用mutableVideoComposition
    func addAnimToVideo(){
        let videoAssetTrack:AVAssetTrack = (videoAsset?.tracks(withMediaType: AVMediaTypeVideo)[0])!
        let winWidth:CGFloat = videoAssetTrack.naturalSize.width
        let winHeight:CGFloat = videoAssetTrack.naturalSize.height
        
        
        let composition:AVMutableComposition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        var videoComposition:AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: winWidth, height: winHeight)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, (videoAsset?.duration)!)
        let videoLayerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        videoLayerInstruction.setTransform(videoTrack.preferredTransform, at: kCMTimeZero)
        videoLayerInstruction.setOpacity(0.0, at: (videoAsset?.duration)!)
        instruction.layerInstructions = [videoLayerInstruction]
        videoComposition.instructions = [instruction]
        
        
        

        
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (videoAsset?.duration)!), of: (videoAsset?.tracks(withMediaType: AVMediaTypeVideo)[0])! , at: kCMTimeZero)
            
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (videoAsset?.duration)!), of: (videoAsset?.tracks(withMediaType: AVMediaTypeAudio)[0])!, at: kCMTimeZero)
            
            // 为videoComposition添加动画layer
            videoComposition = self.addAnimToComposition(composition: videoComposition, rect: videoAssetTrack.naturalSize)
            
            // 导出视频,保存到相册
            var fileUrl:URL = FileManager.default.temporaryDirectory.absoluteURL
            fileUrl.appendPathComponent("animvideo1.mov")
            
            
            let exporter:AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset960x540)!
            
            exporter.videoComposition = videoComposition
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.outputURL = fileUrl
            exporter.shouldOptimizeForNetworkUse = true
            
            exporter.exportAsynchronously {
                print("动画视频已经保存")
                print(fileUrl)
                
                // 保存到相册
                self.moveToPhotos(fileUrl: fileUrl)
            }
            
        } catch {
            
        }
        
        
    }
    
    
    
    
    /// 移动媒体文件到相册
    ///
    /// - parameter fileUrl: 媒体文件地址
    func moveToPhotos(fileUrl:URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
            }, completionHandler: { saved, error in
                if saved {
                    print("移动到相册成功")
                    
                    do {
                        try FileManager.default.removeItem(at: fileUrl)
                    } catch {
                        print("移除源文件失败")
                    }
                } else {
                    print(error)
                }
        })
    }
    
    
    
    
    @IBAction func chooseVideo(_ sender: AnyObject) {
        self.chooseVideo()
    }
    
    @IBAction func mergeAnim(_ sender: AnyObject) {
        self.addAnimToVideo()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

