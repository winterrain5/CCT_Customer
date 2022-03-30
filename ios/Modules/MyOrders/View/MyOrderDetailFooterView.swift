//
//  MyOrderDetailFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class MyOrderDetailFooterView: UIView {
  
  @IBOutlet weak var deliveryType: UILabel!
  
  @IBOutlet weak var addressLabel: UILabel!
  
  @IBOutlet weak var totalItemsLabel: UILabel!
  @IBOutlet weak var subTotalPriceLabel: UILabel!
  @IBOutlet weak var discountLabel: UILabel!
  @IBOutlet weak var deliveryFeeTypeLabel: UILabel!
  @IBOutlet weak var deliveryFeeLabel: UILabel!
  @IBOutlet weak var totalHeaderLabel: UILabel!
  @IBOutlet weak var totalPriceLabel: UILabel!
  
  @IBOutlet weak var pointsLabel: UILabel!
  
  var updateHeightHandler:((CGFloat)->())?
  var model:MyOrderDetailModel! {
    didSet {
      
      addressLabel.text = model.Order_Info?.address
      
      
      var sub_total:Float = 0.0;
      var total = 0;
      var discount:Float = 0;
      var gst:Float = 0.00;
      var freight:Float = 0.0;
      var show_total:Float = 0.00;
      
      model.Order_Line_Info?.forEach({ item in
        
        total += (item.qty?.float()?.int ?? 0)
        
        discount += (item.new_recharge_discount?.float() ?? 0)
        
        discount += (item.reward_discount?.float() ?? 0)
        
        let paid_amount = item.paid_amount?.float() ?? 0
        let rate = item.rate?.float() ?? 0
        
        gst += paid_amount / (1 + (rate / 100))*(rate / 100);
        
      })
      
     
      freight = model.Order_Info?.freight?.float() ?? 0

      sub_total = model.Order_Info?.subtotal?.float() ?? 0

      show_total = model.Order_Info?.total?.float() ?? 0

      show_total += freight

      var local_title = ""
      var address = ""
      var feeTypeHead = ""

      if (freight == 0) {

        if (model.Order_Line_Info?.count ?? 0 > 0) {

          local_title = "Self Collection @" + (model.Order_Line_Info?[0].delivery_location_name ?? "");
          address = (model.Order_Line_Info?[0].delivery_location_address ?? "");
          
        }else {

          local_title = "Self Collection"

        }

        feeTypeHead = "Delivery Fee"
      }else {

        local_title = "Local Delivery"

        address = model.Order_Info?.address ?? "";

        feeTypeHead = "Local Delivery"
      }
      
      deliveryType.text = local_title
      addressLabel.text = address
      
      totalItemsLabel.text = total.string
      subTotalPriceLabel.text = sub_total.string.dolar
      discountLabel.text = discount > 0 ? ("-" + discount.string.dolar) : "$0.00"
      deliveryFeeTypeLabel.text = feeTypeHead
      deliveryFeeLabel.text = freight.string.dolar
      
      totalHeaderLabel.text = gst > 0 ? "Total(Inclusive of GST \(gst.string.dolar))" : "Total"
      totalPriceLabel.text = show_total.string.dolar
      
      pointsLabel.text = "(Points earned \(model.Order_Info?.present_points ?? ""))"
      
      self.setNeedsLayout()
      self.layoutIfNeeded()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.updateHeightHandler?(310 + self.addressLabel.requiredHeight + self.deliveryType.requiredHeight)
      }
      
    }
  }
}
