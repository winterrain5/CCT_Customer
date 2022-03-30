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
  Linking
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

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

let {width, height} = Dimensions.get('window');


export default class BookCompletedDetailsActivity extends Component {

   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       service:undefined,
       transactions_detail:undefined,
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

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });
    });

    if (this.props.route.params) {

      this.setState({
        service:this.props.route.params.service,
      });


      this.getHistoryOrderDetails(this.props.route.params.service.id);

    }


  }


  getHistoryOrderDetails(order_id){


    if (order_id == undefined) {
      return;
    }


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getHistoryOrderDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<orderId i:type="d:string">'+ order_id +'</orderId>'+
    '</n0:getHistoryOrderDetails></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('sale','getHistoryOrderDetailsResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1 && json.data ) {
          
            temporary.setState({
               transactions_detail:json.data,   
            });
        }

    });

  }




serviceType(){

  return (

     <View style = {styles.view_service_type}>

         <View style = {styles.view_service_type}>


            <View style = {[styles.view_service_type_item,{backgroundColor:'#828282'}]}>

                 <Text style = {styles.text_service_type}>Completed</Text>

            </View>
     
        </View>
                   
     
      </View>


    );


}


cardTimeLocation(){


    return (

       <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >


        <View style = {styles.view_card_item}>


           <View style = {[styles.view_item_item,{marginTop:0}]}>

              <Image style = {styles.image_item} 
                  resizeMode = 'contain' 
                  source={require('../../../../images/time.png')}/>


              <Text style = {styles.text_item_content2}>{DateUtil.getShowTimeFromDate2(this.state.service.therapy_start_date)  + ' - ' + DateUtil.getShowHMTime2(this.state.service.therapy_start_date)}</Text>

          </View>


           <View style = {styles.view_item_item}>

              <Image style = {styles.image_item} 
                  resizeMode = 'contain' 
                  source={require('../../../../images/location.png')}/>


              <Text style = {styles.text_item_content2}>{this.state.service.location_name}</Text>

          </View> 

        </View>

       </Card>

      );

}


paymentView(){

  return (

    <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >


      <View style = {styles.view_card_item}>


            <Text style = {styles.text_popup_title}>Payment</Text>


            <View style = {{width:'100%',marginTop:8}}>


              {this.paymentServiceView()}


              <View style = {styles.view_line}  />


              {this.paymentSubTotalView()}


              {this.paymentTotalView()}


              {this.paymentPointsView()}


               <View style = {styles.view_line}  />


              <Text style = {[styles.text_popup_title,{marginTop:16}]}>Payment Method</Text>



               {this.paymentMethodView()}



            </View>



      </View>

    </Card>

  );

}

paymentMethodView(){


  var pay_method = [];

  if (this.state.transactions_detail && this.state.transactions_detail.PayVoucher_Info) {


    for (var i = 0; i < this.state.transactions_detail.PayVoucher_Info.length; i++) {

      var pay_voucher =  this.state.transactions_detail.PayVoucher_Info[i];

      pay_method.push(


        <View style = {styles.view_lines}>


          <Text style = {styles.text_line}>{pay_voucher.name}</Text>


          <Text style = {[styles.text_line,{marginLeft:8}]}>${StringUtils.toDecimal(pay_voucher.paid_amount)}</Text>


        </View>

      );

    }

  }

  if (this.state.transactions_detail && this.state.transactions_detail.PayGift_Info) {


    for (var i = 0; i < this.state.transactions_detail.PayGift_Info.length; i++) {

      var pay_gift =  this.state.transactions_detail.PayGift_Info[i];

      pay_method.push(


        <View style = {styles.view_lines}>


          <Text style = {styles.text_line}>{pay_gift.name}</Text>


          <Text style = {[styles.text_line,{marginLeft:8}]}>${StringUtils.toDecimal(pay_gift.paid_amount)}</Text>


        </View>

      );

    }

  }


  if (this.state.transactions_detail && this.state.transactions_detail.Paymethod_Info) {


    for (var i = 0; i < this.state.transactions_detail.Paymethod_Info.length; i++) {

      var pay =  this.state.transactions_detail.Paymethod_Info[i];

      pay_method.push(


        <View style = {styles.view_lines}>


          <Text style = {styles.text_line}>{pay.name}</Text>


          <Text style = {[styles.text_line,{marginLeft:8}]}>${StringUtils.toDecimal(pay.paid_amount)}</Text>


        </View>

      );

    }

  }




  return pay_method;



}




paymentPointsView(){


  var points = 0;

  if (this.state.transactions_detail && this.state.transactions_detail.Order_Info) {


    try{

     points =  parseInt(this.state.transactions_detail.Order_Info.present_points);

    }catch(e){

    }

  }



  return (

    <View style = {styles.view_lines}>


      <View />


      <Text style = {[styles.text_payment_title,{marginLeft:8,color:'#828282'}]}>(Points earned {points})</Text>


    </View>

  );

}



paymentTotalView(){


  var gst = 0.00;
 
  if (this.state.transactions_detail && this.state.transactions_detail.Order_Line_Info) {


    for (var i = 0; i < this.state.transactions_detail.Order_Line_Info.length; i++) {

      var line =   this.state.transactions_detail.Order_Line_Info[i];

      var paid_amount = 0.00;
      var rate = 0.00;

      try{
        paid_amount = parseFloat(line.paid_amount);
      }catch(e){

      }

      try{
        rate = parseFloat(line.rate);
      }catch(e){

      }

      gst += paid_amount / (1 + (rate / 100)) * (rate / 100);


    } 

  }

  var title = 'TOTAL';


  if (gst > 0) {

    title = 'TOTAL(Inclusive of GST $' + StringUtils.toDecimal(gst) + ')';
  }



  return (

    <View style = {styles.view_lines}>


      <Text style = {[styles.text_payment_title,{color:'#145A7C',fontSize:14}]}>{title}</Text>


      <Text style = {[styles.text_line,{marginLeft:8,color:'#145A7C'}]}>${this.state.transactions_detail ? StringUtils.toDecimal(this.state.transactions_detail.Order_Info.subtotal) : '0.00'}</Text>


    </View>

  );


}






paymentSubTotalView(){


  return (

    <View style = {styles.view_lines}>


      <Text style = {styles.text_payment_title}>Sub Total</Text>


      <Text style = {[styles.text_line,{marginLeft:8}]}>${this.state.transactions_detail ? StringUtils.toDecimal(this.state.transactions_detail.Order_Info.subtotal) : '0.00'}</Text>


    </View>

  );


}





paymentServiceView(){


  var order_lines = [];

  if (this.state.transactions_detail && this.state.transactions_detail.Order_Line_Info) {


    for (var i = 0; i < this.state.transactions_detail.Order_Line_Info.length; i++) {

      var line =  this.state.transactions_detail.Order_Line_Info[i];

      order_lines.push(


        <View style = {styles.view_lines}>


          <Text style = {[styles.text_line,{flex:1 }]}>{line.name}</Text>


          <Text style = {[styles.text_line,{marginLeft:8}]}>${StringUtils.toDecimal(line.total)}</Text>


        </View>

      );

    }

  }


  return order_lines;


}  





 render() {

  const { navigation } = this.props;

  return(

    <View style = {styles.bg}>

      <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


      <SafeAreaView style = {styles.afearea} >

        <TitleBar
          title = {''} 
          navigation={navigation}
          hideLeftArrow = {true}
          hideRightArrow = {false}
          extraData={this.state}/>


        <View style = {styles.view_content}>


          <ScrollView style = {styles.scrollview}
              contentOffset={{x: 0, y: 0}}>


              {this.serviceType()}  


              {this.cardTimeLocation()}


              {this.paymentView()}


          </ScrollView>    


        

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
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  text_title : {
    marginTop:8,
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_service_type:{
    width:'100%',
    marginTop:8,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_service_type_item:{
    paddingLeft:5,
    paddingRight:5,
    borderRadius:50,
    backgroundColor:'#EE8F7B',
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_service_type:{
    padding:5,
    fontSize:12,
    fontWeight:'bold',
    color:'#FFFFFF',
    fontWeight:'bold',
  },
  text_service_title:{
    marginTop:4,
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C',
    textAlign :'center',
  },
  view_card_item:{
    width:'100%',
    padding:16,
  },
  text_item_title:{
    color:'#145A7C',
    fontSize:14,
    fontWeight:'bold',
  },
  text_item_content:{
    marginTop:8,
    color:'#333333',
    fontSize:14,
  },
  view_item_item:{
    marginTop:8,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  image_item:{
    width:15,
    height:15
  },
  text_item_content2:{
    marginLeft:6,
    flex:1,
    color:'#333',
    fontSize:14,
  },
  condition_item : {
    width:'100%',
    flexDirection: 'row',
  },
  text_condition_title:{
    flex:1,
    fontSize:13,
    color:'#333333'
  },
  text_condition_content:{
    width:'100%',
    fontSize:13,
    color:'#333333'
  },
  text_cancel_booking:{
    marginTop:61,
    width:'100%',
    color:'#C44729',
    fontSize:14,
    fontWeight:'bold',
    textAlign :'center',
  },
   next_layout:{
      width:'100%',
      height:44,
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
    marginTop:16
  },
  view_phone_wechat:{
    flex:1,
    flexDirection: 'row',
  },
  text_phone_wechat:{
    marginLeft:5,
    fontSize: 16,
    color: '#145A7C',
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
  text_popup_content:{
    marginBottom:50,
    width:'100%',
    marginTop:32,
    fontSize:16,
    color:'#333333',
    textAlign :'center',
  },
  xpop_cancel_confim:{
    marginTop:32,
    marginBottom:50,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_item:{
    borderRadius: 50,
    height:44,
   
    justifyContent: 'center',
    alignItems: 'center',
  },
  xpop_text: {
    fontSize:14,
    textAlign :'center',
    fontWeight: 'bold',
  },
  xpop_touch:{
     width:'48%',

  },
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    fontWeight: 'bold',
  },
  text_popup_content : {
    marginTop:24,
    width:'100%',
    color:'#333333',
    fontSize:14,
  },
  view_lines:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_line:{
    color:'#333333',
    fontSize:12,
    fontWeight: 'bold', 
  },
  view_line:{
    marginTop:16,
    width:'100%',
    backgroundColor:'#e0e0e0',
    height:1,

  },
  text_payment_title:{
    color:'#333333',
    fontSize:12,

  }
});







