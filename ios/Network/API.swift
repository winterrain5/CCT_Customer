//
//  API.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation



enum API:String {
  case getOurServicesByCategory = "getOurServicesByCategory"
  case getBriefDataBySvrId = "getBriefDataBySvrId"
  case getConditionPlanContent = "getConditionPlanContent"
  
  ///
  case getBlogCategories = "getCategories"
  ///获取顾客对博客的过滤字段
  case getClientBlogFilters = "getClientBlogFilters"
  ///获取blog数据
  case getAllBlogs = "getAllBlogs"
  ///获取blog详情
  case getBlogDetails = "getBlogDetails"
  ///获取所有的board
  case getClientBoards = "getClientBoards"
  ///获取所有的文件夹
  case getBoardsForAddBlog = "getBoardsForAddBlog"
  ///检查是否存在两个默认的分类
  case checkHasDefaultBoards = "checkHasDefaultBoards"
  ///检测name是否存在
  case checkBoardExist = "checkBoardExist"
  ///保存board
  case saveBoard = "saveBoard"
  ///保存blog到board中
  case saveBlogIntoBoard = "saveBlogIntoBoard"
  ///取消blog到board中
  case deleteBlogFromBoard = "deleteBlogFromBoard"
  ///获取所有的过滤类型
  case getFilters = "getFilters"
  ///保存过滤类型
  case saveClientBlogFilters = "saveClientBlogFilters"
  ///显示所有的文章
  case getClientBoardBlogs = "getClientBoardBlogs"
  ///搜索文章
  case searchClientBoardBlogs = "searchClientBoardBlogs"
  ///删除board
  case deleteBoard = "deleteBoard"
  
  case getQuestions = "getQuestions"
  ///获取所有的report
  case getSymptomCheckReports = "getSymptomCheckReports";
  ///删除report
  case deleteSymptomReportById = "deleteSymptomReportById";
  ///取第二个问题Overview
  case getQuestionDetails = "getQuestionDetails";
  ///根据问题2和3获取相应的内容
  ///循环第三个问题，获取多页
  case getQuestionContentByQA23 = "getQuestionContentByQA23";
  ///保存问卷
  case savePatientResults  = "savePatientResults";
  
  case getTClientPartInfo = "getTClientPartInfo"
  case getTClientByUserId = "getTClientByUserId"
  //// 获取公司的发件邮箱地址
  case getTSystemConfig = "getTSystemConfig"
  //// 发送邮件
  case sendSmsForEmail = "sendSmsForEmail"
  case getTreatmentPlanData = "getTreatmentPlanData"
  
  case getNewFeaturedProducts = "getNewFeaturedProducts"
  case getRecentViewedProduct = "getRecentViewedProduct"
  case getLikeProduct = "getLikeProduct"
  case saveLikeProduct = "saveLikeProduct"
  case deleteLikeProduct = "deleteLikeProduct"
  case getProductsByFilters = "getProductsByFilters"
  case searchSourcesByPages = "searchSourcesByPages"
  /// 获取商品详情
  case getProductsDetails = "getProductsDetails"
  case saveRecentViewedProduct = "saveRecentViewedProduct"
  case getRecommendProducts = "getRecommendProducts"
  case getProductsReviews = "getProductsReviews"
  case getCanSendProductLocations = "getCanSendProductLocations"
  //// 获取所有分店地址
  case getAllMp = "getAllMp"
  case getTLocations = "getTLocations"
  case getTCompany = "getTCompany"
  
  /// 获取公司的奖项和证书
  case getAwards = "getAwards"
  /// 获取顾客最新的评价
  case getLastClientReviews = "getLastClientReviews"
  
  case getAllSubjects = "getAllSubjects"
  case getHelpsByKeys = "getHelpsByKeys"
  case getAllHelpsContent = "getAllHelpsContent"
  case saveClientEnquiry = "saveClientEnquiry"
  
  case getTCategories = "getTCategories"
  
  /// In Progress订单表示顾客已经付款，但是产品还有拿到手或者没有邮寄到
  case getInProgressOrders = "getInProgressOrders"
  
  /// Completed表示订单已付款且顾客已经签收产品
  case getCompletedOrders = "getCompletedOrders"
  
  /// Cancelled表示删除的订单，顾客只能到店里让柜台人员删除订单
  case getCancelledInvoices = "getCancelledInvoices"
  
  ///获取订单详情
  case getOrderDetails = "getOrderDetails"
  case getCheckoutDetails = "getCheckoutDetails"
  case getHistoryCheckoutDetails = "getHistoryCheckoutDetails"
  case getHistoryOrderDetails = "getHistoryOrderDetails"
  
  /// 保存顾客对产品的评价
  case saveProductReview = "saveProductReview"
  /// 保存顾客对服务的评价
  case saveServiceReview = "saveServiceReview"
  
  case sendSmsForMobile = "sendSmsForMobile"
  case userMobileExists = "userMobileExists"
  case userEmailExists = "userEmailExists"
  /// 修改顾客的登录方面的信息
  case changeClientUserInfo = "changeClientUserInfo";
  /// 保存设置信息
  case changeClientPartInfo = "changeClientPartInfo"
  /// 修改顾客的信息
  case changeClientInfo = "changeClientInfo"
  
  ///保存找回密码的验证码uuid
  case saveFindPasswordUUID = "saveFindPasswordUUID";
  ///获取找回密码的验证信息的状态
  case getFindPasswordUUID = "getFindPasswordUUID";
  
  /// 获取
  case getClientSettings = "getClientSettings"
  /// ///获取用户金额
  case getNewReCardAmountByClientId = "getNewReCardAmountByClientId"
  /// Transactions数据
  case getTInvoicesForApp = "getTInvoicesForApp"
  /// wallet vouchers
  case getClientGifts = "getClientGifts"
  /// wallet coupons
  case getClientValidRewards = "getClientValidRewards"
  case getValidNewVouchers = "getValidNewVouchers"
  
  case getNewCardDiscountsByLevel = "getNewCardDiscountsByLevel"
  case getCardDiscountDetails = "getCardDiscountDetails"
  /// 获取充值卡的所有的好友
  case getCardFriends = "getCardFriends"
  /// 朋友的卡
  case getFriendsCard = "getFriendsCard"
  /// 获取朋友使用充值卡消费的记录
  case getFriendUsedCard = "getFriendUsedCard"
  /// 删除充值卡可使用的朋友
  case deleteCardFriend = "deleteCardFriend"
  /// 设置充值好友的限额
  case setCardFriendLimit = "setCardFriendLimit"
  /// 添加充值卡的好友
  case saveCardFriend = "saveCardFriend"
  /// 根据手机号搜索顾客信息
  case searchClientsByFields = "searchClientsByFields"
  /// 获取所有信用卡
  case getMethodsForApp = "getMethodsForApp"
  case deleteCardIntoPayment = "deleteCardIntoPayment"
  /// 获取用户取消预约次数
  case getClientCancelCount = "getClientCancelCount"
  /// 添加卡
  case addCardIntoPayment = "addCardIntoPayment"
  /// 保存当前的卡
  case saveNewGiftVoucher = "saveNewGiftVoucher"
  /// 获取税率
  case getTAllTaxes = "getTAllTaxes"
  /// 获取默认的负责员工
  case getBusiness = "getBusiness"
  case checkoutTOrder = "checkoutTOrder"
  /// 获取顾客的vip等级
  case getClientVipLevel = "getClientVipLevel"
  /// Stripe 支付金额
  case createInstance = "createInstance"
  /// 修改订单状态
  case payTOrder = "payTOrder"
  /// 朋友使用推荐
  case friendUseReferral = "friendUseReferral";
  /// 保存用户支付密码
  case saveTpd = "saveTpd"
  /// 获取用户支付密码
  case getClientPayPd = "getClientPayPd"
  /// 通过手机号获取一组用户信息
  case matchPhone = "matchPhone"
  case getQueryData = "getQueryData"
  case getParentCompanyBySysName = "getParentCompanyBySysName"
  case getNotices = "getNotices"
  case getAllCategories = "getAllCategories"
  case getClientCategory = "getClientCategory"
  case unDoNotices = "unDoNotices"
  case deleteNotices = "deleteNotices"
  case saveClientCategories = "saveClientCategories"
  
  /// 服务记录
  case getTSlotHistoryForApp = "getTSlotHistoryForApp"
  case getTUpcomingAppointments = "getTUpcomingAppointments"
  case getClientBookedServices = "getClientBookedServices"
  case cancelAppointments = "cancelAppointments"
  case getCanOnlineBookingLocations = "getCanOnlineBookingLocations"
  case getServicesByLocation = "getServicesByLocation"
  case getDocSchedulesForService = "getDocSchedulesForService"
  case checkCanBookService = "checkCanBookService"
  ///  保存在线预约服务
  case saveTOnlineBookingData = "saveTData"
  /// 保存在线预约服务(看诊)
  case saveDocTData = "saveDocTData"
  /// 根据服务的id获取员工信息
  case getAppEmployeeForService = "getAppEmployeeForService"
  /// Date和Time Slot: 选择某个员工后，根据员工和分店，获取他的排班数据
  case getEmployeeSchedules = "getEmployeeSchedules"
  /// 检查这段时间是否已经被其他顾客预约
  case checkServiceStaff = "checkServiceStaff"
  /// 选择date之后调用接口获取医师的id和Time Slot
  case getTreatDoctorSchedules = "getTreatDoctorSchedules"
  // 非指定预约获取日期
  case  getRandomDutyDates = "getRandomDutyDates"
  ///  .Date：获取日期，这个日期不是连续的 ScheduleController
  case getEmployeeDutyDates = "getEmployeeDutyDates"
  // 非指定预约获取时间
  case  getRandomTimeSlots = "getRandomTimeSlots"
  
  // 非指定预约检查是否可以预约
  case  checkRandomBookService = "checkRandomBookService"
  
  // 非指定预约保存
  case  saveAppRandonData = "saveAppRandonData"
  
  // 指定预约保存
  case  saveAppAssignData = "saveAppAssignData"
  
  //Time Slot: 接口ScheduleController
  case  getBookingTimeSlots = "getBookingTimeSlots"
  //Time Slot: 看诊
  case  getDocTimeSlots = "getDocTimeSlots"
  case saveTClient = "saveTClient"
  /// 获取优惠券
  case getFixedDiscount = "getFixedDiscount"
  
  // 获取当天问卷测试
  case getLastSymptomCheckReport = "getLastSymptomCheckReport"
  /// 检查病人是否已经挂号
  case checkConsulted = "checkConsulted"
  /// 获取某天某分店某类服务的排队数量和等待时间
  case getWaitServiceInfo = "getWaitServiceInfo"
  
  /// 通过手机获取系统所有的用户信息
  case getClientsByPhone = "getClientsByPhone"
  ///修改用户Source，注册方式
  case updateSource = "updateSource"
  //获取配置
  case  getTConfig = "getTConfig"
  // 获取所有国家
  case getTCountries = "getTCountries"
  /// 验证ic是否存在
  case clientICExists = "clientICExists"
  /// 验证推荐码是否存在
  case checkReferralCodeExists = "checkReferralCodeExists"
  /// 获取折扣用于注册时赠送顾客
  case getDiscountForRegister = "getDiscountForRegister"
  
  //获取客户产前问卷信息
  case getPrePartumItems = "getPrePartumItems"
  
  //获取产后详细信息
  case getPostPartumItems = "getPostPartumItems"
  
  //获取问卷
  case getTAllItems = "getTAllItems"
  /// 修改某次服务的状态并给看诊服务排队号
  case changeTStatus = "changeTStatus"
  
  // 物品购物车推送
  case itemsInCart = "itemsInCart";
  //
  case getIdByEmail = "getIdByEmail"
  //
  case deductionCreditsNote = "deductionCreditsNote";
  //
  case deductionAuthorisedNote = "deductionAuthorisedNote";
  //加人进钱包推送
  case addUserInWallet = "addUserInWallet";
  //从钱包删除人推送
  case deleteUserFromWallet = "deleteUserFromWallet";
  //升级推送
  case upgradedTierLevel = "upgradedTierLevel";
  //充值推送
  case topupNote = "topupNote";
  //注册推送
  case welcomeNote = "welcomeNote";
  //预约推送
  case newCreateAppointment = "newCreateAppointment";
}

enum Action:String {
  case Tax = "tax"
  case Blog = "blog"
  case SymptomCheck = "symptoms-check"
  case questionnaireSurvey = "questionnaire-survey"
  case Service = "service"
  case Client = "client"
  case SystemConfig = "system-config"
  case Sms = "sms"
  case Product = "product"
  case Company = "company"
  case Sale = "sale"
  case HelpManager = "help-manager"
  case TreatConditions = "treat-conditions"
  case Category = "category"
  case ClientProfile = "client-profile"
  case User = "user"
  case Voucher = "voucher"
  case RewardDiscounts = "reward-discounts"
  case GiftCertificate = "gift-certificate"
  case VipDefinition = "vip-definition"
  case SalesReport = "sales-report"
  case Notifications = "notifications"
  case PaymentMethod = "payment-method"
  case Employee = "employee"
  case StripePayment = "stripe-payment"
  case CardDiscountContent = "card-discount-content"
  case Query = "query"
  case BookingOrder = "booking-order"
  case Schedule = "schedule"
  case Country = "country"
  
}

struct WebUrl {
  static let services = "http://info.chienchitow.com/services/"
  static let conditionsWeTreat = "http://info.chienchitow.com/condition-we-treat/"
  static let ourStory = "http://info.chienchitow.com/about-us/"
  
}
