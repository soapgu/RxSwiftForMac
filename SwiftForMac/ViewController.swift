//
//  ViewController.swift
//  SwiftForMac
//
//  Created by guhui on 2022/1/17.
//

import Cocoa
import RxSwift
import RxCocoa
import RxAlamofire

class ViewController: NSViewController {
    @IBOutlet var tapButton: NSButton!
    @IBOutlet var image: NSImageView!
    @IBOutlet var msgLabel: NSTextField!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapButton.rx.tap.flatMapLatest{
            [unowned self] in
            self.getRandomPhotoComposeRxAlamofire()
        }
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak image,weak msgLabel] data in
            if let currentString = msgLabel?.stringValue {
                msgLabel?.stringValue = currentString.replacingOccurrences(of: "...", with: "")
            }
            image?.image = NSImage(data: data)
        } )
        .disposed(by: disposeBag)
    }
    
    func getRandomPhoto()->Observable<Data>{
        let urlString = "https://api.unsplash.com/photos/random?client_id=ki5iNzD7hebsr-d8qUlEJIhG5wxGwikU71nsqj8PcMM"
        let url = URL(string: urlString)!
        let req = URLRequest(url: url)
        let responseJSON = URLSession.shared.rx.data(request: req)
        return responseJSON.flatMapLatest{ [unowned self] json -> Observable<Data> in
            //print(json)
            let decoder = JSONDecoder()
            if let photo = try? decoder.decode(Photo.self, from: json){
                return self.getImageData(urlString: photo.urls.small)
            }
            return Observable.error(MyError.obvious)
        }
    }
    
    func getImageData( urlString:String ) ->Observable<Data>{
        let url = URL(string: urlString)!
        let req = URLRequest(url: url)
        let responseData = URLSession.shared.rx.data(request: req)
        return responseData
    }
    
    func getRandomPhotoComposeRxAlamofire() -> Observable<Data>{
        return getRandomPhotoRxAlamofire().flatMap {
            [unowned self,weak msgLabel] photo -> Observable<Data> in
                msgLabel?.stringValue = "Loading \(photo.description ?? "") image..."
                return self.getImageRxAlamofire(urlString: photo.urls.small)
        }
    }
    
    func getRandomPhotoRxAlamofire() ->Observable<Photo>{
        let urlString = "https://api.unsplash.com/photos/random?client_id=ki5iNzD7hebsr-d8qUlEJIhG5wxGwikU71nsqj8PcMM"
        msgLabel?.stringValue = "Loading data..."
        return RxAlamofire.decodable(.get, urlString)
    }
    
    func getImageRxAlamofire( urlString : String ) ->Observable<Data>{
        return RxAlamofire.data(.get, urlString)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

