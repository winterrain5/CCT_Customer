//
//  MyOrderDetailModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class OrderLineInfo :BaseModel,Codable {
  var rate: String?
  var return_amount: String?
  var id: String?
  var discount_type2: Int?
  var equal_staffs: String?
  var paid_amount: String?
  var source_id: String?
  var present_qty: Int?
  var delivery_location_address: String?
  var sale_employee_last_name: String?
  var tax_code: String?
  var cooperator_last_name: String?
  var picture: String?
  var return_present_qty: String?
  var referrer_last_name: String?
  var employee_last_name: String?
  var valid_qty: Int?
  var staff_id: String?
  var qty: String?
  var referrer_first_name: String?
  var has_leaved_review: Int?
  var reward_discount: String?
  var discount_amount1: String?
  var create_time: String?
  var doctor_first_name: String?
  var discount_amount2: String?
  var name: String?
  var product_category: String?
  var cooperator_first_name: String?
  var tax_rate_type: String?
  var valid_amount: CGFloat?
  var total: String?
  var tax: String?
  var tax_id: String?
  var price: String?
  var product_id: String?
  var referrer: String?
  var disc2: Int?
  var designation_code: String?
  var staff_id2: String?
  var doctor_last_name: String?
  var responsible_doctor: String?
  var delivery_location_name: String?
  var return_qty: String?
  var employee_first_name: String?
  var discount2: String?
  var has_delivered: String?
  var discount: String?
  var discount_type: Int?
  var disc: Int?
  var new_recharge_discount: String?
  var sale_employee_first_name: String?
  var leave_review_points:String?
  var should_leavea_review:Bool? {
    get {
      return (product_category == "2" || product_category == "1" || product_category == "5" || product_category == "7") && (has_leaved_review == 0)
    }
  }
  var totalDiscount:Float {
    return (discount_amount1?.float() ?? 0) + (discount_amount2?.float() ?? 0)
  }
  
  var discountName:String {
    var discountNameStr:[String] = []
    if !(discount?.trim().isEmpty ?? false) {
      discountNameStr.append(discount ?? "")
    }
    if !(discount2?.trim().isEmpty ?? false) {
      discountNameStr.append(discount2 ?? "")
    }
    
    if totalDiscount > 0 {
      if discountNameStr.isEmpty {
        return "Discount"
      }else {
        return "Discount(" + discountNameStr.joined(separator: ",").removingSuffix(", ") + ")"
      }
    }
    return ""
  }
  
  var transactionDetailCellHeight:CGFloat? {
    get {
      let discountH = discountName.heightWithConstrainedWidth(width: kScreenWidth - 134, font: UIFont(name:.AvenirNextRegular,size:14))
      let nameHeight = name?.heightWithConstrainedWidth(width: kScreenWidth - 80 - 48, font: UIFont(name: .AvenirNextDemiBold, size:14)) ?? 0
      return totalDiscount > 0 ? (nameHeight + discountH + 48) : (nameHeight + 32)
    }
  }
  
  var bookCompleteCellHeight:CGFloat {
    let nameHeight = name?.heightWithConstrainedWidth(width: kScreenWidth - 160, font: UIFont(name: .AvenirNextDemiBold, size:12)) ?? 0
    return  nameHeight + 16
  }
  
  var recharge_discount_sort: Int?
  var retail_price: String?
  var voucher_pay_code: String?
  var product_category_tag: String?
  

}

class PayVoucherInfo :BaseModel {
  var is_freight: String?
  var sale_order_line_id: String?
  var is_present: String?
  var create_date: String?
  var bought_voucher_id: String?
  var id: String?
  var sale_order_id: String?
  var name: String?
  var paid_amount: String?
  
}

class PayGiftInfo :BaseModel {
  var client_gift_id:String?
  var create_date:String?
  var id:String?
  var name:String?
  var paid_amount:String?
  var sale_order_id:String?
  var sale_order_line_id:String?

}

class PaymethodInfo :BaseModel {
  var pay_method_line_id: String?
  var id: String?
  var real_paid_amount: String?
  var paid_amount: String?
  var name: String?
  
}

class OrderInfo :BaseModel {
  var id: String?
  var exchange_rate: String?
  var comment_id: String?
  var paid_amount: String?
  var promise_date: String?
  var pay_by_service: String?
  var new_gift_voucher_amount: String?
  var company_id: String?
  var subtotal: String?
  var return_pay_by_gift: String?
  var project_subject: String?
  var return_gift_voucher_amount: String?
  var date: String?
  var modify_uid: String?
  var close_time: String?
  var return_cash_amount: String?
  var status: String?
  var modify_time: String?
  var goods_number: String?
  var client_balance: String?
  var pay_by_balance: String?
  var country_id: String?
  var address: String?
  var type: String?
  var return_points: String?
  var voucher_amount: String?
  var account_id: String?
  var location_id: String?
  var pay_method_line_id: String?
  var total_new_recharge_discount: String?
  var saleman_id: String?
  var paid_today: String?
  var pay_by_gift: String?
  var create_time: String?
  var customer_id: String?
  var tip_amount: String?
  var invoice_date: String?
  var freight: String?
  var is_from_app: String?
  var total: String?
  var change: String?
  var return_pay_by_service: String?
  var staff_tipped: String?
  var balance: String?
  var is_delete: String?
  var referral_source_id: String?
  var remark: String?
  var quote_id: String?
  var category: String?
  var create_uid: String?
  var number: String?
  var customer_zip: String?
  var return_new_gift_voucher_amount: String?
  var origin_paid_amount: String?
  var return_voucher_amount: String?
  var gift_voucher_amount: String?
  var addr_id: String?
  var present_points: String?
  var total_discount: String?
  var is_history: String?
  var tax: String?
  var return_amount: String?
  var ship_via_id: String?
  var reward_amout: String?
  var terms_id: String?
  var customer_number: String?
  var reward_id: String?
  var return_pay_by_balance: String?
  var tax_id: String?
  var quote_number: String?
  var invoice_no: String?
  var due_date: String?
  
}

class VoucherInfo: BaseModel {
  var id:String?
  var voucher_code:String?
}

class MyOrderDetailModel: BaseModel {
  var Order_Line_Info: [OrderLineInfo]?
  var PayVoucher_Info: [PayVoucherInfo]?
  var PayGift_Info: [PayGiftInfo]?
  var Paymethod_Info: [PaymethodInfo]?
  var Voucher_Info:[VoucherInfo]?
  var Order_Info: OrderInfo?
  
}
