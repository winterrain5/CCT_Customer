//
//  TopUpOrderDetailModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/2.
//

import Foundation
class PayVoucher_Info :Codable {
  
}

class Order_Line_Info :Codable {
  var recharge_discount_sort: Int?
  var return_amount: String?
  var new_recharge_discount: String?
  var id: String?
  var discount_type2: Int?
  var equal_staffs: String?
  var source_id: String?
  var present_qty: String?
  var sale_employee_last_name: String?
  var tax_code: String?
  var cooperator_last_name: String?
  var retail_price: String?
  var employee_last_name: String?
  var staff_id: String?
  var qty: String?
  var reward_discount: Int?
  var create_time: String?
  var cooperator_first_name: String?
  var product_category: String?
  var name: String?
  var tax_rate_type: String?
  var total: String?
  var tax: String?
  var tax_id: String?
  var price: String?
  var product_id: String?
  var disc2: Int?
  var designation_code: String?
  var staff_id2: String?
  var product_category_tag: String?
  var return_qty: String?
  var discount2: String?
  var employee_first_name: String?
  var discount: String?
  var discount_type: Int?
  var disc: Int?
  var rate: String?
  var sale_employee_first_name: String?
  
}

class Order_Info :Codable {
  var id: Int?
  var exchange_rate: String?
  var comment_id: Int?
  var new_gift_voucher_amount: String?
  var promise_date: String?
  var pay_by_service: String?
  var paid_amount: String?
  var company_id: Int?
  var subtotal: String?
  var return_pay_by_gift: String?
  var return_gift_voucher_amount: String?
  var project_subject: String?
  var close_time: String?
  var modify_uid: String?
  var date: String?
  var return_cash_amount: String?
  var status: Int?
  var modify_time: String?
  var goods_number: String?
  var client_balance: String?
  var pay_by_balance: String?
  var country_id: Int?
  var address: String?
  var type: Int?
  var return_points: String?
  var voucher_amount: String?
  var location_id: Int?
  var account_id: Int?
  var pay_method_line_id: Int?
  var total_new_recharge_discount: String?
  var saleman_id: Int?
  var paid_today: String?
  var pay_by_gift: String?
  var create_time: String?
  var invoice_date: String?
  var tip_amount: String?
  var customer_id: Int?
  var freight: String?
  var is_from_app: Int?
  var total: String?
  var change: String?
  var return_pay_by_service: String?
  var staff_tipped: String?
  var balance: String?
  var is_delete: Int?
  var quote_id: Int?
  var remark: String?
  var referral_source_id: String?
  var category: Int?
  var create_uid: Int?
  var number: String?
  var customer_zip: String?
  var return_new_gift_voucher_amount: String?
  var return_voucher_amount: String?
  var present_points: String?
  var gift_voucher_amount: String?
  var addr_id: Int?
  var origin_paid_amount: String?
  var total_discount: String?
  var tax: String?
  var return_amount: String?
  var is_history: Int?
  var ship_via_id: Int?
  var terms_id: Int?
  var reward_amout: String?
  var reward_id: String?
  var return_pay_by_balance: String?
  var customer_number: String?
  var tax_id: Int?
  var quote_number: String?
  var invoice_no: String?
  var due_date: String?
  
}

class PayGift_Info :Codable {
  
}

class Paymethod_Info :Codable {
  
}

class Voucher_Info :Codable {
  var id: String?
  var voucher_code: String?
  
}

class TopUpOrderDetailModel :Codable {
  var PayVoucher_Info: [PayVoucher_Info]?
  var Order_Line_Info: [Order_Line_Info]?
  var Order_Info: Order_Info?
  var PayGift_Info: [PayGift_Info]?
  var Paymethod_Info: [Paymethod_Info]?
  var Voucher_Info: [Voucher_Info]?
  
}
