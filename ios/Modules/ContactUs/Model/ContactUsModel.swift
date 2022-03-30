//
//  ContactUsModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class ContactUsModel: Codable {
  var is_delete: String?
  var online_booking: String?
  var uen_number: String?
  var remark: String?
  var id: String?
  var tax_ref_no: String?
  var hotline: String?
  var system_name: String?
  var address: String?
  var create_uid: String?
  var show_sort: String?
  var text: String?
  var country_id: String?
  var mon_fri_start: String?
  var business_type_id: String?
  var gst_de_reg_date: String?
  var type: String?
  var website: String?
  var whatapp: String?
  var sat_sun_start: String?
  var email: String?
  var create_time: String?
  var cct_or_mp: String?
  var gst_reg_date: String?
  var contacts: String?
  var name: String?
  var code: String?
  var zip_code: String?
  var can_send_product: String?
  var time_zone: String?
  var employees: String?
  var alias_name: String?
  var subNodes: [ContactUsSubNodes]?
  var area_id: String?
  var gst_number: String?
  var currency_id: String?
  var sat_sun_end: String?
  var img_data: String?
  var img_url: String?
  var financial_independent: String?
  var data_nodeid: String?
  var financial_company_id: String?
  var phone: String?
  var time_format: String?
  var mon_fri_end: String?
  var pid: String?
  var cellHeight:CGFloat?
  var isExpend:Bool?
  var longitude:String?
  var latitude:String?
}

class ContactUsSubNodes:Codable {
  
}
