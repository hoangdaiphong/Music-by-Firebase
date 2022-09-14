//
//  ViewController.swift
//  Music by Firebase
//
//  Created by Hoang Dai Phong on 2020/02/11.
//  Copyright © 2020 Hoang Dai Phong. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var singerName: [String] = ["Taylor Swift", "Tone And I", "Daddy Yankee", "Ed Sheeran", "Akon", "Justin Bieber"]
    var songName : [String] = ["Blank Space", "Dance MonKey", "Despacito", "Shape Of You", "Smack That", "Sorry"]
    var songLink: [String] = ["BlankSpace.mp3", "DanceMonkey.mp3", "Despacito.mp3", "ShapeOfYou.mp3", "SmackThat.mp3", "Sorry.mp3"]
    var singer: [String] = ["TaylorSwift.jpg", "ToneAndI.jpg", "DaddyYankee.jpg", "EdSheeran.jpg", "Akon.jpg", "JustinBieber.jpg"]

    var player: AVAudioPlayer!
    var timer: Timer!
    var timerAnimation: Timer!
    var goc: Int = 0
    
    @IBOutlet weak var lblSongName: UILabel!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    
    @IBOutlet weak var sldTime: UISlider!
    @IBOutlet weak var sldVolume: UISlider!
    
    @IBOutlet weak var btnOpenVolume: UIButton!
    @IBOutlet weak var btnMuteVolume: UIButton!
    
    @IBOutlet weak var tblListMusic: UITableView!
    
    @IBOutlet weak var imgSinger: UIImageView!
    
    @IBOutlet weak var imgAnimation: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIImageViewを調整する - Chỉnh lại UIImageView
        imgSinger.layer.cornerRadius = 10
                
        // ImageViweとLabelを調整する - Set imageView và label:
        lblSongName.text = "\(songName[0]) - \(singerName[0])"
        imgSinger.image = UIImage(named: singer[0])
        
        // 音楽アイコンを動く - Set chuyển động ImgAnimation:
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (abc) in
        self.goc += 2
        self.imgAnimation.transform = CGAffineTransform(rotationAngle: CGFloat(self.goc) * CGFloat(Double.pi) / 180)
        })
        
        getMusic(linkSong: songLink[0])
        
        btnPlay.isHidden = false
        btnPause.isHidden = true
        
        btnMuteVolume.isHidden = true
        btnOpenVolume.isHidden = false
        
        tblListMusic.dataSource = self
        tblListMusic.delegate = self
    }

    // 音楽の再生ボタンをおお押す -　Nhấn vào button phát nhạc
    @IBAction func btn_Play(_ sender: Any) {
        
        self.player.play()
        let dur: TimeInterval! = player.duration
        
        sldTime.minimumValue = 0
        sldTime.maximumValue = Float(dur)
        sldTime.value = 0
        
        btnPlay.isHidden = true
        btnPause.isHidden = false
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    // 音楽停止ボタンを押す -　Nhấn vào button pause nhạc
    @IBAction func btn_Pause(_ sender: Any) {
        
        self.player.pause()
        
        btnPlay.isHidden = false
        btnPause.isHidden = true
    }
    
    // 音楽再生時の更新時間 - Update time lúc phát nhạc
    @objc func updateTime() {
        
        let cur = player.currentTime
        sldTime.value = Float(cur)
        
        // Khi bài hát trở về thì nút Play và Pause sẽ đổi lại
        if cur == 0 {
            btnPause.isHidden = true
            btnPlay.isHidden = false
        }
    }
    
    // 歌の時間を調整する - Tương tác thời gian bài nhạc
    @IBAction func sld_Time(_ sender: Any) {
        
        self.player.currentTime = TimeInterval(self.sldTime.value)
        btn_Play((Any).self)
    }
    
    // 音量を調整する - Tương tác âm lượng bài nhạc
    @IBAction func sld_Volume(_ sender: Any) {
        
        player.volume = sldVolume.value
    }
    
    // 音を出す - Ấn nút thì phát tiếng
    @IBAction func btn_OpenVolume(_ sender: Any) {
        
        btnMuteVolume.isHidden = false
        btnOpenVolume.isHidden = true
        player.volume = 0
    }
    
    // 音を消す - Ấn nút thì tắt tiếng
    @IBAction func btn_MuteVolume(_ sender: Any) {
        
        btnMuteVolume.isHidden = true
        btnOpenVolume.isHidden = false
        player.volume = sldVolume.value
    }
    
    // Table view を作る -　Gọi hàm khởi tạo table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(songName[indexPath.row]) - \(singerName[indexPath.row])"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        
       
        return cell
    }
    
    // Table View Cell の高さ -　Set lại kích thước cho Table View Cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // Listを押す時は音楽を選択する -　Khi ấn vào list bài hát sẽ chọn bài khác
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        lblSongName.text = "\(songName[indexPath.row]) - \(singerName[indexPath.row])"
        getMusic(linkSong: songLink[indexPath.row])
        imgSinger.image = UIImage(named: singer[indexPath.row])
        player.play()
        
        let dur = player.duration
        sldTime.minimumValue = 0
        sldTime.maximumValue = Float(dur)
        sldTime.value = 0
    }
    
    // Firebase から　ダウンロードすること -　Download file nhạc từ firebase
    func getMusic(linkSong: String) {
        
        let storage = Storage.storage()
        let rootFolder = storage.reference(forURL: "gs://music-by-firebase-d82df.appspot.com")
        let audioFolder = rootFolder.child("musics")
        let audioFile = audioFolder.child(linkSong)
        
        audioFile.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
            if error != nil {
                print(error as Any)
            }
            else {
                do {
                    try self.player = AVAudioPlayer(data: data!)
                    self.player.prepareToPlay()
                    //self.player.play()
                }
                catch {
                    print("ERROR")
                }
            }
        }
    }
}

