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

export default class CouponActivity extends Component {


   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       selected_type:0,  // 当前选择的方式  0：折扣 1 ：礼券
       selected_coupon:undefined, // 选择的折扣
       new_time:undefined, // 当前时间
       coupons:[]
    }
  }

   UNSAFE_componentWillMount(){



    var selected_type = 0;


    console.error(this.props);

    if (this.props != undefined && this.props.selected_type != undefined) {
      this.setState({
        selected_coupon:this.props.selected_coupon,
        selected_type:this.props.selected_type,
      });

      selected_type = this.props.selected_type;
    }else {
      if (this.props.route && this.props.route.params) {
        this.setState({
          selected_coupon:this.props.route.params.selected_coupon,
          selected_type:this.props.route.params.selected_type,
        });
  
        selected_type = this.props.route.params.selected_type;
  
      }
  
    }
    

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

      if (selected_type == 0) {
        this.getClientValidRewards(user_bean);
      }else {
        this.getClientGifts(user_bean);
      }

    });

    this.getSystemTime();
     
  }


  getClientGifts(user_bean){


    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientGifts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">' + user_bean.id + '</clientId>'+
    '<isValid i:type="d:string">1</isValid>'+
    '</n0:getClientGifts></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('gift-certificate','getClientGiftsResponse',data, function(json) {
      

      if (json && json.success == 1 && json.data ) {

          temporary.setState({
            coupons:json.data,
          });

      }
      
    });

  }





  getSystemTime(){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getSystemTime id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('system-config','getSystemTimeResponse',data, function(json) {
      
      if (json && json.success == 1 && json.data ) {

          temporary.setState({
            new_time:json.data,
          });

      }
       

    });
  }

  getClientValidRewards(userBean){

    var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientValidRewards id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<exceed i:type="d:string">0</exceed>'+
    '<isDiscount i:type="d:string">1</isDiscount>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getClientValidRewards></v:Body></v:Envelope>';      
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('reward-discounts','getClientValidRewardsResponse',data, function(json) {
      
      if (json && json.success == 1 && json.data ) {

          temporary.setState({
            coupons:json.data,
          });

      }
      
    });

  }




  _renderItem = (item) =>{


    return (

      <View style = {{width:'100%',marginTop:16}}>

         <View style = {styles.view_item}>

            <View style = {styles.view_image_card}>

            </View>


            <View style = {{flex:1,paddingLeft:20,paddingTop:8}}>


              <Text style = {styles.text_view_name}>{item.item.name}</Text>

              <Text style = {styles.text_view_content}>{item.item.description}</Text>

              <Text style = {styles.text_view_date}> {item.item.expired_time ? 'Expires on' + DateUtil.getShowTimeFromDate4(item.item.expired_time) : ''}</Text>

            </View>


         </View>


          <View style = {styles.next_view}>

            <TouchableOpacity style = {[styles.next_layout]}  
                activeOpacity = {0.8 }
                onPress={this.clickSelectedItem.bind(this,item)}>


                   <Text style = {styles.next_text}>{this.state.selected_coupon ? (this.state.selected_coupon.id == item.item.id ? 'Cancel Use' : 'Use Now') : 'Use Now'}</Text>

            </TouchableOpacity>

            </View>


         <View style = {styles.view_line}/>


      </View>


      );

  }


clickSelectedItem(item){

  if (this.props.navigation) {
    this.props.navigation.goBack();
  }else {
    NativeModules.NativeBridge.goBack()
  }
  

  if (this.state.selected_type == 0) {

     DeviceEventEmitter.emit('selected_coupon',JSON.stringify(item.item));

  }else {

     DeviceEventEmitter.emit('selected_voucher',JSON.stringify(item.item));

  }
 


}


 

  render() {

    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

         <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


         <SafeAreaView style = {styles.afearea} >

            <TitleBar
              title = {this.state.selected_type == 0 ? 'Coupon' : 'Voucher'} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


             <View style = {[styles.bg,{padding:16}]}>


                <Text style = {styles.text_title}>Select {this.state.selected_type == 0 ? 'Coupon' : 'Voucher'} </Text>


                 <FlatList
                    style = {{flex:1}}
                    ref = {(flatList) => this._flatList = flatList}
                    renderItem = {this._renderItem}
                    onEndReachedThreshold={0}
                    keyExtractor={(item, index) => index.toString()}
                    data={this.state.coupons}/>  

             
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
    marginBottom:8,
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
    marginTop:24,
    backgroundColor:'#E0e0e0',
    width:'100%',
    height:1,
  },
   view_iparinput:{
     paddingTop:16,
     paddingLeft:16,
     paddingRight:16,
  },
  view_item : {
    width:'100%',
    flexDirection: 'row',
  },
  view_image_card:{
    flex:1,
    backgroundColor:'#F2F2F2',
    borderRadius:16,
    width:'100%',
    height:120,
  },
  text_view_name:{
    fontSize: 14,
    color: '#333333',
    fontWeight: 'bold',
  },
  text_view_content:{
    flex:1,
    marginTop:9,
    fontSize: 12,
    color: '#333333',
  },
  text_view_date:{
    fontSize: 10,
    color: '#828282',
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
    marginTop:16
  },
});