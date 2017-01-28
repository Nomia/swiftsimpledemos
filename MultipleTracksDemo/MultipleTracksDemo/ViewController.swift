//
//  ViewController.swift
//  MultipleTracksDemo
//
//  Created by RowVincent on 2017/1/28.
//  Copyright © 2017年 Nimbosa. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
    
    var videoAsset:AVAsset?
    var audioAsset:AVAsset?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /// 从相册选择音频
    func chooseAudio(){
        let mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        mediaPicker.delegate = self
        mediaPicker.prompt = "选择音频"
        mediaPicker.showsCloudItems = true
        mediaPicker.allowsPickingMultipleItems = true
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("取消选择音频")
//        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        if mediaItemCollection.items.count > 0 {
            let item = mediaItemCollection.items[0];
            audioAsset = AVAsset(url: item.assetURL!)
        }
        mediaPicker.dismiss(animated: true, completion: nil)
        
    }
    
    /// 从相册选择视频
    func chooseVideo(){
        // 媒体文件选择器
        let mediaPicker:UIImagePickerController!
        mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.sourceType = .photoLibrary
        mediaPicker.mediaTypes = ["public.movie"]
        present(mediaPicker, animated: true, completion: nil)
    }
    
    
    
    /// 取消选择
    ///
    /// - parameter picker: 图片选择控制器
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image picker cancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    /// 选择了媒体文件
    ///
    /// - parameter picker: 图片选择控制器
    /// - parameter info:   图片媒体信息
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        videoAsset = AVAsset(url: info[UIImagePickerControllerMediaURL] as! URL)
    }
    
    
    /// 合并并保存视频音频
    func mergeAssets(){
        if audioAsset != nil && videoAsset != nil {
            let mixCompo:AVMutableComposition  = AVMutableComposition()
            
            
            do {
                // 添加视频轨
                let videoTrack:AVMutableCompositionTrack = mixCompo.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                
                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (videoAsset?.duration)!), of: (videoAsset?.tracks(withMediaType: AVMediaTypeVideo)[0])! as AVAssetTrack, at: kCMTimeZero)
                
                
                
                // 添加音轨
                let audioTrack:AVMutableCompositionTrack = mixCompo.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (videoAsset?.duration)!), of: (audioAsset?.tracks(withMediaType: AVMediaTypeAudio)[0])! as AVAssetTrack
                    , at: kCMTimeZero)
                
                
                var fileUrl:URL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                fileUrl.appendPathComponent("temp1.mov")
                
                
                
                // 导出文件
                let exporter:AVAssetExportSession = AVAssetExportSession(asset: mixCompo, presetName: AVAssetExportPreset960x540)!
                
                exporter.outputURL = fileUrl
                exporter.outputFileType = AVFileTypeQuickTimeMovie
                exporter.shouldOptimizeForNetworkUse = true
                exporter.exportAsynchronously(completionHandler: {
                    print("exported")
                    
                    self.moveToPhotos(fileUrl: fileUrl)
                })
            } catch {
                
            }
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
                    print("saved")
                    
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
    
    @IBAction func onChooseVideo(_ sender: AnyObject) {
        self.chooseVideo()
    }
    
    @IBAction func onMerge(_ sender: AnyObject) {
        self.mergeAssets()
    }
    
    @IBAction func onChooseAudio(_ sender: AnyObject) {
        self.chooseAudio()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

