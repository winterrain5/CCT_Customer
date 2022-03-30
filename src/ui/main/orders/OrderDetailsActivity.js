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

import {Card} from 'react-native-shadow-cards';


export default class OrderDetailsActivity extends Component {



  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       seleted_type:0,
       order_detalis:undefined,
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
        order:this.props.route.params.order,
        seleted_type:this.props.route.params.selected_type,
      });

      if (this.props.route.params.order.type && this.props.route.params.order.type == '5') {
          this.getHistoryCheckoutDetails(this.props.route.params.order);
      }else{
        this.getHistoryOrderDetails(this.props.route.params.order);
      }


    }


  }


  getHistoryOrderDetails(order){


     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getHistoryOrderDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<orderId i:type="d:string">'+ order.id +'</orderId>'+
     '</n0:getHistoryOrderDetails></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sale','getHistoryOrderDetailsResponse',data, function(json) {

        if (json && json.success == 1 ) {
            // 当天有
             temporary.setState({
                order_detalis:json.data,
             }); 

        }
    });      


  }


  getHistoryCheckoutDetails(order){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getHistoryCheckoutDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<orderId i:type="d:string">'+ order.id +'</orderId>'+
     '</n0:getHistoryCheckoutDetails></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('sale','getHistoryCheckoutDetailsResponse',data, function(json) {

        if (json && json.success == 1 ) {
            // 当天有
             temporary.setState({
                order_detalis:json.data,
             }); 

        }
    });      


  }




  orderItems(){

    if (this.state.order_detalis  && this.state.order_detalis.Order_Line_Info ) {

      var items = [];

      for (var i = 0; i < this.state.order_detalis.Order_Line_Info.length; i++) {


        var item = this.state.order_detalis.Order_Line_Info[i];
        
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

                <Text style = {styles.text_view_price}>${StringUtils.toDecimal(item.price)}</Text>


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

  clickHelp(){

    const { navigation } = this.props;

    if (navigation) {
      navigation.navigate('FrequentlyAskedQuestionsActivity');
    }


  }



  totalView(){

    var sub_total = 0.0;
    var total = 0;
    var discount = 0;
    var gst = 0.00;
    var freight = 0.0;
    var show_total = 0.00;


    if (this.state.order_detalis && this.state.order_detalis.Order_Line_Info) {


      for (var i = 0; i < this.state.order_detalis.Order_Line_Info.length; i++) {

         var item =  this.state.order_detalis.Order_Line_Info[i];

         total += parseInt(item.qty);

         discount += parseFloat(item.new_recharge_discount);

         discount += parseFloat(item.reward_discount);

         var paid_amount = parseFloat(item.paid_amount);
         var rate = parseFloat(item.rate);

         gst += paid_amount / (1 + (rate / 100))*(rate / 100);

      }

    }





    if (this.state.order_detalis && this.state.order_detalis.Order_Info) {

        freight = parseFloat(this.state.order_detalis.Order_Info.freight);

        sub_total = parseFloat(this.state.order_detalis.Order_Info.subtotal);

        show_total = parseFloat(this.state.order_detalis.Order_Info.total);
    }


    show_total += freight;



    var items = [];


    var local_title = '';
    var address = '';


    if (freight == 0) {

      if (this.state.order_detalis && this.state.order_detalis.Order_Line_Info &&  this.state.order_detalis.Order_Line_Info.length > 0) {


        local_title = 'Self Collection @ ' + this.state.order_detalis.Order_Line_Info[0].delivery_location_name;
        address = this.state.order_detalis.Order_Line_Info[0].delivery_location_address;

      }else {

        local_title = 'Self Collection';

      }


    }else {

      local_title = 'Local Delivery';

      if (this.state.order_detalis && this.state.order_detalis.Order_Info) {

        address = this.state.order_detalis.Order_Info.address;
      }
      

    }



    items.push(

        <View style = {{width:'100%'}}>

          <Text style = {styles.text_item_title}>{local_title}</Text>
          <Text style = {styles.text_item_adresss}>{address}</Text>

        </View>

    );


    items.push(

        <View style = {styles.view_voucher}>

            <Text style = {styles.text_voucher}>Total Items</Text>

            <Text style = {styles.text_voucher}>{total}</Text>

        </View>


    );


    items.push(
    

       <View style = {styles.view_voucher}>


          <Text style = {styles.text_voucher}>Sub Total</Text>

          <Text style = {styles.text_voucher}>{'$' + StringUtils.toDecimal(sub_total)}</Text>


      </View>
      
    ); 


    if (freight > 0) {

      items.push(

           <View style = {styles.view_voucher}>

            <Text style = {styles.text_voucher}>Local Delivery</Text>

            <Text style = {styles.text_voucher}>{'$' + StringUtils.toDecimal(freight)}</Text>

        </View>


      );

    }


    if (discount > 0) {

      items.push(


           <View style = {styles.view_voucher}>


              <Text style = {styles.text_voucher}>Discount</Text>

              <Text style = {styles.text_voucher}>{'-$' + StringUtils.toDecimal(discount)}</Text>


          </View>


      );


    }



    items.push(

       <View style = {styles.view_voucher}>

          <Text style = {styles.text_voucher_total}>{gst > 0 ?  'Total (Inclusive of GST $' + StringUtils.toDecimal(gst) + ')' : 'Total'}</Text>

          <Text style = {styles.text_voucher_total}>{StringUtils.toDecimal(show_total)}</Text>

      </View>


    );


  
    return items;



  }




  render() {

    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {styles.afearea} >

              <TitleBar
                title = {'My Orders'} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>


              <View style = {styles.view_content}>


                <ScrollView style = {styles.scrollview}
                  contentOffset={{x: 0, y: 0}}>


                  <View style = {styles.view_type}>

                        <View style = {[styles.view_type_item,{backgroundColor:this.state.seleted_type == 0 ? '#145A7C' : (this.state.seleted_type == 1 ? '#38B46C' : '#E0e0e0')}]}>


                          <Text style = {styles.text_type}>{this.state.seleted_type == 0 ? 'In Progress' : (this.state.seleted_type == 1 ? 'Completed' : 'Cancelled')}</Text>


                        </View>


                  </View>


                  <Text style = {styles.text_order_title}>Order Summary</Text>



                  <View style = {styles.view_item}>

                        <Text style = {styles.text_item_title}>{'Date of Order ' + DateUtil.getShowTimeFromDate4(this.state.order.invoice_date)}</Text>

                        <Text style = {[styles.text_item_title,{marginTop:24}]}>Your Items</Text>


                        {this.orderItems()}


                  </View>



                   <View style = {styles.view_item}>



                      {this.totalView()}

                  
                   </View>




                </ScrollView>  


                 <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout]}  
                          activeOpacity = {0.8}
                          onPress={this.clickHelp.bind(this)}>


                      <Text style = {styles.next_text}>Need Help?</Text>

                    </TouchableOpacity>


                </View>





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
    backgroundColor:'#FFFFFF',
     padding:24,
  },
  scrollview:{
     flex:1,
  },
  view_type:{
    width:'100%',
    alignItems: 'center',
    justifyContent: 'center',
  },
  view_type_item:{
    paddingLeft:10,
    paddingRight:10,
    paddingTop:5,
    paddingBottom:5,
    backgroundColor:'#145A7C',
    borderRadius:50,
  },
  text_type:{
    color:'#FFFFFF',
    fontSize:12,
    fontWeight:'bold',
  },
  text_order_title:{
    marginTop:4,
    color:'#145A7C',
    fontSize:24,
    fontWeight:'bold',
    textAlign :'center',
  },
  view_item:{
    marginTop:24,
    width:'100%',
    backgroundColor:'#FAF3EB',
    borderRadius:16,
    padding:16,
  },
  text_item_title:{
    fontSize:16,
    color:'#145A7C',
    fontWeight:'bold',
  },
  text_item_adresss:{
    marginTop:16,
    fontSize:14,
    color:'#333333',
  },
  view_voucher:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_voucher:{
    marginTop:24,
    fontSize:14,
    color:'#000000',
  },
  text_voucher_total:{
    marginTop:24,
    fontSize:16,
    color:'#000000',
    fontWeight:'bold',
  },
  next_layout:{
    marginTop:32,
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
    marginBottom:32,
    width:'100%',
    height:44,
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
  view_line : {
    backgroundColor:'#E0e0e0',
    width:'100%',
    height:1,
  },
});