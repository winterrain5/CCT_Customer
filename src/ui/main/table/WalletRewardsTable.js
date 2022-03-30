import React, {
  Component
} from 'react';
import PropTypes from 'prop-types';
import {
  Text,
  View,
  Image,
  StatusBar,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  FlatList,
  Dimensions,
  DeviceEventEmitter
} from 'react-native';

import DeviceStorage from '../../../uitl/DeviceStorage';

import DateUtil from '../../../uitl/DateUtil';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import {Card} from 'react-native-shadow-cards';


let {width, height} = Dimensions.get('window');


export default class WalletRewardsTable extends Component {

  constructor(props) {
      super(props);
      this.state = {
         head_company_id:'97',
         userBean:undefined,
         vouchers:[],
         coupons:[],
      }
    }

  UNSAFE_componentWillMount(){

    DeviceStorage.get('head_company_id').then((ompany_id) => {


      if (ompany_id) {
        this.setState({
            head_company_id: ompany_id,
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

      this.getClientValidRewards(user_bean);

      this.getClientGifts(user_bean);
    });
     
  }


  getClientGifts(userBean){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientGifts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '<isValid i:type="d:string">1</isValid>'+
    '</n0:getClientGifts></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('gift-certificate','getClientGiftsResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0) {

            // 当天有
             temporary.setState({
                vouchers:json.data,
             }); 

        }else {
           
            temporary.setState({
                vouchers:[],
             }); 

        }

    });      



  }




  getClientValidRewards(userBean){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientValidRewards id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<exceed i:type="d:string">0</exceed>'+
    '<isDiscount i:type="d:string">1</isDiscount>'+
    '<clientId i:type="d:string">'+ userBean.id  +'</clientId>'+
    '</n0:getClientValidRewards></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('reward-discounts','getClientValidRewardsResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0) {

            // 当天有
             temporary.setState({
                coupons:json.data,
             }); 

        }else {
           
            temporary.setState({
                coupons:[],
             }); 

        }

    });      


  }





  _vouchersView(){


    if (this.state.vouchers && this.state.vouchers.length > 0) {


      var items = [];

      for (var i = 0; i < this.state.vouchers.length; i++) {
         var voucher = this.state.vouchers[i];

          var img = voucher.img;
          var image_url = img ? img.slice(1,img.length) : '';

         items.push(

           <TouchableOpacity
              key = {i + ''}                      
              activeOpacity = {0.8}
              onPress={this.clickVoucherItem.bind(this,voucher)}> 


               <View style = {styles.view_item_voucher}>

                  <View style = {styles.view_image}>

                      <Image 
                        style={{flex:1,borderRadius:16}}
                        source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                        resizeMode="cover" />

                  </View>

                  <Text style = {styles.text_item_name}>{voucher.name}</Text>

                  <Text style = {styles.text_item_info}>{voucher.description}</Text>


              </View>

          </TouchableOpacity>    


           
        );
      }

      return items;

    }else {


      return (

        <View style = {{width:width,height:200,justifyContent: 'center', alignItems: 'center'}}>


            <Text style = {styles.text_no_data}>You have no new Coupons</Text>


        </View>

      );


    }

  }

  clickVoucherItem(item){


    DeviceEventEmitter.emit('vaoucher_detail',JSON.stringify(item));

  
  }


  _couponsView(){

    if (this.state.coupons && this.state.coupons.length > 0) {


      var items = [];

      for (var i = 0; i < this.state.coupons.length; i++) {
         var coupon = this.state.coupons[i];

          var img = coupon.img;
          var image_url = img ? img.slice(1,img.length) : '';

         items.push(


            <TouchableOpacity                      
              activeOpacity = {0.8}
              onPress={this.clickVoucherItem.bind(this,coupon)}> 


              <View style = {styles.view_item_voucher}>

                <View style = {styles.view_image}>

                     <Image 
                        style={{flex:1,borderRadius:16}}
                        source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                        resizeMode="cover" />


                </View>

                <Text style = {styles.text_item_name}>{coupon.name}</Text>

                <Text style = {styles.text_item_info}>{coupon.description}</Text>

              </View>

            </TouchableOpacity>  
    

        );
      }

      return items;

    }else {


      return (

        <View style = {{width:width,height:200,justifyContent: 'center', alignItems: 'center'}}>


            <Text style = {styles.text_no_data}>You have no new Coupons</Text>


        </View>

      );


    }


  }







  render() {

    return(

      <View style = {styles.bg}>

         <ScrollView 
            style = {styles.scrollview}
            contentOffset={{x: 0, y: 0}}>



            <View style = {{width:'100%'}}>


                <Text style = {styles.text_title}>Vouchers</Text>


                <ScrollView 
                  showsHorizontalScrollIndicator = {false}
                  horizontal={true}
                  contentOffset={{x: 0, y: 0}}>


                  {this._vouchersView()}

                </ScrollView>  
                


                 <Text style = {styles.text_title}>Coupons</Text>


                <ScrollView
                  showsHorizontalScrollIndicator = {false} 
                  horizontal={true}
                  contentOffset={{x: 0, y: 0}}>


                  {this._couponsView()}

                </ScrollView>  



            </View>  



        </ScrollView>    







      </View>


    );

  }
    
}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
 scrollview:{
  flex:1,
  backgroundColor:'#FFFFFF'
},
text_title:{
    marginTop:24,
    marginLeft:24,
    color:'#145A7C',
    fontWeight:'bold',
    fontSize:18,
},
text_no_data:{
  width:'100%',
  color:'#BDBDBD',
  fontWeight:'bold',
  fontSize:16,
  textAlign: 'center',
},
view_item_voucher:{
  marginTop:8,
  width:width / 2 -16,
  marginLeft:8
},
view_image:{
  width:'100%',
  height:120,
  borderRadius:16,
  backgroundColor:'#F2F2F2'
},
text_item_name:{
  marginTop:8,
  width:'100%',
  color:'#333333',
  fontWeight:'bold',
  fontSize:14,
},
text_item_info:{
  marginTop:4,
  color:'#333333',
  fontSize:12,
}

});

