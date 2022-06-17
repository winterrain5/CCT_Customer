//
//  TodayTreatmentQueueCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/17.
//

import UIKit

class TodayTreatmentQueueCell: UICollectionViewCell {
  @IBOutlet weak var queueNoLabel: UILabel!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var locationView: UIView!

  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var infoLabel: UILabel!
  var model:BookingTodayModel! {
    didSet {
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      timeLabel.text = date?.timeString(ofStyle: .short)
      locationLabel.text = model.location_name
      
      queueNoLabel.text = model.queue_no
      getWaitServiceInfo()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    infoContentView.addLightShadow(by: 16)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    locationView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  func getWaitServiceInfo() {
    let params = SOAPParams(action: .BookingOrder, path: .getWaitServiceInfo)
    params.set(key: "locationId", value: model.location_id)
    params.set(key: "startTime", value: Date().string(withFormat: "yyyy-MM-dd"))
    params.set(key: "endTime", value: Date().adding(.day, value: 1).string(withFormat: "yyyy-MM-dd"))
    params.set(key: "wellnessTreatType", value: 2)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(WaitServiceModel.self, from: data) {
        let sub1 = "\(model.queue_count) currently in queue \nEstimated "
        let str = "\(model.queue_count) currently in queue \nEstimated \(model.duration_mins) mins waiting time"
        let attr = NSMutableAttributedString(string: str)
        attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size: 14), range: NSRange(location: 0, length: model.queue_count.count))
        attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size: 14), range: NSRange(location: sub1.count, length: (model.duration_mins + " mins").count))
        self.infoLabel.attributedText = attr
      }
    } errorHandler: { e in
      
    }

  }
}
