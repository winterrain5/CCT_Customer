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
  Dimensions
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


export default class TransactionsDetailActivity extends Component {

    constructor(props) {
      super(props);
      this.state = {
         head_company_id:'97',
         userBean:undefined,
         order_id:undefined,
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
        order_id:this.props.route.params.order_id,
      });

      this.getHistoryOrderDetails(this.props.route.params.order_id);

    }

  }


  getHistoryOrderDetails(order_id){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getHistoryOrderDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<orderId i:type="d:string">'+ order_id +'</orderId>'+
    '</n0:getHistoryOrderDetails></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sale','getHistoryOrderDetailsResponse',data, function(json) {

    
        if (json && json.success == 1 && json.data ) {
          
            temporary.setState({
               transactions_detail:json.data,   
            });
        }

    });

  }


  _order_lines(){


    if (this.state.transactions_detail && this.state.transactions_detail.Order_Line_Info && this.state.transactions_detail.Order_Line_Info.length > 0) {


        var lines = [];

        for (var i = 0; i < this.state.transactions_detail.Order_Line_Info.length; i++) {
              var line_info = this.state.transactions_detail.Order_Line_Info[i];


              lines.push(

                  <View style = {{width:'100%',paddingTop:21}}>

                     <View style = {styles.view_name_volue}>

                        <Text style = {styles.text_item_name}>{line_info.name}</Text>

                         <Text style = {styles.text_item_name}>{'$' + StringUtils.toDecimal(line_info.total)}</Text>

                     </View> 



                     {this._order_lines_discount(line_info)}


                    <View style = {styles.view_line}/>





                  </View>


                );

        }



        return lines;





    }else {

      return (<View />);

    }


  }


  _order_lines_discount(line_info){

    var discount = parseFloat(line_info.discount_amount1) + parseFloat(line_info.discount_amount2);


    if (discount > 0) {


      return (

         <View style = {[styles.view_name_volue,{marginTop:12}]}>

            <Text style = {[styles.text_item_name,{fontWeight:'normal'}]}>Discount</Text>

             <Text style = {[styles.text_item_name,{fontWeight:'normal'}]}>{'-$' + StringUtils.toDecimal(discount)}</Text>

         </View>  );


    }else {


      return (<View/>);


    }



  }


  _order_discount(){


    if (this.state.transactions_detail) {

     
      var discount = 0 ;

      for (var i = 0; i < this.state.transactions_detail.Order_Line_Info.length; i++) {

        var order_line =  this.state.transactions_detail.Order_Line_Info[i];


        discount += (parseFloat(order_line.new_recharge_discount)  + parseFloat(order_line.reward_discount));



      }


      if (discount > 0) {


        return (

           <View style = {[styles.view_name_volue,{marginTop:12}]}>

              <Text style = {[styles.text_item_name,{fontWeight:'normal'}]}>Discount</Text>

               <Text style = {[styles.text_item_name,{fontWeight:'normal'}]}>{'-$' + StringUtils.toDecimal(discount)}</Text>

           </View>  

        );


      }else {


        return (<View/>);


      }





    }else {

       return (<View/>);

    }


  }



  _local_delivery(){

    if (this.state.transactions_detail) {

     
      var freight = 0;

      freight = parseFloat(this.state.transactions_detail.Order_Info.freight);


      if (freight > 0) {


        return (

           <View style = {[styles.view_name_volue,{marginTop:12}]}>

              <Text style = {[styles.text_item_name,{fontWeight:'normal'}]}>Local Delivery</Text>

               <Text style = {[styles.text_item_name]}>{ '$' + StringUtils.toDecimal(freight)}</Text>

           </View>  

        );


      }else {


        return (<View/>);


      }

    }else {

       return (<View/>);

    }

  }


  _total_view(){


    var total = 0.00;
    var gst = 0;


    if (this.state.transactions_detail) {

      total = parseFloat(this.state.transactions_detail.Order_Info.total) + parseFloat(this.state.transactions_detail.Order_Info.freight);



      for (var i = 0; i < this.state.transactions_detail.Order_Line_Info.length; i++) {

         var order_line =  this.state.transactions_detail.Order_Line_Info[i];

         gst += (parseFloat(order_line.paid_amount) / (1 + parseFloat(order_line.rate) / 100) * (parseFloat(order_line.rate) / 100));

      }



    }


    return(


      <View style = {{width:'100%'}}>

           <View style = {[styles.view_name_volue,{marginTop:16}]}>

             <Text style = {[styles.text_item_total]}>{gst > 0 ? 'TOTAL(Inclusive of GST $' + StringUtils.toDecimal(gst) + ')' : 'TOTAL'}</Text>

             <Text style = {[styles.text_item_total,{fontSize:24}]}>{'$' + StringUtils.toDecimal(total)}</Text>

          </View>

           <View style = {[styles.view_name_volue,{marginTop:16}]}>

             <Text />

             <Text style = {[styles.text_points]}>{'(Points earned ' + (this.state.transactions_detail ? parseInt(this.state.transactions_detail.Order_Info.present_points) : '0')  + ')'}</Text>

          </View>




      </View>

    

    );


  }


  _payment_method(){


    var methods = [];


    if (this.state.transactions_detail ) {



      if (this.state.transactions_detail.PayVoucher_Info && this.state.transactions_detail.PayVoucher_Info.length > 0) {


        var map = new Map();


        for (var i = 0; i < this.state.transactions_detail.PayVoucher_Info.length; i++) {

           var pay_voucher =  this.state.transactions_detail.PayVoucher_Info[i];

           if (map.get(pay_voucher.name) != undefined) {

              var old_pay_voucher = map.get(pay_voucher.name);

              var new_paid_amount = (parseFloat(pay_voucher.paid_amount) + parseFloat(old_pay_voucher.paid_amount)) + '';

              pay_voucher.paid_amount = new_paid_amount;

              map.set(pay_voucher.name,pay_voucher);

           }else {

              map.set(pay_voucher.name,pay_voucher);

           }
        }


        for(let item of map.values()){

           methods.push(

            <View style = {styles.view_method}>


               <Image style = {{width:20,height:18}} 
                  source={require('../../../../images/qianbao_526.png')}/>  


               <Text style = {styles.text_method} >{item.name + ' - $' + StringUtils.toDecimal(item.paid_amount)}</Text>      



            </View>

            );
        }

      }



      if (this.state.transactions_detail.PayGift_Info && this.state.transactions_detail.PayGift_Info.length > 0) {

        for (var i = 0; i < this.state.transactions_detail.PayGift_Info.length; i++) {

          var gift =  this.state.transactions_detail.PayGift_Info[i];


           methods.push(

            <View style = {styles.view_method}>


               <Image style = {{width:20,height:18}} 
                  source={require('../../../../images/qianbao_526.png')}/>  


               <Text style = {styles.text_method} >{gift.name + ' - $' + StringUtils.toDecimal(gift.paid_amount)}</Text>      



            </View>

            );

        }
      }

      if (this.state.transactions_detail.Paymethod_Info && this.state.transactions_detail.Paymethod_Info.length > 0) {

        for (var i = 0; i < this.state.transactions_detail.Paymethod_Info.length; i++) {

          var paymethod =  this.state.transactions_detail.Paymethod_Info[i];


           methods.push(

            <View style = {styles.view_method}>


               <Image style = {{width:20,height:18}} 
                  source={require('../../../../images/qianbao_526.png')}/>  


               <Text style = {styles.text_method}>{paymethod.name + ' - $' + StringUtils.toDecimal(paymethod.paid_amount)}</Text>      

            </View>

            );

        }
      }



      return methods;



    } else {

      return (<View />);


    }


  }







  render() {


    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {styles.afearea} >

              <TitleBar
                title = {'My Wallet'} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>

              <View style = {styles.view_content}>  

                  <ScrollView 
                      style = {styles.scrollview}
                      showsVerticalScrollIndicator = {false}
                      contentOffset={{x: 0, y: 0}}
                      onScroll={this.changeScroll}>


                      <Text style = {styles.text_number}>{this.state.transactions_detail ? '#' + this.state.transactions_detail.Order_Info.number : ''}</Text>


                      <Text style = {styles.text_date}>{this.state.transactions_detail ? DateUtil.getShowTimeFromDate3(this.state.transactions_detail.Order_Info.date) : ''}</Text>


                      {this._order_lines()}


                       <View style = {[styles.view_name_volue,{marginTop:12}]}>

                          <Text style = {[styles.text_item_name,{fontWeight:'normal'}]}>Sub Total</Text>

                           <Text style = {[styles.text_item_name]}>{this.state.transactions_detail ? '$' + StringUtils.toDecimal(this.state.transactions_detail.Order_Info.subtotal) : ''}</Text>

                       </View> 


                       {this._order_discount()}


                       {this._local_delivery()}


                       <View style = {styles.view_line}/>


                       {this._total_view()}


                      <View style = {styles.view_line}/>


                      <Text style = {[styles.text_number,{fontSize:18,marginTop:16}]}>Payment Method</Text>


                      {this._payment_method()}
 




                  </ScrollView>    


              
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
   scrollview:{
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_user_card:{
    borderRadius:16,
    width:'100%',
    height:184,
  },
  view_user_info:{
    width:'100%',
    height:'100%',
    position:'absolute',
  },
  view_leve:{
    padding:16,
    width:'100%',
    flexDirection: 'row',
    alignItems: 'center'
  },
  view_name_leve:{
    flex:1,
  },
  text_leve:{
    fontSize:18,
    fontWeight:'bold',
    color:'#333',
  },
  image_edit:{
    marginLeft:3,
    width:24,
    height:24,
    paddingBottom:3,
    paddingRight:1,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_user_info:{
    marginTop:24,
    marginLeft:24,
    padding:24,
    width:'100%',
    height:'100%',
    position:'absolute',
   
  },
  view_name_volue:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_hint:{
    marginTop:8,
    flex:1,
    fontSize:12,
    color:'#828282'
  },
  view_points:{
    paddingLeft:24,
    paddingRight:24,
    width:'100%',
  },
  text_points:{
    fontSize:14,
    color:'#828282'
  },
  text_number:{
    fontSize:24,
    color:'#145A7C',
    fontWeight:'bold',
  },
  text_date:{
    fontSize:16,
    color:'#333333',
  },
  text_item_name:{
    fontSize:14,
    color:'#000000',
    fontWeight:'bold',
  },
  view_line:{
    marginTop:16,
    width:'100%',
    height:1,
    backgroundColor:'#F2F2F2',
  },
  text_item_total:{
    fontSize:14,
    color:'#145A7C',
    fontWeight:'bold',
  },
  view_method:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  text_method:{
    paddingLeft:8,
    fontSize:16,
    color:'#333333',
  }

});


