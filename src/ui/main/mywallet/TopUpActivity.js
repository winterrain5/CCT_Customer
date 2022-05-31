import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  FlatList,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions,
  NativeEventEmitter,
  NativeModules
} from 'react-native';


import TitleBar from '../../../widget/TitleBar';

import ProgressBar from '../../../widget/ProgressBar';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';

import MD5 from "react-native-md5";

const { PushManager } = NativeModules;
const MyPushManager = (Platform.OS.toLowerCase() != 'ios') ? '' : new NativeEventEmitter(PushManager);

let nativeBridge = NativeModules.NativeBridge;
export default class TopUpActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       amount:'$0.00',
       pay_amount:0.00,
       selected_method:undefined,
       new_time:undefined,//当前时间
       new_gift_voucher:undefined,
       tax:undefined,
       order_id:undefined,
       order_detail:undefined,
       point_present_multiple:'1',
    }
    this.subscription = (Platform.OS.toLowerCase() != 'ios')?'':MyPushManager.addListener('PaymentStatus',(reminder) => {

      //         nativeBridge.log("接收到native");
      //         nativeBridge.log(reminder);  

              if ((reminder + '') == '7') {

                // 进行订单修改
                this.payTOrder();

              }else {

                toastShort('Credit card payment failed');
              }

      
          });
      
  }

   UNSAFE_componentWillMount(){

    DeviceStorage.get('head_company_id').then((company_id) => {

      if (company_id) {
        this.setState({
            head_company_id: company_id,
          });
      }else {
        this.setState({
            head_company_id: '97',
          });

      }
    });

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

    });

    this.getSystemTime();

  }

   //注册通知
  componentDidMount(){

     var temporary = this;



     this.emit =  DeviceEventEmitter.addListener('selected_method',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         
           if (params) {

              this.setState({
                selected_method:JSON.parse(params,'utf-8')
              });
           }
     });

    
     
  }

  componentWillUnmount(){
    this.emit.remove();
    if (Platform.OS.toLowerCase() === 'ios') {

      //移除监听
    
      this.subscription.remove();
    
  }
  }



  getSystemTime(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
     '<v:Body><n0:getSystemTime id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('system-config','getSystemTimeResponse',data, function(json) {
    
        if (json && json.success == 1 && json.data ) {
              temporary.setState({
                new_time:json.data
              });   
        }

    });      


  }





  clickMethod(){


    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('TopUpMethodActivity');
    }

  }

  onChangeText(text){


    var new_amount = '';


    if (!text || text.length == 0 || text.length == 1) {

      new_amount = '$';

    }else {

      // if (text.length == 2) {

      //   if (text.substr(1,1) == '.') {
      //      new_amount = '$';
      //   }else {

      //     new_amount = text;

      //   }



      // }else {

      //   //除了末尾外 是否有小数点

      //   var isHasDian = false;

      //   for (var i = 0; i < text.length - 1; i++) {
      //     if (text.substr(i,1) == '.') {
      //       isHasDian = true;
      //       break;
      //     }
      //   }

      //   if (isHasDian && text.substr(text.length-1,1) == '.') {

      //     new_amount = text.substr(0,text.length - 2);

      //   }else {

      //     new_amount = text;
      //   }

       new_amount = text;

    }


   this.setState({
      amount:new_amount,
    });

  }


  clickAmount(amount){

    this.setState({

      amount:'$' + amount + '.00',

    })

  }

  clickToUp(){

    // 判断金额是否正常的

    var str_amount = this.state.amount;

    var amount = str_amount.substr(1,str_amount.length - 1);

    if (!StringUtils.isNumber(amount) || parseFloat(amount) <= 0) {

      toastShort('Please enter the correct amount');
      return;

    }

    //this.createInstance(); 

    this.setState({
      pay_amount:parseFloat(StringUtils.toDecimal(amount))
    });


    var temporary = this;

    nativeBridge.showPinView(this.state.userBean.pay_password,(error, result) => {
        
        if (result) {

          var userBean = this.state.userBean;

          userBean.pay_password = result;

          temporary.setState({
            userBean:userBean,
          });

          DeviceStorage.save('UserBean', userBean); 

         // 判断是否存在积分（只有信用卡支付才能获取积分）

          temporary.saveNewGiftVoucher(StringUtils.toDecimal(amount)); 
        }
    });




    //this.saveNewGiftVoucher(StringUtils.toDecimal(amount)); 

  }

  saveNewGiftVoucher(amount){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:saveNewGiftVoucher id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">is_delet</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">' +this.state.userBean.user_id + '</value></item>'+
    '<item><key i:type="d:string">create_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
    '<item><key i:type="d:string">name</key><value i:type="d:string">New Recharge Card</value></item>'+
    '<item><key i:type="d:string">recharge_level</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">voucher_value</key><value i:type="d:string">'+ amount +'</value></item>'+
    '<item><key i:type="d:string">recharge_type</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">enable_sales</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">service_type</key><value i:type="d:string">3</value></item>'+
    '<item><key i:type="d:string">expiry_period_date</key><value i:type="d:string">12</value></item>'+
    '<item><key i:type="d:string">voucher_type</key><value i:type="d:string">2</value></item>'+
    '<item><key i:type="d:string">default_count_in_pos</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">companyId</key><value i:type="d:string">97</value></item>'+
    '<item><key i:type="d:string">cct_mp_type</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">voucher_pay_code</key><value i:type="d:string"></value></item>'+
    '</data>'+
    '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
    '</logData></n0:saveNewGiftVoucher></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('voucher','saveNewGiftVoucherResponse',data, function(json) {
    
        if (json && json.success == 1 && json.data ) {
                
            temporary.setState({
              new_gift_voucher:json.data,
            });
            temporary.getTAllTaxes();
        } else {

           Loading.hidden();
           toastShort('Failed to create new recharge card');
        }

    });      

  }


  getTAllTaxes(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body>'+
     '<n0:getTAllTaxes id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
     '</n0:getTAllTaxes></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('tax','getTAllTaxesResponse',data, function(json) {
    
        if (json && json.success == 1 && json.data && json.data.length > 0) {
                
            temporary.setState({
              tax:json.data[0],
            });
            temporary.getBusiness();
        }else {

           Loading.hidden();
           toastShort('Failed to obtain tax rate！');
        }

    });      

  }

  getBusiness(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getBusiness id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('employee','getBusinessResponse',data, function(json) {
    
        if (json && json.success == 1 && json.data) {
                
            temporary.setState({
              business:json.data,
            });
            temporary.checkoutTOrder(json.data);
        }else {

           Loading.hidden();
           toastShort('Failed to obtain duty personnel！');
        }

    });      


  }


  checkoutTOrder(business){


      var uuid = StringUtils.uuid(6,16);

      var tax = 0.00;
      var voucher = this.state.pay_amount;
      var rate = parseFloat(this.state.tax.rate);

      tax = (voucher - (voucher / (1 + rate / 100)));


     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:checkoutTOrder id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+

     '<item><key i:type="d:string">Order_Lines</key><value i:type="n1:Map">'+

     '<item><key i:type="d:string">0</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">vouchers</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">0</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">present_balance</key><value i:type="d:string">'+ 0 +'</value></item>'+
     '<item><key i:type="d:string">present_value</key><value i:type="d:string">'+ 0 +'</value></item>'+
     '<item><key i:type="d:string">voucher_manual_code</key><value i:type="d:string">'+ uuid + '</value></item>'+
     '<item><key i:type="d:string">voucher_id</key><value i:type="d:string">'+ this.state.new_gift_voucher.id  +'</value></item>'+
     '<item><key i:type="d:string">create_date</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
     '<item><key i:type="d:string">voucher_type</key><value i:type="d:string">'+ 5 +'</value></item>'+
     '<item><key i:type="d:string">voucher_code</key><value i:type="d:string">'+ '1' +  MD5.hex_md5(uuid)+'</value></item>'+
     '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
     '</value></item></value></item>'+

     '<item><key i:type="d:string">data</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">create_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
     '<item><key i:type="d:string">tax_is_include</key><value i:type="d:string">'+ 1 +'</value></item>'+
     '<item><key i:type="d:string">staff_id</key><value i:type="d:string">'+ business.id +'</value></item>'+
     '<item><key i:type="d:string">location_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
     '<item><key i:type="d:string">tax_id</key><value i:type="d:string">'+ this.state.tax.id +'</value></item>'+
     '<item><key i:type="d:string">referrer</key><value i:type="d:string">'+ 0 +'</value></item>'+
     '<item><key i:type="d:string">present_qty</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">responsible_doctor</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">qty</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">product_unit_id</key><value i:type="d:string"></value></item>'+
     '<item><key i:type="d:string">delivery_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
     '<item><key i:type="d:string">appoint_sale_id</key><value i:type="d:string"></value></item>'+
     '<item><key i:type="d:string">delivery_location_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
     '<item><key i:type="d:string">discount_id</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">product_id</key><value i:type="d:int">'+ this.state.new_gift_voucher.id + '</value></item>'+
     '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
     '<item><key i:type="d:string">staff_id2</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">is_delete</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">has_delivered</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">tax</key><value i:type="d:string">'+ tax +'</value></item>'+
     '<item><key i:type="d:string">equal_staffs</key><value i:type="d:string"></value></item>'+
     '<item><key i:type="d:string">discount_id2</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">price</key><value i:type="d:string">'+ voucher+'</value></item>'+
     '<item><key i:type="d:string">cost</key><value i:type="d:string">'+ voucher +'</value></item>'+
     '<item><key i:type="d:string">retail_price</key><value i:type="d:string">'+ voucher + '</value></item>'+
     '<item><key i:type="d:string">product_category</key><value i:type="d:string">9</value></item>'+
     '<item><key i:type="d:string">collection_method</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">total</key><value i:type="d:string">'+ voucher +'</value></item>'+
     '<item><key i:type="d:string">name</key><value i:type="d:string">Top Up:'+ voucher +'</value></item>'+
     '</value></item></value></item></value></item>'+

     '<item><key i:type="d:string">Order_Info</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
     '<item><key i:type="d:string">create_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
     '<item><key i:type="d:string">customer_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
     '<item><key i:type="d:string">category</key><value i:type="d:string">2</value></item>'+
     '<item><key i:type="d:string">is_delete</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">company_id</key><value i:type="d:string">'+this.state.head_company_id +'</value></item>'+
     '<item><key i:type="d:string">location_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
     '<item><key i:type="d:string">due_date</key><value i:type="d:string">'+ DateUtil.formatDateTime1() +'</value></item>'+
     '<item><key i:type="d:string">status</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">invoice_date</key><value i:type="d:string">'+ DateUtil.formatDateTime()  +'</value></item>'+
     '<item><key i:type="d:string">is_from_app</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">type</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">total</key><value i:type="d:string">'+ voucher +'</value></item>'+
     '<item><key i:type="d:string">subtotal</key><value i:type="d:string">'+ voucher+'</value></item>'+
     '</value></item>'+
     '<item><key i:type="d:string">Client_Info</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">pay_password</key><value i:type="d:string">'+(this.state.userBean.pay_password ? this.state.userBean.pay_password : '')+'</value></item>'+
     '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
     '<item><key i:type="d:string">id</key><value i:type="d:string">'+ this.state.userBean.id  +'</value></item>'+
     '</value></item></data>'+

     '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
     '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
     '</logData></n0:checkoutTOrder></v:Body></v:Envelope>';
    
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('sale','checkoutTOrderResponse',data, function(json) {
    

        if (json && json.success == 1 && json.data ) {
            
            temporary.setState({
              order_id:json.data,
            });
            temporary.getCheckoutDetails(json.data);
        }else {
            Loading.hidden();
            toastShort('Failed to generate order！');
        }

    });      


  }

  getCheckoutDetails(order_id){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getCheckoutDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<orderId i:type="d:string">'+ order_id +'</orderId>'+
    '</n0:getCheckoutDetails></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sale','getCheckoutDetailsResponse',data, function(json) {

      if (json && json.success == 1 && json.data ) {
              
          temporary.setState({
            order_detail:json.data,
          });

          temporary.createInstance(json.data);
      }else {
          Loading.hidden();
          toastShort('Failed to generate order！');
      }
      
    });


  }



  createInstance(order_detail){



     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:createInstance id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">orderId</key><value i:type="d:string">'+ this.state.order_id +'</value></item>'+
     '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.userBean.email +'</value></item>'+
     '<item><key i:type="d:string">invoice_no</key><value i:type="d:string">'+ this.state.order_detail.Order_Info.invoice_no +'</value></item>'+
     '<item><key i:type="d:string">totalAmount</key><value i:type="d:string">' +  this.state.pay_amount * 100 +'</value></item>'+
     '</data></n0:createInstance></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('stripe-payment','createInstanceResponse',data, function(json) {
    

        if (json && json.success == 1 && json.data ) {
          
            temporary.setState({
              clientSecret:json.data.clientSecret
            });

            temporary.getClientVipLevel();
             
        }else {
          Loading.hidden();
          toastShort('Failed to generate credit card order number！');
        }

    });      

  }

   getClientVipLevel(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getClientVipLevel id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
     '</n0:getClientVipLevel></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sale','getClientVipLevelResponse',data, function(json) {
    

        if (json && json.success == 1 && json.data ) {
            temporary.setState({
              point_present_multiple:json.data.point_present_multiple
            });

            temporary.toPayActivity();
             
        }else {
          Loading.hidden();
          toastShort('Failed to obtain user points level！');
        }

    });      
    

  }



  toPayActivity(){

     Loading.hidden();

     var params = {};

     params.clientSecret = this.state.clientSecret;
     params.cvc = this.state.selected_method.method_lines[0].authorisation_code;
     params.number = this.state.selected_method.method_lines[0].card_number;
     var dates = this.state.selected_method.method_lines[0].expiry_date.split('-');
     params.expMonth = dates[1];
     params.expYear = dates[0];


     var str_params = JSON.stringify(params);

     //进行ios交互;
     nativeBridge.payment(str_params);

     
  }

  payTOrder(){

    var present_points = this.state.pay_amount;

    //当前是不是生日

    if (this.state.new_time && DateUtil.parserDateString(this.state.new_time) == DateUtil.parserDateString(this.state.userBean.birthday + ' 00:00:00')) {
      present_points *= 2;
    }

    present_points *= (parseInt(this.state.point_present_multiple));



     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:payTOrder id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+

     '<item><key i:type="d:string">payMethods</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">0</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">real_paid_amount</key><value i:type="d:string">'+ this.state.pay_amount +'</value></item>'+
     '<item><key i:type="d:string">pay_method_card_id</key><value i:type="d:string">'+ this.state.selected_method.method_lines[0].id +'</value></item>'+
     '<item><key i:type="d:string">pay_method_line_id</key><value i:type="d:string">'+  this.state.selected_method.id  +'</value></item>'+
     '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">'+ this.state.pay_amount +'</value></item>'+
     '</value></item></value></item>'+

     '<item><key i:type="d:string">Order_Lines</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">0</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">data</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">salesmen_id</key><value i:type="d:string">'+ this.state.business.id +'</value></item>'+
     '<item><key i:type="d:string">pay_by_gift</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">has_paid</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">pay_by_service</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">pay_by_voucher</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">new_recharge_discount</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">pay_by_balance</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">id</key><value i:type="d:string">'+ this.state.order_detail.Order_Line_Info[0].id +'</value></item>'+
     '</value></item></value></item></value></item>'+

     '<item><key i:type="d:string">Order_Info</key><value i:type="n1:Map">'+
     '<item><key i:type="d:string">balance</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">total_recharge_discount</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">pay_by_gift</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">close_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
     '<item><key i:type="d:string">invoice_date</key><value i:type="d:string">'+ DateUtil.formatDateTime1() +'</value></item>'+
     '<item><key i:type="d:string">gift_voucher_amount</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">new_gift_voucher_amount</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">change</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">present_points</key><value i:type="d:string">'+ present_points +'</value></item>'+
     '<item><key i:type="d:string">origin_paid_amount</key><value i:type="d:string">'+ this.state.pay_amount +'</value></item>'+
     '<item><key i:type="d:string">id</key><value i:type="d:int">'+ this.state.order_detail.Order_Info.id +'</value></item>'+
     '<item><key i:type="d:string">status</key><value i:type="d:string">1</value></item>'+
     '<item><key i:type="d:string">pay_by_service</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">pay_by_balance</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">remark</key><value i:type="d:string"></value></item>'+
     '<item><key i:type="d:string">due_date</key><value i:type="d:string">'+ DateUtil.formatDateTime1() +'</value></item>'+
     '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">'+ this.state.pay_amount +'</value></item>'+
     '<item><key i:type="d:string">voucher_amount</key><value i:type="d:string">0</value></item>'+
     '<item><key i:type="d:string">saleman_id</key><value i:type="d:string">'+ this.state.business.id +'</value></item>'+
     '<item><key i:type="d:string">date</key><value i:type="d:string">'+ DateUtil.formatDateTime1() + '</value></item>'+
     '<item><key i:type="d:string">is_from_app</key><value i:type="d:string">1</value></item></value></item>'+
     '<item><key i:type="d:string">bookingTimesData</key><value i:type="n1:Map" /></item></data>'+

     '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
     '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id + '</value></item>'+
     '</logData>'+

     '</n0:payTOrder></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    console.error('data:'+data);
    WebserviceUtil.getQueryDataResponse('sale','payTOrderResponse',data, function(json) {
      
        if (json && json.success == 1  ) {
           

            DeviceEventEmitter.emit('user_money_up','ok');
        
           // 支付成功
            temporary.topupNote();
        }else {
          Loading.hidden();

          toastShort('Order modification failed!');
        }

        console.error('json:'+json);

    });      
    
  }

  topupNote(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:topupNote id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<amount i:type="d:string">'+ this.state.pay_amount +'</amount>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:topupNote></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('notifications','topupNoteResponse',data, function(json) {
    
       
        
    });      
    
    temporary.deductionCreditsNote();
  }

  deductionCreditsNote(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:deductionCreditsNote id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<amount i:type="d:string">'+ this.state.pay_amount +'/amount>'+
    '<orderNo i:type="d:string">'+ this.state.order_detail.Order_Info.invoice_no+'</orderNo>'+
    '<clientId i:type="d:string">326802</clientId>'+
    '</n0:deductionCreditsNote></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('notifications','deductionCreditsNoteResponse',data, function(json) {
    

        
        
    });   

    temporary.getTClientPartInfo();

  }


  getTClientPartInfo(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {
         temporary.upAppClitent(json.data);
      
    });

  }

  upAppClitent(newUser){
    Loading.hidden();
    toastShort('Top up success!')
    DeviceStorage.update('UserBean', newUser);  
    DeviceEventEmitter.emit('user_update',JSON.stringify(newUser));
    this.props.navigation.goBack();
  }





 

  render() {

     const { navigation } = this.props;

     return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


        <SafeAreaView style = {styles.afearea} >

          <TitleBar
            title = {'Top Up'} 
            navigation={navigation}
            hideLeftArrow = {true}
            hideRightArrow = {false}
            extraData={this.state}/>

          <View style = {styles.view_content}>


            <View style = {styles.view_method}>

                <Text style = {styles.text_method}>Payment Method</Text>


                <TouchableOpacity 
                    onPress={this.clickMethod.bind(this)}
                    activeOpacity = {0.8 }>


                     <View style = {styles.view_coupon}>


                        <Image 
                          style={{width:22,height:22,}}
                          source={require('../../../../images/ver_12_27.png')}
                          resizeMode = 'contain' />


                        <Text style = {[styles.text_selsected_value,{color:this.state.selected_method ? '#333333':'#828282'}]}>{this.state.selected_method ? this.state.selected_method.method_lines[0].name_on_card : 'Add Payment Method'}</Text>


                        <Image 
                          style={{width:8,height:12, marginLeft:8,}}
                          source={require('../../../../images/you.png')}
                          resizeMode = 'contain' />

                      </View>

                              
                  </TouchableOpacity> 

            </View>


           <View style = {styles.view_line} />


           <View style = {styles.view_method}>

                <Text style = {styles.text_method}>Top Up Amount</Text>


                <View style = {styles.view_edit}>


                   <TextInput 
                      style = {styles.text_input}
                      ref='intput_amount'
                      placeholder=''
                      multiline = {false}
                      textAlign = 'center'
                      value = {this.state.amount} 
                      onChangeText={(text) => {
                       
                         this.onChangeText(text);
                       
                        }  
                      }/>

                </View>


                <View style = {styles.view_amount_list}>


                  <TouchableOpacity 
                      onPress={this.clickAmount.bind(this,'100')}
                      activeOpacity = {0.8 }>

                       <View style = {styles.view_amount_item}>

                          <Text style= {styles.text_amount_item}>$100</Text>

                      </View>


                  </TouchableOpacity>  


                 

                  <TouchableOpacity 
                      onPress={this.clickAmount.bind(this,'200')}
                      activeOpacity = {0.8 }>

                       <View style = {styles.view_amount_item}>

                          <Text style= {styles.text_amount_item}>$200</Text>

                      </View>


                  </TouchableOpacity>  



                  <TouchableOpacity 
                      onPress={this.clickAmount.bind(this,'500')}
                      activeOpacity = {0.8 }>

                       <View style = {styles.view_amount_item}>

                          <Text style= {styles.text_amount_item}>$500</Text>

                      </View>


                  </TouchableOpacity>  


                </View>



                <View style = {[styles.view_amount_list,{marginTop:16}]}>


                  <TouchableOpacity 
                      onPress={this.clickAmount.bind(this,'1000')}
                      activeOpacity = {0.8 }>

                       <View style = {styles.view_amount_item}>

                          <Text style= {styles.text_amount_item}>$1000</Text>

                      </View>

                  </TouchableOpacity>  


                  <TouchableOpacity 
                      onPress={this.clickAmount.bind(this,'2000')}
                      activeOpacity = {0.8 }>

                       <View style = {styles.view_amount_item}>

                          <Text style= {styles.text_amount_item}>$2000</Text>

                      </View>

                  </TouchableOpacity>  



                  <TouchableOpacity 
                      onPress={this.clickAmount.bind(this,'2500')}
                      activeOpacity = {0.8 }>

                       <View style = {styles.view_amount_item}>

                          <Text style= {styles.text_amount_item}>$2500</Text>

                      </View>

                  </TouchableOpacity>  

                </View>

           </View>

        
          
          </View>



           <View style = {styles.next_view}>

                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:this.state.selected_method ? '#C44729' : '#BDBDBD'}]}  
                      activeOpacity = {this.state.selected_method  ? 0.8 : 1}
                      onPress={this.clickToUp.bind(this)}>

                    <Text style = {styles.next_text}>Top Up</Text>

                  </TouchableOpacity>

              </View>




        </SafeAreaView>

  
        <SafeAreaView style = {styles.afearea_foot} />     

      </View>

    );

  }

}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
   afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
   view_content:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_method : {
    width:'100%',
    padding:24,
  },
  text_method:{
    color:'#145A7C',
    fontSize:18,
    fontWeight: 'bold',
  },
   view_coupon:{
    paddingTop:16,
    paddingBottom:16,
    width:'100%',
    flexDirection: 'row',
    alignItems: 'center',
  },
  text_selsected_value:{
    marginLeft:5,
    flex:1,
    color:'#333333',
    fontSize:18,
  },
  view_line:{
    width:'100%',
    backgroundColor:'#E0e0e0',
    height:1,
  },
  view_edit:{
    marginTop:22,
    backgroundColor:'#F2F2F2',
    width:'100%',
    height:68,
    borderRadius:16,
  },
  text_input:{
    flex:1,
    color:'#145A7C',
    fontSize:32,
    fontWeight:'bold',
  },
  view_amount_list:{
    marginTop:34,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  view_amount_item:{
    width:98,
    height:44,
    backgroundColor:'#F2F2F2',
    borderRadius:16,
    flexDirection: 'row',
    alignItems: 'center',
  },
  text_amount_item:{
    width:'100%',
    color:'#333333',
    fontSize:16,
    fontWeight:'bold',
    textAlign :'center',
  },
  next_layout:{
      width:'100%',
      height:44,
      backgroundColor:'#C44729',
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'
  },
  next_text :{
      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',
  },
  next_view:{
    padding:24,
    backgroundColor:'#FFFFFF'
  },
});

