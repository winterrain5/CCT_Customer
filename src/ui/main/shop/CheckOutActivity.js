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
  NativeEventEmitter,
  NativeModules
} from 'react-native';


import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import TitleBar from '../../../widget/TitleBar';

const { PushManager } = NativeModules;
const MyPushManager = (Platform.OS.toLowerCase() != 'ios') ? '' : new NativeEventEmitter(PushManager);

let nativeBridge = NativeModules.NativeBridge;


export default class CheckOutActivity extends Component {



   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       buy_now:0,
       order_id:undefined,
       order_detail:undefined,
       products:[],
       post_code:undefined,
       street_name:undefined,
       building_block_num:undefined,
       unit_num:undefined,
       city:undefined,
       new_time:undefined,//当前时间
       method_type:0, // 付款方式 0 ：会员卡，1：朋友的卡 2：信用卡
       selected_voucher:undefined, // 选择的礼券
       selected_coupon:undefined, // 选择的折扣
       delivery_fee:undefined,
       selected_location:{'id':'-1'}, 
       selected_popup_location:undefined,
       discount_percent:0,//当前会员卡享受的百分比优惠
       client_voucher:undefined,//当前会员余额
       items_count:0,
       business_id:undefined,//默认员工id,
       point_present_multiple:'0',//积分
       method_card_detail:undefined, // 信用卡支付时，卡的信息
    }
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

    if (this.props) {

      if (this.props.order_id) {

         this.setState({
            order_id:this.props.order_id,
          });

       // 获取订单详情
        this.getCheckoutDetails(this.props.order_id);

      }else if (this.props.route.params){

        this.setState({
          order_id:this.props.route.params.order_id,
        });
  
         // 获取订单详情
        this.getCheckoutDetails(this.props.route.params.order_id);

      }

    } 
    
    DeviceStorage.get('UserBean').then((user_bean) => {

      if (user_bean) {

        this.setState({
             userBean: user_bean,
             post_code:user_bean.post_code,
             street_name:user_bean.street_name,
             building_block_num:user_bean.building_block_num,
             unit_num:user_bean.unit_num,
             city:user_bean.city,
        });

      }

      //获取当前人员会员卡余额
      this.getNewReCardAmountByClientId(user_bean);

      // 获取会员卡享受的百分比优惠
      this.getNewCardDiscountsByLevel(user_bean.new_recharge_card_level);

    });
  
    // // 获取运费
    // this.getTSystemConfig();  


    // 获取默认人员
    this.getBusiness();


    //获取当前时间
    this.getSystemTime();


  }


   //注册通知
  componentDidMount(){


    var temporary = this;


     this.subscription = (Platform.OS.toLowerCase() != 'ios')?'':MyPushManager.addListener('PaymentStatus',(reminder) => {

        if ((reminder + '') == '7') {

          // 进行订单修改
          temporary.payTOeder();

        }else {

          toastShort('Credit card payment failed');
        }

      
    });



    this.emit =  DeviceEventEmitter.addListener('selected_coupon',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

          if (params) {

            var new_selected_coupon = JSON.parse(params,'utf-8');

            if (temporary.state.selected_coupon && new_selected_coupon && temporary.state.selected_coupon.id == new_selected_coupon.id) {

                temporary.setState({
                  selected_coupon:undefined,
                });


            }else {

                temporary.setState({
                  selected_coupon:new_selected_coupon,
                });


            }

          }
        
     });


    this.emit1 =  DeviceEventEmitter.addListener('selected_voucher',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

          if (params) {

            var new_selected_voucher = JSON.parse(params,'utf-8');

            if (temporary.state.selected_voucher && new_selected_voucher && temporary.state.selected_voucher.id == new_selected_voucher.id) {

                temporary.setState({
                  selected_voucher:undefined,
                });

            }else {

                temporary.setState({
                  selected_voucher:new_selected_voucher,
                });


            }

          }
        
     });


    this.emit2 =  DeviceEventEmitter.addListener('selected_payment_method',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

          if (params) {

            var new_selected_payment_method = JSON.parse(params,'utf-8');

            if (new_selected_payment_method) {

              var method_type = new_selected_payment_method.select_type;

              var method_card_detail = undefined;

              if (method_type == 2 || method_type == 1) {

                method_card_detail = new_selected_payment_method.method_detail;

              }


              if (method_type == 1  ) {

                temporary.getNewCardDiscountsByLevel(method_card_detail.new_recharge_card_level);

              }else if (method_type == 0) {


                temporary.getNewCardDiscountsByLevel(this.state.userBean.new_recharge_card_level)

              }




              this.setState({
                method_type:method_type,
                method_card_detail:method_card_detail,
              });

            }

            

          }
        
     });



     this.emit3 =  DeviceEventEmitter.addListener('shop_over',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

          
          if (this.props.pressLeft) {
            this.props.pressLeft();
       
          }else if (this.props.navigation) {
            this.props.navigation.goBack();
       
          }else {
           nativeBridge.goBack();

         }
        
     });



  }


  componentWillUnmount(){
    this.subscription.remove();
    this.emit.remove();
    this.emit1.remove();
    this.emit2.remove();
    this.emit3.remove();

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


  getBusiness(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getBusiness id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('employee','getBusinessResponse',data, function(json) {

    
        if (json && json.success == 1 && json.data ) {
          
            temporary.setState({
               business_id:json.data.id,   

            });
        }

    });


  }





  getNewReCardAmountByClientId(userBean){

     var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewReCardAmountByClientId id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<clientId i:type="d:string">' + userBean.id +'</clientId>'+
     '</n0:getNewReCardAmountByClientId></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('voucher','getNewReCardAmountByClientIdResponse',data, function(json) {
        
      if (json && json.success == 1 && json.data ) {

        temporary.setState({
          client_voucher:json.data,
        });
      
      }
      
    });
  }





  getNewCardDiscountsByLevel(new_recharge_card_level){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewCardDiscountsByLevel id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id + '</companyId>'+
    '<cardLevel i:type="d:string">'+ new_recharge_card_level+'</cardLevel>'+
    '</n0:getNewCardDiscountsByLevel></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('vip-definition','getNewCardDiscountsByLevelResponse',data, function(json) {
        
      if (json && json.success == 1 && json.data ) {


        for (var i = 0; i < json.data.length; i++) {

          if (json.data[i].sale_category && json.data[i].sale_category  == 'P' && json.data[i].discount_percent) {

              temporary.setState({
                  discount_percent:parseFloat(json.data[i].discount_percent) ,
              });

              break;

          }

        }
      }
      
    });



  }



  getTSystemConfig(){


    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTSystemConfig id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">' + this.state.head_company_id+ '</companyId>'+
    '<columns i:type="d:string">delivery_fee</columns>'+
    '</n0:getTSystemConfig></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('system-config','getTSystemConfigResponse',data, function(json) {
        
      if (json && json.success == 1 && json.data ) {
          temporary.setState({
            delivery_fee:json.data.delivery_fee,
          });

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
          
          var items_count = 0;

          if (json.data.Order_Line_Info) {

            for (var i = 0; i < json.data.Order_Line_Info.length; i++) {
                items_count += parseInt(json.data.Order_Line_Info[i].qty);  
            }

          }

          temporary.setState({
            order_detail:json.data,
            products:json.data.Order_Line_Info,
            items_count:items_count,
          });


          var subtotal = 0;

          try {

            subtotal = parseFloat(json.data.Order_Info.subtotal);
          }catch(e){

          }

          if (subtotal >= 150) {

            temporary.setState({
               delivery_fee:'0.00',
            });

          }else {
            temporary.getTSystemConfig();
          }


      }
      
    });


  }






  _items(){


    if (this.state.products && this.state.products.length > 0) {

      var items = [];

      for (var i = 0; i < this.state.products.length; i++) {


        var item = this.state.products[i];
        
        var picture = item.picture;
        var image_url = '';
        if (picture) {
          image_url = picture.slice(1,picture.length);
        }


        items.push(

          <View style = {{width:'100%'}} key = {i + ''}>

              <View style = {{width:'100%',padding:16,flexDirection: 'row',}}>


                <View style = {styles.view_image_card}>

                   <Image 
                    style={{flex:1,borderRadius:16}}
                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                    resizeMode="cover" />

                </View>

                <Text style = {styles.text_view_num}>{parseInt(item.qty)} x</Text>


                <Text style = {styles.text_view_name}>{item.name}</Text>

                <Text style = {styles.text_view_price}>${StringUtils.toDecimal(item.total)}</Text>


              </View>



              <View style = {styles.view_line} />




          </View>
       
        );
        
      }

    
     return (
     
      <View style = {{width:'100%',backgroundColor:'#FAF3EB'}}>


        {items}

        
      </View>


     ); 




    }else {


      return (<View />);


    }


  }




  _renderItem = (item) =>{


    return (

      <View>


      </View>


      );

  }

  _footer() {



    var method_name = '';
    var method_selsected_value = '';

    if (this.state.method_type == 0) {

      method_name = 'CCT Wallet';

      if (this.state.client_voucher != undefined) {

        method_selsected_value = ('$' + StringUtils.toDecimal(this.state.client_voucher));

      }else {

        method_selsected_value  = '$0.00';

      }

    }else if (this.state.method_type == 1) {

      method_name = 'Friend Card';

       if (this.state.method_card_detail != undefined) {

          if (this.state.method_card_detail.first_name) {
            method_selsected_value +=  this.state.method_card_detail.first_name;
          }

          if (this.state.method_card_detail.last_name) {
            method_selsected_value +=  (' ' +  this.state.method_card_detail.last_name);
          }


       }else {

          method_selsected_value = '';

       }


    }else if (this.state.method_type == 2) {

       method_name = 'Card';

      if (this.state.method_card_detail != undefined) {

          method_selsected_value = this.state.method_card_detail.method_lines[0].name_on_card;

      }else {

          method_selsected_value = '';
      }


    }





    return (

      <View style = {{width:'100%'}}>



        <TouchableOpacity 
          onPress={this.clickCoupon.bind(this)}
          activeOpacity = {0.8 }>


           <View style = {styles.view_coupon}>


              <Text style = {styles.text_title}>Select Coupon</Text>

              <Text style = {styles.text_selsected_value}>{this.state.selected_coupon ? this.state.selected_coupon.name : 'Not Selected'}</Text>


              <Image 
                style={{width:8,height:12, marginLeft:8,}}
                source={require('../../../../images/you.png')}
                resizeMode = 'contain' />

            </View>

                    
        </TouchableOpacity>              


        <View style = {styles.view_line}/>


         <Text style = {[styles.text_title,{margin:16}]}>Payment Method</Text>



         <TouchableOpacity 
          onPress={this.clickPaymentMethod.bind(this)}
          activeOpacity = {0.8 }>


           <View style = {styles.view_coupon}>


               <Image 
                style={{width:20,height:20, marginLeft:8,}}
                source={this.state.method_type == 0 ? require('../../../../images/home_logo.png') : require('../../../../images/qianbao_526.png')}
                resizeMode = 'contain' />


              <Text style = {styles.text_title_1}>{method_name}</Text>

              <Text style = {styles.text_selsected_value}>{method_selsected_value}</Text>


              <Image 
                style={{width:8,height:12, marginLeft:8,}}
                source={require('../../../../images/you.png')}
                resizeMode = 'contain' />

            </View>

                    
        </TouchableOpacity> 



         <TouchableOpacity 
          onPress={this.clickVoucher.bind(this)}
          activeOpacity = {0.8 }>


           <View style = {styles.view_coupon}>


              <Text style = {styles.text_title_1}>Select Voucher</Text>

              <Text style = {styles.text_selsected_value}>{this.state.selected_voucher ? this.state.selected_voucher.name : 'Not Selected'}</Text>


              <Image 
                style={{width:8,height:12, marginLeft:8,}}
                source={require('../../../../images/you.png')}
                resizeMode = 'contain' />

            </View>

                    
        </TouchableOpacity> 


        <View style = {styles.view_line}/>   


        <Text style = {[styles.text_title,{margin:16}]}>Collection Method</Text>    



        <TouchableOpacity 
          onPress={this.clickCollectionMethod.bind(this)}
          activeOpacity = {0.8 }>


           <View style = {styles.view_coupon}>


              <Text style = {[styles.text_selsected_value,{textAlign:'left',fontWeight:'bold'}]}>{this.state.selected_location.id != '-1'  ? 'Self-Collection @ ' + (this.state.selected_location.alias_name ? this.state.selected_location.alias_name : this.state.selected_location.name) : 'Local Delivery $' + this.state.delivery_fee}</Text>


              <Image 
                style={{width:25,height:25, marginLeft:8,}}
                source={require('../../../../images/dropdownxxxhdpi.png')}
                resizeMode = 'contain' />

            </View>

                    
        </TouchableOpacity> 



         <View style = {styles.view_line}/>   



         {this.shippingAddress()}
     


      </View>


      );

  }


  shippingAddress(){


    if (this.state.selected_location.id == '-1' ) {

        return( 

      <View style = {{width:'100%'}}>

          <Text style = {[styles.text_title,{margin:16}]}>Shipping Address</Text>    


         <View style = {styles.view_iparinput}>
                <IparInput
                    valueText = {this.state.post_code} 
                    placeholderText={'Postal Code*'}
                    onChangeText={(text) => {
                         
                      this.setState({post_code:text})
                    }}/>

            </View>


            <View style = {styles.view_iparinput}>
                <IparInput 
                    valueText = {this.state.street_name} 
                    placeholderText={'Street Name*'}
                    onChangeText={(text) => {
                         
                      this.setState({street_name:text})
                    }}/>

            </View>



            <View style = {styles.view_iparinput}>
                <IparInput
                    valueText = {this.state.building_block_num} 
                    placeholderText={'Building/Block Number*'}
                    onChangeText={(text) => {
                         
                      this.setState({building_block_num:text})
                    }}/>

            </View>


            <View style = {styles.view_iparinput}>
                <IparInput 
                    valueText = {this.state.unit_num}
                    placeholderText={'Unit Number'}
                    onChangeText={(text) => {
                         
                      this.setState({unit_num:text})
                    }}/>

            </View>


            <View style = {styles.view_iparinput}>
                <IparInput 
                    valueText = {this.state.city}
                    placeholderText={'city'}
                    onChangeText={(text) => {
                         
                      this.setState({city:text})
                    }}/>

            </View>



      </View>

      );




    }else {


      return (<View />)


    }




    

  }



  clickCoupon(){

    if (this.props.isNative) {

      NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'CouponActivity',property:{
        'selected_type':0,
        'selected_coupon':this.state.selected_coupon,
      }})
      return;
    }
    const { navigation } = this.props;

    if (navigation) {
       navigation.navigate('CouponActivity',{
        'selected_type':0,
        'selected_coupon':this.state.selected_coupon,
      });

    }
  }

  clickPaymentMethod(){

    if (this.props.isNative) {

      NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'PaymentMethodActivity'})
      return;
    }
     const { navigation } = this.props;
      if (navigation) {
        navigation.navigate('PaymentMethodActivity');
      }
  }


  clickVoucher(){
    if (this.props.isNative) {

      NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'CouponActivity',property:{
        'selected_type':1,
        'selected_coupon':this.state.selected_voucher,
      }})
      return;
    }
    const { navigation } = this.props;

    if (navigation) {
       navigation.navigate('CouponActivity',{
        'selected_type':1,
        'selected_coupon':this.state.selected_voucher,
      });

    }


  }

  clickCollectionMethod(){

    this.getCanSendProductLocations();


  }


  getCanSendProductLocations(){


    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getCanSendProductLocations id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '</n0:getCanSendProductLocations></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('company','getCanSendProductLocationsResponse',data, function(json) {
          
      if (json && json.success == 1 && json.data ) {
          
          temporary.showProductLocationsPopup(json.data);
      }
      
    });



  }


  showProductLocationsPopup(data){


    this.setState({
      selected_popup_location:this.state.selected_location,
    })



    data.unshift({'id':'-1'});

   this.coverLayer.showWithContent(
            ()=> {
                return (
                    <View style={styles.view_popup_bg}>


                      <Text style = {styles.text_popup_title}>Collection Method</Text>

                      <FlatList
                          style = {styles.flat_popup}
                          ref = {(flatList) => this._flatList = flatList}
                          renderItem = {this._renderItem}
                          onEndReachedThreshold={0}
                          keyExtractor={(item, index) => index.toString()}
                          data={data}/>

                       <View style = {[styles.next_view,{width:'100%'}]}>

                          <TouchableOpacity style = {[styles.next_layout]}  
                              activeOpacity = {0.8 }
                              onPress={this.clickSelectLocation.bind(this)}>


                                 <Text style = {styles.next_text}>Select</Text>

                          </TouchableOpacity>

                       </View>
                    
                    </View>
                )
            },
        ()=>this.coverLayer.hide(),
        CoverLayer.popupMode.bottom);


  }


  _renderItem = (item) => {


      return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.selectedLocations.bind(this,item)}>


          <View style = {{marginTop:4,marginBottom:4}}>

            <View style = {[styles.view_item,{backgroundColor:this.state.selected_popup_location.id == item.item.id ? '#F2F2F2' : '#FFFFFF'}]}>

              <Text style = {[styles.text_item_title,{color:this.state.selected_popup_location.id == item.item.id ? '#C44729' : '#BDBDBD'}]}>{item.item.id != '-1'  ? 'Self-Collection @ ' + (item.item.alias_name ? item.item.alias_name : item.item.name) : 'Local Delivery $' + this.state.delivery_fee}</Text>

            </View>

          </View>

        
        </TouchableOpacity>  

      );

  }


  selectedLocations(item){


    this.setState({
      selected_popup_location:item.item,
    });
  }


  clickSelectLocation(){

    this.coverLayer.hide();
    this.setState({
      selected_location:this.state.selected_popup_location,
    });

  }



  _total(){


   if (!this.state.order_detail) {

      return (<View />);
   }  


   var sub_total = parseFloat(this.state.order_detail.Order_Info.subtotal);

   var coupon_total = 0;

   var vocher_total = 0;

   var delivery_total = 0;

   var total = 0;

   if (!this.state.selected_coupon) {
      // 没有使用折扣

      if (this.state.method_type == 0 ||  this.state.method_type == 1) { // 会员卡,朋友的卡优惠

        coupon_total = sub_total*this.state.discount_percent / 100;

      }else {

        // 信用卡不享受会员卡优惠


      }

   }else{
      // 用了折扣

      if (this.state.selected_coupon.value_type == '1') { // 当前的折扣属于的类型 百分比 和 具体金额

        //百分比折扣

        coupon_total = sub_total *parseFloat(this.state.selected_coupon.nominal_value) ;



      }else {

        // 具体金额
        coupon_total =  parseFloat(this.state.selected_coupon.nominal_value);

      }

   }



   //礼券 （礼券只有现金）
   if (this.state.selected_voucher) {

      vocher_total = parseFloat(this.state.selected_voucher.balance);

   }


   // 运费
   if (this.state.selected_location && this.state.selected_location.id == '-1') {

      delivery_total = parseFloat(this.state.delivery_fee);

   }


   // 如果 支付金额大于 150的话， 免运费

   // if (sub_total - coupon_total - vocher_total >= 150) {

   //    delivery_total = 0.00;

   // }



   //需要支付的总金额

   if (sub_total <= coupon_total + vocher_total) {


      total = delivery_total;

   }else {

      total = sub_total - coupon_total - vocher_total + delivery_total;

   }




    return (

      <View style = {{width:'100%',padding:16,marginTop:8}}>

          <View style = {styles.view_total_item}>

            <Text style = {styles.text_total_title}>Total Items</Text>

            <Text style = {styles.text_total_title}>{this.state.items_count}</Text>


          </View>



          <View style = {styles.view_total_item}>

            <Text style = {styles.text_total_title}>Sub Total(GST Inclusive)</Text>

            <Text style = {styles.text_total_title}>${StringUtils.toDecimal(sub_total)}</Text>


          </View>


          {this.totalCopon(coupon_total)}


          {this.totalVocher(vocher_total)}


          {this.totalLocalFee(delivery_total)}



          <View style = {[styles.view_total_item]}>

            <Text style = {[styles.text_total_title,{fontWeight:'bold'}]}>Total</Text>

            <Text style = {[styles.text_total_title,{fontWeight:'bold'}]}>${StringUtils.toDecimal(total)}</Text>


          </View>
  





      </View>



      );

  }


  totalLocalFee(total){


    if (total > 0) {

      return (

          <View style = {styles.view_total_item}>

            <Text style = {styles.text_total_title}>Local Delivery Fee</Text>

            <Text style = {styles.text_total_title}>${StringUtils.toDecimal(total)}</Text>


          </View>
      );

    }else {


      return (<View/>);

    }


  }

  totalCopon(total){

    if (total > 0) {

      return (

          <View style = {styles.view_total_item}>

            <Text style = {styles.text_total_title}>{this.state.selected_coupon == undefined ? 'Discount' : 'Coupon'}</Text>

            <Text style = {styles.text_total_title}>-${StringUtils.toDecimal(total)}</Text>


          </View>
      );

    }else {


      return (<View/>);

    }

  }

  totalVocher(total){

    if (total > 0) {

      return (

          <View style = {styles.view_total_item}>

            <Text style = {styles.text_total_title}>Voucher</Text>

            <Text style = {styles.text_total_title}>-${StringUtils.toDecimal(total)}</Text>


          </View>
      );

    }else {


      return (<View/>);

    }

  }



  clickPlace(){


    if (this.state.selected_location.id == '-1') {

      // 选择邮寄的话，需要填写邮寄地址

      if (!this.state.post_code) {

        toastShort('Please fill in the Post Code');
        return;
      }

      if (!StringUtils.isPostCode(this.state.post_code)) {

        toastShort('Post Code entered is invalid');
        return;

      }


      if (!this.state.street_name) {
        toastShort('Please fill in the Street Name');
        return;
      }

      if (!this.state.building_block_num) {
        toastShort('Please fill in the Building/Block Number');
        return;
      }

      // if (!this.state.unit_num) {
      //   toastShort('Please fill in the Unit Number');
      //   return;
      // }

      // if (!this.state.city) {
      //   toastShort('Please fill in the City');
      //   return;
      // }
    }

   

   var sub_total = parseFloat(this.state.order_detail.Order_Info.subtotal);

   var coupon_total = 0;

   var vocher_total = 0;

   var delivery_total = 0;

   var total = 0;

   if (!this.state.selected_coupon) {
      // 没有使用折扣

      if (this.state.method_type == 0) { // 会员卡优惠

        coupon_total = sub_total*this.state.discount_percent / 100;

      }else {

        // 朋友的卡和信用卡不享受会员卡优惠


      }

   }else{
      // 用了折扣

      if (this.state.selected_coupon.value_type == '1') { // 当前的折扣属于的类型 百分比 和 具体金额

        //百分比折扣

        coupon_total = sub_total *parseFloat(this.state.selected_coupon.nominal_value) ;



      }else {

        // 具体金额
        coupon_total =  parseFloat(this.state.selected_coupon.nominal_value);

      }

   }



   //礼券 （礼券只有现金）
   if (this.state.selected_voucher) {

      vocher_total = parseFloat(this.state.selected_voucher.balance);

   }


   // 运费
   if (this.state.selected_location && this.state.selected_location.id == '-1') {


      delivery_total = parseFloat(this.state.delivery_fee);

   }

   // 150以上免运费
   // if (sub_total - coupon_total - vocher_total) {

   //    delivery_fee = 0.00;

   // }



   //需要支付的总金额

   if (sub_total <= coupon_total + vocher_total) {


      total = delivery_total;

   }else {

      total = sub_total - coupon_total - vocher_total + delivery_total;

   }


   // 判断是否可以进行支付
   if (this.state.method_type == 0) {
      // 自己的会员卡
      if (total > this.state.client_voucher) {
          toastShort('Current balnace is insufficient');
          return;
      }

   }else if (this.state.method_type == 1) {
      // 朋友的卡

      // 判断金额，和限制金额是否达标

      var new_card_amount = 0;  // 卡的余额

      try {

        new_card_amount = parseFloat(this.state.method_card_detail.new_card_amount);

      }catch(e){

      }

      if (this.state.method_card_detail.trans_limit != undefined && this.state.method_card_detail.trans_limit  == '-1.00') {

        // 卡无限制


        if (new_card_amount < total) {

          toastShort('The current friend‘s card balance is insufficient');

          return;
        }


      }else {

        // 卡有限制

        var trans_limit = 0;

        try{
          trans_limit = parseFloat(this.state.method_card_detail.trans_limit);
        }catch(e){

        }

        //现比较 余额与限制大小

        if (trans_limit >= new_card_amount) {


          if (new_card_amount < total) {

            toastShort('The current friend‘s card balance is insufficient');

            return;
          }

        }else {

          if (trans_limit < total) {
            toastShort('Current consumption limit of friend‘s card');
            return;
          }

        }
      }

   }else {

      // 信用卡。不考虑余额是否购

   }

   if (this.state.method_type == 1) {

      //获取朋友的支付密码
      this.getClientPayPd();

   }else {

    var temporary = this;

    nativeBridge.showPinView(this.state.userBean.pay_password,(error, result) => {
        
        if (result) {

          var userBean = this.state.userBean;


          if (userBean.pay_password == undefined || userBean.pay_password.length == 0) {

            // 进行保存
            temporary.saveTpd(result);

          }else {

            if (temporary.state.method_type == 0 || temporary.state.method_type == 1) {


                temporary.setState({
                  point_present_multiple:0,
                });

                //
                 Loading.show();
                temporary.getValidNewVouchers();

             }else {

                //信用卡支付积分相关，
                Loading.show();
                temporary.getClientVipLevel(total);

             }

          }  

        }
    });

   }





   // // 判断是否存在积分（只有信用卡支付才能获取积分）

   // if (this.state.method_type == 0 || this.state.method_type == 1) {


   //    this.setState({
   //      point_present_multiple:0,
   //    });

   //    //
   //     Loading.show();
   //    this.getValidNewVouchers();

   // }else {

   //    //信用卡支付积分相关，
   //    Loading.show();
   //    this.getClientVipLevel(total);

   // }

  }


  getClientPayPd(){

      var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
      '<v:Header />'+
      '<v:Body><n0:getClientPayPd id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<clientId i:type="d:string">'+ this.state.method_card_detail.card_owner_id +'</clientId>'+
      '</n0:getClientPayPd></v:Body></v:Envelope>';
      var temporary = this;
      Loading.show();

      WebserviceUtil.getQueryDataResponse('client','getClientPayPdResponse',data, function(json) {


         Loading.hidden();
        if (json && json.success == 1 && json.data ) {

          temporary.showFrinedPasswordPopup(json.data);
          
        }else {
        
          toastShort('The current user has not set a payment password. Please confirm and pay！');
        }

    });      


  }


  showFrinedPasswordPopup(friend_password){


    var temporary = this;

     nativeBridge.showPinView(friend_password,(error, result) => {
        
        if (result) {

           temporary.setState({
                point_present_multiple:0,
            });

           Loading.show();
          temporary.getValidNewVouchers();


        
        }
    });


  }





  saveTpd(pay_password){
      var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
      '<v:Header />'+
      '<v:Body><n0:saveTpd id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<pd i:type="d:string">'+ pay_password +'</pd>'+
      '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
      '</n0:saveTpd></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','saveTpdResponse',data, function(json) {


        if (json && json.success == 1 && json.data == 1 ) {

            var userBean = temporary.state.userBean;
            userBean.pay_password = pay_password;
            temporary.setState({
              userBean:userBean,
            });
           DeviceStorage.save('UserBean', userBean); 
          nativeBridge.setClientId(userBean.id.toString());

             // 判断是否存在积分（只有信用卡支付才能获取积分）
         if (temporary.state.method_type == 0 || temporary.state.method_type == 1) {

            temporary.setState({
              point_present_multiple:0,
            });

            //
            temporary.getValidNewVouchers();

         }else {

            //信用卡支付积分相关，
            temporary.getClientVipLevel(total);

         }

           
        }else {
          Loading.hidden();
          toastShort('Failed to save payment password. Please try again later！');
        }

    });      



  }



  getClientVipLevel(total){

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

            temporary.createInstance(total);
             
        }else {
          Loading.hidden();
          toastShort('Failed to obtain user points level！');
        }

    });      
    

  }

   createInstance(total){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:createInstance id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
     '<item><key i:type="d:string">orderId</key><value i:type="d:string">'+ this.state.order_id +'</value></item>'+
     '<item><key i:type="d:string">email</key><value i:type="d:string">'+ this.state.userBean.email +'</value></item>'+
     '<item><key i:type="d:string">invoice_no</key><value i:type="d:string">'+ this.state.order_detail.Order_Info.invoice_no +'</value></item>'+
     '<item><key i:type="d:string">totalAmount</key><value i:type="d:string">' +  total * 100 +'</value></item>'+
     '</data></n0:createInstance></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('stripe-payment','createInstanceResponse',data, function(json) {
    

        if (json && json.success == 1 && json.data ) {
          
            temporary.toPayActivity(json.data.clientSecret);
             
        }else {
          Loading.hidden();
          toastShort('Failed to generate credit card order number！');
        }

    });      

  }




  toPayActivity(clientSecret){

     Loading.hidden();

     var params = {};

     params.clientSecret = clientSecret;
     params.cvc = this.state.method_card_detail.method_lines[0].authorisation_code;
     params.number = this.state.method_card_detail.method_lines[0].card_number;
     var dates = this.state.method_card_detail.method_lines[0].expiry_date.split('-');
     params.expMonth = dates[1];
     params.expYear = dates[0];


     var str_params = JSON.stringify(params);

     //进行ios交互;
     nativeBridge.payment(str_params);

  }



  getValidNewVouchers(){


    var clientId = '';


    if (this.state.method_type == 0) {

        clientId = this.state.userBean.id;

    }else if (this.state.method_type == 1) {

        clientId = this.state.method_card_detail.card_owner_id;

    }



    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getValidNewVouchers id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">' + clientId + '</clientId>'+
    '</n0:getValidNewVouchers></v:Body></v:Envelope>';    
   
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getValidNewVouchersResponse',data, function(json) {

        if (json && json.success == 1 && json.data ) {
            
          
            temporary.payTOeder(json.data)


        }else {
          Loading.hidden();
          toastShort('Request was aborted');
        } 


    });
  }


payTOeder(valid_new_vouchers){


   var sub_total = parseFloat(this.state.order_detail.Order_Info.subtotal); // 订单总金额

   var coupon_total = 0; // 折扣总金额

   var vocher_total = 0; // 优惠券总金额

   var delivery_total = 0;  // 运费

   var total = 0;  // 支付总金额

   if (!this.state.selected_coupon) {
      // 没有使用折扣

      if (this.state.method_type == 0 || this.state.method_type == 1) { // 会员卡优惠

        coupon_total = sub_total*this.state.discount_percent / 100;

      }else {

        // 朋友的卡和信用卡不享受会员卡优惠


      }

   }else{
      // 用了折扣

      if (this.state.selected_coupon.value_type == '1') { // 当前的折扣属于的类型 百分比 和 具体金额

        //百分比折扣

        coupon_total = sub_total *parseFloat(this.state.selected_coupon.nominal_value) ;



      }else {

        // 具体金额
        coupon_total =  parseFloat(this.state.selected_coupon.nominal_value);

      }

   }



   //礼券 （礼券只有现金）
   if (this.state.selected_voucher) {

      vocher_total = parseFloat(this.state.selected_voucher.balance);

   }


   // 运费
   if (this.state.selected_location && this.state.selected_location.id == '-1') {


      delivery_total = parseFloat(this.state.delivery_fee);

   }


   // if (sub_total - coupon_total - vocher_total >= 150) {

   //    delivery_total = 0.00;

   // }



   //需要支付的总金额

   if (sub_total <= coupon_total + vocher_total) {

      total = delivery_total;

   }else {

      total = sub_total - coupon_total - vocher_total + delivery_total;

   }


   var pay_voucher_map = new Map();
   if ((this.state.method_type == 0 || this.state.method_type == 1) && valid_new_vouchers) {


      for (var i = 0; i < this.state.order_detail.Order_Line_Info.length; i++) {
        
          var line_info = this.state.order_detail.Order_Line_Info[i];

          var line_total = 0;


          if (!this.state.selected_coupon) {

              if (this.state.discount_percent) {

                line_total = parseFloat(line_info.total) * (1 - (parseFloat(this.state.discount_percent) / 100));

              }else {

                line_total = parseFloat(line_info.total);

              }
               // 减去 单个商品的折扣，按比例分配到每个订单上

              line_total = line_total - vocher_total * (parseFloat(line_info.total) / parseFloat(this.state.order_detail.Order_Info.subtotal)); 



          }else {


            var nominal_value = parseFloat(this.state.selected_coupon.nominal_value);


            if (this.state.selected_coupon.value_type == '1') {

              line_total = parseFloat(line_info.total) * (1 - nominal_value );

            }else {

              line_total =  parseFloat(line_info.total) -  nominal_value / this.state.order_detail.Order_Line_Info.length;
            }

             // 减去 单个商品的折扣，按比例分配到每个订单上

            line_total = line_total - vocher_total * (parseFloat(line_info.total) / parseFloat(this.state.order_detail.Order_Info.subtotal)); 

          }


          var payVoucher = '';


          if (line_total > 0) {


             var fee_total = delivery_total;


            for (var j = 0; j < valid_new_vouchers.length; j++) {
                var valid = valid_new_vouchers[j];
                var valid_balance = parseFloat(valid.balance);

              
                if (valid_balance == 0) {
                   continue;
                }


             

                if (line_total >= valid_balance) {
                  paid_amount = valid_balance;
                  line_total -= valid_balance;
                  valid_new_vouchers[i].balance = '0.00';
                }else {
                  paid_amount = line_total;
                  valid_new_vouchers[i].balance = (valid_balance - fee_total) + '';
                  line_total = 0;
                }

               payVoucher += (
                  '<item><key i:type="d:string">'+ j +'</key><value i:type="n1:Map">'+
                  '<item><key i:type="d:string">bought_voucher_id</key><value i:type="d:string">'+ valid.id +'</value></item>'+
                  '<item><key i:type="d:string">is_present</key><value i:type="d:string">0</value></item>'+
                  '<item><key i:type="d:string">create_date</key><value i:type="d:string">'+ DateUtil.formatDateTime()+'</value></item>'+
                  '<item><key i:type="d:string">voucher_type</key><value i:type="d:string">'+ valid.voucher_type +'</value></item>'+
                  '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">'+ paid_amount +'</value></item>'+
                  '</value></item>'
              ); 

              if (line_total == 0) {
                break;
              }
            }


          }

          pay_voucher_map.set(line_info.id,payVoucher);

      }
 
   }




   var Order_Lines = '<item><key i:type="d:string">Order_Lines</key><value i:type="n1:Map">';


   for (var i = 0; i <  this.state.order_detail.Order_Line_Info.length; i++) {

      var line_info = this.state.order_detail.Order_Line_Info[i];


      var reward_discount = 0;
      var pay_by_voucher = 0;
      var new_recharge_discount = 0;


      if (this.state.method_type == 0 || this.state.method_type == 1) {


          if (this.state.selected_coupon) {

            var nominal_value = parseFloat(this.state.selected_coupon.nominal_value);


            if (this.state.selected_coupon.value_type == '1') {

                reward_discount = parseFloat(line_info.total)*nominal_value;


            }else {

              reward_discount = nominal_value * (parseFloat(line_info.total) / parseFloat(this.state.order_detail.Order_Info.subtotal));

            }


             pay_by_voucher = parseFloat(line_info.total) - reward_discount;



          }else {


            if (this.state.discount_percent) {


              new_recharge_discount = parseFloat(line_info.total) * (parseFloat(this.state.discount_percent) / 100);

              pay_by_voucher = parseFloat(line_info.total) - new_recharge_discount;

              reward_discount = 0;

            }else {

              pay_by_voucher = parseFloat(line_info.total);

            }


          }


      }else {


        if (this.state.selected_coupon) {

           var nominal_value = parseFloat(this.state.selected_coupon.nominal_value);


           if (this.state.selected_coupon.value_type == '1') {

                reward_discount = parseFloat(line_info.total)*nominal_value;


            }else {

              reward_discount = nominal_value * (parseFloat(line_info.total) / parseFloat(this.state.order_detail.Order_Info.subtotal));

            }

        }
          
      }


      var pay_by_gift = vocher_total * (parseFloat(line_info.total) / parseFloat(this.state.order_detail.Order_Info.subtotal))


      Order_Lines +=   
          ('<item><key i:type="d:string">'+ i +'</key><value i:type="n1:Map">'+
          '<item><key i:type="d:string">data</key><value i:type="n1:Map">'+
          '<item><key i:type="d:string">pay_by_voucher</key><value i:type="d:string">'+ pay_by_voucher +'</value></item>'+
          '<item><key i:type="d:string">has_paid</key><value i:type="d:string">1</value></item>'+
          '<item><key i:type="d:string">id</key><value i:type="d:string">'+ line_info.id +'</value></item>'+
          '<item><key i:type="d:string">pay_by_service</key><value i:type="d:string">0</value></item>'+
          '<item><key i:type="d:string">pay_by_gift</key><value i:type="d:string">'+ pay_by_gift +'</value></item>'+
          '<item><key i:type="d:string">reward_discount</key><value i:type="d:string">'+ reward_discount +'</value></item>'+
          '<item><key i:type="d:string">delivery_time</key><value i:type="d:string"></value></item>'+
          '<item><key i:type="d:string">salesmen_id</key><value i:type="d:string">'+ this.state.business_id +'</value></item>'+
          '<item><key i:type="d:string">has_delivered</key><value i:type="d:string">0</value></item>'+
          '<item><key i:type="d:string">new_recharge_discount</key><value i:type="d:string">'+ new_recharge_discount +'</value></item>'+
          '<item><key i:type="d:string">delivery_location_id</key><value i:type="d:string">'+(this.state.selected_location.id == '-1' ? this.state.head_company_id: this.state.selected_location.id)+'</value></item>'+
          '<item><key i:type="d:string">pay_by_balance</key><value i:type="d:string">0</value></item>'+
          '<item><key i:type="d:string">collection_method</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? '2':'1') +'</value></item>'+
          '</value></item>'+
          '<item><key i:type="d:string">Pay_Voucher</key><value i:type="n1:Map">' + 

          pay_voucher_map.get(line_info.id) +

          '</value></item></value></item>');    



     
   }

   Order_Lines += ('</value></item>');





   // 会员卡支付运费
   var payFreightVoucher = '';


   if ((this.state.method_type == 0 || this.state.method_type == 1) && delivery_total > 0 ) {


    var fee_total = delivery_total;

    var poistion = 0;

    payFreightVoucher += '<item><key i:type="d:string">payFreightVoucher</key><value i:type="n1:Map">'


    for (var i = 0; i < valid_new_vouchers.length; i++) {
      
        var valid = valid_new_vouchers[i];


        var valid_balance = parseFloat(valid.balance);

        if (valid_balance == 0) {

            continue;
        }


        var paid_amount = 0;

        if (fee_total >= valid_balance) {
          paid_amount = valid_balance;
          fee_total -= valid_balance;
          valid_new_vouchers[i].balance = '0.00';
        }else {
          paid_amount = fee_total;
          valid_new_vouchers[i].balance = (valid_balance - fee_total) + '';
          fee_total = 0;
        }

       payFreightVoucher += (
          '<item><key i:type="d:string">'+ i +'</key><value i:type="n1:Map">'+
          '<item><key i:type="d:string">bought_voucher_id</key><value i:type="d:string">'+ valid.id +'</value></item>'+
          '<item><key i:type="d:string">is_present</key><value i:type="d:string">0</value></item>'+
          '<item><key i:type="d:string">create_date</key><value i:type="d:string">'+ DateUtil.formatDateTime()+'</value></item>'+
          '<item><key i:type="d:string">voucher_type</key><value i:type="d:string">'+ valid.voucher_type +'</value></item>'+
          '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">'+ paid_amount +'</value></item>'+
          '</value></item>'
      ); 

      if (fee_total == 0) {
        break;
      }


    }


    payFreightVoucher +=  '</value></item>';

   }

   //信用卡支付运费

   var payFreight = '';


   if (this.state.method_type == 2 && this.state.selected_location.id == '-1') {

      payFreight = '<item><key i:type="d:string">payFreight</key><value i:type="n1:Map">' + 
        '<item><key i:type="d:string">real_paid_amount</key><value i:type="d:string">'+ delivery_total +'</value></item>' +
        '<item><key i:type="d:string">pay_method_card_id</key><value i:type="d:string">'+ this.state.method_card_detail.id +'</value></item>' +
        '<item><key i:type="d:string">pay_method_line_id</key><value i:type="d:string">'+ this.state.method_card_detail.method_lines[0].id +'</value></item>' +
        '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">'+ delivery_total +'</value></item>' +
        '</value></item>';
   }



   var payMethods = '';

   if (this.state.method_type == 2) {

     payMethods = '<item><key i:type="d:string">payMethods</key><value i:type="n1:Map">'+
        '<item><key i:type="d:string">0</key><value i:type="n1:Map">' +
        '<item><key i:type="d:string">real_paid_amount</key><value i:type="d:string">'+ (total - delivery_total) +'</value></item>' +
        '<item><key i:type="d:string">pay_method_card_id</key><value i:type="d:string">'+ this.state.method_card_detail.id +'</value></item>' +
        '<item><key i:type="d:string">pay_method_line_id</key><value i:type="d:string">'+ this.state.method_card_detail.method_lines[0].id +'</value></item>' +
        '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">'+ (total - delivery_total) +'</value></item>' +
       '</value></item></value></item>';



   }else {

    payMethods = '<item><key i:type="d:string">payMethods</key><value i:type="n1:Map" /></item>';

   }





   // 积分计算
   
   //原始积分为支付金额，不包含运费
   var present_points = total - delivery_total;

   //生日当天积分翻倍
    if (this.state.new_time && DateUtil.parserDateString(this.state.new_time) == DateUtil.parserDateString(this.state.userBean.birthday + ' 00:00:00')) {
      present_points *= 2;
    }

    present_points *= (parseInt(this.state.point_present_multiple));




   var reward_and_gift = '';


   if (this.state.selected_coupon != undefined) {

      reward_and_gift +=   ('<item><key i:type="d:string">reward_id</key><value i:type="d:string">'+ this.state.selected_coupon.id +'</value></item>');
      reward_and_gift +=   ('<item><key i:type="d:string">reward_amout</key><value i:type="d:string">'+ coupon_total +'</value></item>');

   }


   if (this.state.selected_voucher != undefined) {

      reward_and_gift +=   ('<item><key i:type="d:string">gift_id</key><value i:type="d:string">'+ this.state.selected_voucher.id +'</value></item>');
      reward_and_gift +=   ('<item><key i:type="d:string">gift_amount</key><value i:type="d:string">'+ vocher_total +'</value></item>');


   }






    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:payTOrder id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    payMethods + 
    Order_Lines + 
    payFreightVoucher + 
    '<item><key i:type="d:string">Order_Info</key><value i:type="n1:Map">'+
    reward_and_gift + 
    '<item><key i:type="d:string">building_block_num</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? this.state.building_block_num : '') + '</value></item>'+
    '<item><key i:type="d:string">balance</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">total_recharge_discount</key><value i:type="d:string">'+ (this.state.selected_coupon == undefined && (this.state.method_type == 0 || this.state.method_type == 1) ? StringUtils.toDecimal(coupon_total) : '0.00') +'</value></item>'+
    '<item><key i:type="d:string">pay_by_gift</key><value i:type="d:string">'+ StringUtils.toDecimal(vocher_total) +'</value></item>' +
    '<item><key i:type="d:string">close_time</key><value i:type="d:string">' + DateUtil.formatDateTime() + '</value></item>'+
    '<item><key i:type="d:string">invoice_date</key><value i:type="d:string">'+ DateUtil.formatDateTime1() +'</value></item>'+
    '<item><key i:type="d:string">address</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? this.state.street_name + ' ' + this.state.building_block_num + ' ' + (this.state.unit_num ? this.state.unit_num + ' ' : '')  + (this.state.city ? this.state.city + ' ' : '')  + this.state.post_code : '') +'</value></item>'+
    '<item><key i:type="d:string">gift_voucher_amount</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">freight</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? StringUtils.toDecimal(delivery_total) : '0') +'</value></item>'+
    '<item><key i:type="d:string">new_gift_voucher_amount</key><value i:type="d:string">'+ ((this.state.method_type == 0 || this.state.method_type == 1) ? StringUtils.toDecimal(total):'0')  +'</value></item>'+
    '<item><key i:type="d:string">change</key><value i:type="d:string">0</value></item>' + 
    '<item><key i:type="d:string">street_name</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? this.state.street_name : '')  +'</value></item>'+
    '<item><key i:type="d:string">present_points</key><value i:type="d:string">'+ present_points + '</value></item>'+
    '<item><key i:type="d:string">origin_paid_amount</key><value i:type="d:string">'+  ((this.state.method_type == 0 || this.state.method_type == 1) ? '0' :StringUtils.toDecimal(total))  +'</value></item>'+
    '<item><key i:type="d:string">id</key><value i:type="d:int">'+ this.state.order_detail.Order_Info.id +'</value></item>'+
    '<item><key i:type="d:string">status</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">pay_by_service</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">pay_by_balance</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">city</key><value i:type="d:string">' + (this.state.selected_location.id == '-1' ? (this.state.city ? this.state.city : '') : '') + '</value></item>'+
    '<item><key i:type="d:string">remark</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">due_date</key><value i:type="d:string">'+  DateUtil.formatDateTime1()  +'</value></item>'+
    '<item><key i:type="d:string">unit_num</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? (this.state.unit_num != undefined ? this.state.unit_num : '') : '') +'</value></item>'+
    '<item><key i:type="d:string">post_code</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? this.state.post_code : '') +'</value></item>'+
    '<item><key i:type="d:string">paid_amount</key><value i:type="d:string">' + (this.state.method_type == 2 ? StringUtils.toDecimal(total) : '0') + '</value></item>'+
    '<item><key i:type="d:string">voucher_amount</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">saleman_id</key><value i:type="d:string">'+ this.state.business_id +'</value></item>'+
    '<item><key i:type="d:string">date</key><value i:type="d:string">'+ DateUtil.formatDateTime1() +'</value></item>'+
    '<item><key i:type="d:string">is_from_app</key><value i:type="d:string">1</value></item>'+
    '<item><key i:type="d:string">collection_method</key><value i:type="d:string">'+ (this.state.selected_location.id == '-1' ? '2' : '1') +'</value></item>'+
    '</value></item>' +
    '<item><key i:type="d:string">bookingTimesData</key><value i:type="n1:Map" /></item>'+
    '</data>'+
    '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
    '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
    '</logData>'+
    '</n0:payTOrder></v:Body></v:Envelope>';    
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('sale','payTOrderResponse',data, function(json) {

        // console.error(json);
        Loading.hidden();
        if (json && json.success == 1) {
          // if (temporary.props.navigation) {
          //   temporary.props.navigation.goBack(); 
          // }else {
          //   NativeModules.NativeBridge.goBack();
          // }
          temporary.toShopOrderSummaryActivity();

            
          toastShort('Recharge Success');        
        }else {
  
          toastShort('Order modification failed！');

        } 


    });

}

toShopOrderSummaryActivity(){
NativeModules.NativeBridge.setClientId(this.state.userBean.id.toString());
  if (this.props.isNative) {
    NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'ShopOrderSummaryActivity',property:{
      'order_id':this.state.order_id,
    }});
  }else {
    const { navigation } = this.props;
    if (navigation) {
       navigation.replace('ShopOrderSummaryActivity',{
        'order_id':this.state.order_id,
      });
  
    }
  } 

}



render() {


    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

        <SafeAreaView style = {styles.afearea} >


            <TitleBar
              title = {'Check Out'} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>



            <View style = {[styles.bg]}>

            <ScrollView style = {styles.scrollview}
                contentOffset={{x: 0, y: 0}}>



                <View style = {{width:'100%',padding:16,backgroundColor:'#FAF3EB'}}>


                     <Text style = {[styles.text_title]}>Items</Text>

                </View>


                {this._items()}

                {this._footer()}


                {this._total()}


           </ScrollView>  


        
            <View style = {styles.next_view}>

                <TouchableOpacity style = {[styles.next_layout]}  
                    activeOpacity = {0.8 }
                    onPress={this.clickPlace.bind(this)}>


                       <Text style = {styles.next_text}>Place Order</Text>

                </TouchableOpacity>

            </View>

   
          </View>   


        </SafeAreaView>


        <SafeAreaView style = {styles.afearea_foot} />

        <CoverLayer ref={ref => this.coverLayer = ref}/>


      </View>

    );


  }

}


const styles = StyleSheet.create({

  bg: {
    flex:1,
    backgroundColor:'#FFFFFF',
  },
  afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
   next_layout:{
      width:'100%',
      height:44,
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center',
       backgroundColor:'#C44729'
  },
  next_text :{
      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',
  },
  next_view:{
    padding:16,
  },
  view_coupon:{
    width:'100%',
    padding:16,
    flexDirection: 'row',
    alignItems: 'center',
  },
  text_title:{
    fontSize: 18,
    color: '#145A7C',
    fontWeight: 'bold',
  },
  text_title_1:{
    marginLeft:5,
    fontSize: 16,
    color: '#333333',
  },
  text_selsected_value:{
    flex:1,
    fontSize: 16,
    color: '#828282',
    textAlign:'right'
  },
  view_line : {
    backgroundColor:'#E0e0e0',
    width:'100%',
    height:1,
  },
   view_iparinput:{
     paddingTop:16,
     paddingLeft:16,
     paddingRight:16,
  },
  view_image_card:{
    backgroundColor:'#FFFFFF',
    borderRadius:16,
    width:85,
    height:60,
  },
  text_view_num:{
    marginTop:8,
    marginLeft:16,
    fontSize:14,
    color:'#333333',
  },
  text_view_name:{
    marginTop:8,
    flex:1,
    marginLeft:8,
    fontSize:14,
    color:'#333333',
    fontWeight: 'bold',
  },
  text_view_price:{
    marginTop:8,
    marginLeft:8,
    fontSize:14,
    color:'#333333',
  },
   text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
   flat_popup:{
    marginTop:24,
    width:'100%'
  },
  text_popup_content:{
    width:'100%',
    marginTop:16,
    marginBottom:16,
    fontSize:16,
    color:'#333333'
  },
   text_item_title:{
    fontSize: 16,
    fontWeight: 'bold',
  },
  view_item:{
    padding:12,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_total_item:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  text_total_title:{
    fontSize:14,
    color:'#333333'
  }
});