//
//  TopUpOrderDetailModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/2.
//

import Foundation



class Order_Line_Info :BaseModel {
  var sale_employee_first_name: String?
  var new_recharge_discount: Int = 0
  var return_amount: String?
  var discount_type2: Int = 0
  var id: String?
  var equal_staffs: String?
  var source_id: String?
  var present_qty: String?
  var sale_employee_last_name: String?
  var tax_code: String?
  var retail_price: String?
  var cooperator_last_name: String?
  var employee_last_name: String?
  var staff_id: String?
  var qty: String?
  var reward_discount: Int = 0
  var create_time: String?
  var name: String?
  var product_category: String?
  var tax: String?
  var tax_rate_type: String?
  var total: String?
  var cooperator_first_name: String?
  var price: String?
  var product_id: String?
  var tax_id: String?
  var disc2: Int = 0
  var designation_code: String?
  var staff_id2: String?
  var product_category_tag: String?
  var return_qty: String?
  var discount2: String?
  var employee_first_name: String?
  var discount: String?
  var rate: String?
  var disc: Int = 0
  var discount_type: Int = 0
  var recharge_discount_sort: Int = 0
  
}

class Order_Info :BaseModel {
  var id: Int = 0
  var exchange_rate: String?
  var comment_id: Int = 0
  var new_gift_voucher_amount: String?
  var promise_date: String?
  var pay_by_service: String?
  var paid_amount: String?
  var company_id: Int = 0
  var subtotal: String?
  var return_pay_by_gift: String?
  var project_subject: String?
  var return_gift_voucher_amount: String?
  var date: String?
  var modify_uid: String?
  var close_time: String?
  var return_cash_amount: String?
  var status: Int = 0
  var goods_number: String?
  var modify_time: String?
  var client_balance: String?
  var pay_by_balance: String?
  var country_id: Int = 0
  var address: String?
  var type: Int = 0
  var return_points: String?
  var voucher_amount: String?
  var location_id: Int = 0
  var account_id: Int = 0
  var paid_today: String?
  var total_new_recharge_discount: String?
  var saleman_id: Int = 0
  var pay_method_line_id: Int = 0
  var create_time: String?
  var pay_by_gift: String?
  var customer_id: Int = 0
  var tip_amount: String?
  var invoice_date: String?
  var total: String?
  var is_from_app: Int = 0
  var freight: String?
  var change: String?
  var return_pay_by_service: String?
  var staff_tipped: String?
  var balance: String?
  var is_delete: Int = 0
  var referral_source_id: String?
  var quote_id: Int = 0
  var remark: String?
  var category: Int = 0
  var create_uid: Int = 0
  var number: String?
  var customer_zip: String?
  var return_new_gift_voucher_amount: String?
  var origin_paid_amount: String?
  var return_voucher_amount: String?
  var gift_voucher_amount: String?
  var addr_id: Int = 0
  var present_points: String?
  var total_discount: String?
  var tax: String?
  var is_history: Int = 0
  var return_amount: String?
  var ship_via_id: Int = 0
  var terms_id: Int = 0
  var reward_id: String?
  var reward_amout: String?
  var return_pay_by_balance: String?
  var customer_number: String?
  var tax_id: Int = 0
  var quote_number: String?
  var invoice_no: String?
  var due_date: String?
  
}

class PayVoucher_Info :BaseModel {
  
}

class PayGift_Info :BaseModel {
  
}

class Paymethod_Info :BaseModel {
  
}

class Voucher_Info :BaseModel {
  var voucher_code: String?
  var id: String?
  
}

class TopUpOrderDetailModel :BaseModel {
  var Order_Line_Info: [Order_Line_Info]?
  var Order_Info: Order_Info?
  var PayVoucher_Info: [PayVoucher_Info]?
  var PayGift_Info: [PayGift_Info]?
  var Paymethod_Info: [Paymethod_Info]?
  var Voucher_Info: [Voucher_Info]?
  
}
