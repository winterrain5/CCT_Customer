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
  NativeModules,
} from 'react-native';

let nativeBridge = NativeModules.NativeBridge;


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

// import DateTimePicker from '@react-native-community/datetimepicker'


import {DatePicker} from "react-native-common-date-picker";


export default class PaymentMethodActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       select_type:0, // 选择的支付的类型。0：自己的信用卡，1，朋友的卡 2.添加的信用卡
       client_voucher:undefined,
       method_detail:undefined,
       method_data:undefined,
       method_postion:-1,
       friend_method_postion:-1,
       friend_cards:undefined,
       new_card_name:undefined,
       new_card_number:undefined,
       new_card_date:undefined,
       new_card_cvv:undefined,
      show_birth_day:new Date(),
       keyboard:false,
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

      //获取当前人员会员卡余额
      this.getNewReCardAmountByClientId(user_bean);


      //获取用户所有信用卡

      this.getMethodsForApp(user_bean);


      //获取朋友的卡
      this.getFriendsCard(user_bean);


    });     
  }


  getFriendsCard(userBean){

      if (userBean == undefined) {
        return;
      }

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getFriendsCard id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
     '</n0:getFriendsCard></v:Body></v:Envelope>';


       console.error(data);

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('voucher','getFriendsCardResponse',data, function(json) {


    
        if (json && json.success == 1 && json.data ) {
           temporary.setState({
              friend_cards:json.data, 
           });
        }

    });      


  } 


  getMethodsForApp(userBean){


     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
     '<n0:getMethodsForApp id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
     '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
     '</n0:getMethodsForApp></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('payment-method','getMethodsForAppResponse',data, function(json) {


        if (json && json.success == 1 && json.data && json.data.length > 0) {
           temporary.setState({
              method_detail:json.data[0], 
              method_data:json.data[0].method_lines,
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


  methodsForAppview(){


    if (this.state.method_data && this.state.method_data.length > 0) {


        var items = [];

       for (var i = 0; i < this.state.method_data.length; i++) {

           var card  = this.state.method_data[i];

           items.push(


                <TouchableOpacity 
                      onPress={this.clickMethodCard.bind(this,i)}
                      activeOpacity = {0.8 }>


                       <View style = {{width:'100%'}}>

                          <View style = {[styles.view_item,{marginTop:16}]}>

                               <Image 
                                  style={{width:17,height:12, marginLeft:8,}}
                                  source={ this.state.select_type == 2 && this.state.method_postion == i ? require('../../../../images/selected_526.png') : undefined}
                                  resizeMode = 'contain' />


                               <Image 
                                  style={{width:20,height:18, marginLeft:10,marginRight:11}}
                                  source={require('../../../../images/qianbao_526.png')}
                                  resizeMode = 'contain' />    


                              <Text style = {styles.text_card_name}>{card.name_on_card}</Text>      


                              <TouchableOpacity 
                                  activeOpacity = {0.8}
                                  onPress={this.deletedPaymentMethodItem.bind(this,card)}> 


                                  <Image 
                                      style={{width:20,height:20, marginLeft:8}}
                                      source={require('../../../../images/hongse_deltete.png')}
                                      resizeMode = 'contain' />   


                              </TouchableOpacity>    
      

                          </View>


                         <View style = {styles.view_line} /> 



                  </View>


                </TouchableOpacity>      
  

          );

       }

       return items;


    }else {


      return ( <View />);

    }


  }


  methodsFriendView(){


    if (this.state.friend_cards && this.state.friend_cards.length > 0) {

        var items = [];

       for (var i = 0; i < this.state.friend_cards.length; i++) {

           var card  = this.state.friend_cards[i];


           var name = '';

          if (card.first_name) {
            name +=  card.first_name;
          }

          if (card.last_name) {
            name +=  (' ' +  card.last_name);
          }

           items.push(


                <TouchableOpacity 
                      onPress={this.clickFriendMethodCard.bind(this,i)}
                      activeOpacity = {0.8 }>


                       <View style = {{width:'100%'}}>

                          <View style = {[styles.view_item,{marginTop:16}]}>

                               <Image 
                                  style={{width:17,height:12, marginLeft:8,}}
                                  source={ this.state.select_type == 1 && this.state.friend_method_postion == i ? require('../../../../images/selected_526.png') : undefined}
                                  resizeMode = 'contain' />


                               <Image 
                                  style={{width:20,height:18, marginLeft:10,marginRight:11}}
                                  source={require('../../../../images/qianbao_526.png')}
                                  resizeMode = 'contain' />    


                              <Text style = {styles.text_card_name}>{name}</Text>      


                              <Text style ={styles.text_anument}>${StringUtils.toDecimal(card.new_card_amount)}</Text>    
      

                          </View>


                         <View style = {styles.view_line} /> 



                  </View>


                </TouchableOpacity>      
  

          );

       }

       return items;


    }else {


      return ( <View />);

    }



  }


  clickFriendMethodCard(postion){

    this.setState({
      select_type:1,
      friend_method_postion:postion,
    });

  }





  clickMethodCard(postion){


    this.setState({
        select_type:2,
        method_postion:postion,
    });

  }


  clickCCTCard(){

    this.setState({
      select_type:0,
    });

  }

  clickAddPaymentMethod(type){


    if (type == 1) {
      this.setState({
         new_card_name:undefined,
         new_card_number:undefined,
         new_card_date:undefined,
         new_card_cvv:undefined,
      });
    }

      // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={[styles.view_popup_bg,{paddingBottom:50}]}>


                          <Text style = {[styles.text_popup_title]}>Add Card</Text>


                          <View style = {[styles.view_add_item,{marginTop:32}]}>


                              <Text style = {styles.text_popup_two_title}>Name on Card</Text>


                              <TextInput 
                                  style = {styles.text_input}
                                  ref='intput_amount'
                                  placeholder='Enter Name on Card'
                                  multiline = {false}
                                  onBlur={() => {
                                      this.setState({
                                        keyboard:false,
                                      })
                                  }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }}
                                  value = {this.state.new_card_name} 
                                  onChangeText={(text) => {
                                  
                                     this.setState({
                                        new_card_name:text,
                                     });
                              
                                    }  
                                  }/>


                               <View style = {[styles.view_line,{marginTop:5}]}/>   

                          </View> 


                           <View style = {[styles.view_add_item,{marginTop:16}]}>


                              <Text style = {styles.text_popup_two_title}>Card Number</Text>


                              <TextInput 
                                  style = {styles.text_input}
                                  ref='intput_amount'
                                  keyboardType='numeric'
                                  placeholder='Enter Card Number'
                                  onBlur={() => {
                                      this.setState({
                                        keyboard:false,
                                      })
                                  }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }}
                                  multiline = {false}
                                  value = {this.state.new_card_number} 
                                  onChangeText={(text) => {
                                  
                                     this.setState({
                                        new_card_number:text,
                                     });
                              
                              
                                    }  
                                  }/>


                               <View style = {[styles.view_line,{marginTop:5}]}/>   



                          </View>   


                          <View style = {styles.viw_expiry_cvv}>


                              <View style = {{flex:2,marginRight:16}}>

                                 <Text style = {styles.text_popup_two_title}>Expiry Date</Text>


                                 <TouchableOpacity 
                                    activeOpacity = {0.8}
                                    onPress={this.clickNewCardDate.bind(this)}>

                                     <Text style = {[styles.text_input,{color:this.state.new_card_date ? '#333333':'#828282'}]}>{this.state.new_card_date ? StringUtils.showDateYMDtoMY(this.state.new_card_date) : 'MM/YY'}</Text>

                                </TouchableOpacity>   


                              
                                <View style = {[styles.view_line,{marginTop:5}]}/>   



                              </View>


                               <View style = {{flex:1}}>

                                 <Text style = {styles.text_popup_two_title}>CVV</Text>


                                  <TextInput 
                                  style = {styles.text_input}
                                  ref='intput_amount'
                                  keyboardType='numeric'
                                  placeholder='CVV'
                                  multiline = {false}
                                  onBlur={() => {
                                      this.setState({
                                        keyboard:false,
                                      })
                                  }}
                                  onFocus={() => {
                                      this.setState({
                                        keyboard:true,
                                      })
                                  }}
                                  value = {this.state.new_card_cvv} 
                                  onChangeText={(text) => {
                                  
                                     this.setState({
                                        new_card_cvv:text,
                                     });     
                                
                                    }  
                                  }/>


                                <View style = {[styles.view_line,{marginTop:10}]}/>   


                              </View>


                          </View>
                         

                       <View style = {[styles.next_view,{paddingLeft:0,paddingRight:0}]}>

                                <TouchableOpacity style = {[styles.next_layout]}  
                                    activeOpacity = {0.8}
                                    onPress={this.addCard.bind(this)}>

                                  <Text style = {styles.next_text}>Add Card</Text>

                                </TouchableOpacity>

                            </View>  
     
                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);




  }


  clickNewCardDate(){


    var defaultDate ;

    if (this.state.new_card_date == undefined) {
        this.setState({
          show_birth_day:DateUtil.formatDateTime1(),
        });

        defaultDate = DateUtil.formatDateTime1();

    }else {

       this.setState({
          show_birth_day:this.state.new_card_date,
        });

       defaultDate = this.state.new_card_date;

    }


    this.coverLayer.hide();


    this.setState({
      keyboard:false,
    });


      // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}></Text>


                         <DatePicker
                              style = {styles.date_picker}
                              defaultDate = {defaultDate}
                              type = {'MM-YYYY'}
                              minDate = {DateUtil.formatDateTime1()}
                              maxDate = {'2100-01-01'}
                              monthDisplayMode = {'en-short'}
                              showToolBar = {false}
                              onValueChange={(selectedIndex) => {
                                 this.setState({
                                  show_birth_day:selectedIndex,
                                });
                              }}
                          />



                          <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPopCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickPopConfirm.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Confirm</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>                     
                        </View>
                    )
                },
            ()=>this.clickPopCancel(),
            CoverLayer.popupMode.bottom);


    }


  clickPopCancel(){

      this.coverLayer.hide();

      this.clickAddPaymentMethod(0);

    }

  clickPopConfirm(){

      this.coverLayer.hide();

      if (this.state.show_birth_day.split('-').length == 2) {

        this.setState({
           new_card_date:(this.state.show_birth_day  + '-01'),
        });

      }else {

         this.setState({
           new_card_date:(this.state.show_birth_day),
        });

      }

     
     
      this.clickAddPaymentMethod(0);

  }


  addCard(){

    if (!this.state.new_card_name) {
      toastShort('Enter Name on Card');
      return;
    }

    if (!this.state.new_card_number) {
      toastShort('Enter Card Number');
      return;
    }

     if (!this.state.new_card_date) {
      toastShort('Enter Expiry Date');
      return;
    }


     if (!this.state.new_card_cvv) {
      toastShort('Enter Card CVV');
      return;
    }

    this.addCardIntoPayment();

  }


  addCardIntoPayment(){

   this.coverLayer.hide();
   this.setState({
      keyboard:false,
    });

   var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
   '<n0:addCardIntoPayment id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
   '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
   '<item><key i:type="d:string">payment_method_id</key><value i:type="d:string">'+this.state.method_detail.id +'</value></item>'+
   '<item><key i:type="d:string">companyId</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
   '<item><key i:type="d:string">expiry_date</key><value i:type="d:string">'+ this.state.new_card_date +'</value></item>'+
   '<item><key i:type="d:string">card_number</key><value i:type="d:string">'+ this.state.new_card_number +'</value></item>'+
   '<item><key i:type="d:string">name_on_card</key><value i:type="d:string">'+ this.state.new_card_name +'</value></item>'+
   '<item><key i:type="d:string">client_id</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
   '<item><key i:type="d:string">authorisation_code</key><value i:type="d:string">'+ this.state.new_card_cvv + '</value></item>'+
   '</data></n0:addCardIntoPayment></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('payment-method','addCardIntoPaymentResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {
            // 获取
            toastShort('Add Success!');
            temporary.getMethodsForApp(temporary.state.userBean);
           
        }else {
           toastShort('Add Failed!');

        }
    });   

}


deletedPaymentMethodItem(item){

          // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Are you sure you want to remove this payment method?</Text>



                          <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickdeletePaymentMethodCanner.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickdeletePaymentMethodSure.bind(this,item)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Confirm</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                        </View>                     
     
                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


}

clickdeletePaymentMethodCanner(){
  this.coverLayer.hide();
}


clickdeletePaymentMethodSure(item){

  this.coverLayer.hide();

  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
  '<v:Body><n0:deleteCardIntoPayment id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<id i:type="d:string">'+ item.id +'</id>'+
  '</n0:deleteCardIntoPayment></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('payment-method','deleteCardIntoPaymentResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {
            // 获取
            toastShort('Detele Success!')
            temporary.getMethodsForApp(temporary.state.userBean);
           
        }else {
          toastShort('Detele Failed!')

        }
    });   

}



  clickDone(){


    var payment_method = {};

    payment_method.select_type = this.state.select_type;


    if (this.state.select_type == 2) {

      var method_detail =  this.state.method_detail;

      var method_lines = [];

      if (this.state.method_postion == -1 || this.state.method_postion >= this.state.method_data.length > 0) {
        return;
      }

      var method_line = this.state.method_data[this.state.method_postion];

      method_lines.push(method_line);

      method_detail.method_lines = method_lines;

      
      payment_method.method_detail = method_detail;

    }else if (this.state.select_type == 1) {


      if (this.state.friend_method_postion == -1 || this.state.friend_method_postion >= this.state.friend_cards.length > 0) {
          return;
      }

      var method_detail = this.state.friend_cards[this.state.friend_method_postion];

      payment_method.method_detail = method_detail;

    }

    DeviceEventEmitter.emit('selected_payment_method',JSON.stringify(payment_method));  


    if (this.props.pressLeft) {
      this.props.pressLeft()
    }else if (this.props.navigation){
      this.props.navigation.goBack();
    }else {
        nativeBridge.goBack();
    }
  }

   render() {

     const { navigation } = this.props;


     var level_name = 'Basic';


    if (this.state.userBean) {

          if (this.state.userBean.new_recharge_card_level == undefined || this.state.userBean.new_recharge_card_level == '1') {

              level_name = 'Basic';

          }else if (this.state.userBean.new_recharge_card_level == '2') {

            level_name = 'Silver';

          }else if (this.state.userBean.new_recharge_card_level == '3') {

            level_name = 'Gold';

          }else if (this.state.userBean.new_recharge_card_level == '4') {

            level_name = 'Platinum';
      
          }


    }



    return(

        <View style = {styles.bg}>

           <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


           <SafeAreaView style = {styles.afearea} >

               <TitleBar
                  title = {'Payment Method'} 
                  navigation={navigation}
                  hideLeftArrow = {true}
                  hideRightArrow = {false}
                  extraData={this.state}/>


                  <View style = {styles.view_title}>

                     <Text style = {styles.text_title}>Select your Payment Method</Text>

                  </View>

                 

              <ScrollView 
                  showsVerticalScrollIndicator = {false}
                  style = {[styles.bg,{padding:24}]}>

                 <TouchableOpacity 

                  onPress={this.clickCCTCard.bind(this)}
                  activeOpacity = {0.8 }>

                    <View style = {[styles.view_item]}>

                         <Image 
                            style={{width:17,height:12, marginLeft:8,}}
                            source={this.state.select_type == 0 ? require('../../../../images/selected_526.png') : undefined}
                            resizeMode = 'contain' />


                         <Image 
                            style={{width:26,height:26, marginLeft:8,marginRight:8}}
                            source={require('../../../../images/home_logo.png')}
                            resizeMode = 'contain' />    


                        <Text style = {styles.text_card_name}>{level_name} Card</Text>      


                        <Text style ={styles.text_anument}>${this.state.client_voucher ? StringUtils.toDecimal(this.state.client_voucher) : '0.00'}</Text>     


                    </View>


                  </TouchableOpacity>  

                

                <View style = {styles.view_line} />


                {this.methodsFriendView()}


                {this.methodsForAppview()}


              </ScrollView>



               <View style = {styles.view_add}>


                   <TouchableOpacity 
                      activeOpacity = {0.8}
                      onPress={this.clickAddPaymentMethod.bind(this,1)}>

                      
                        <Text style = {styles.text_add_card}>Add Card</Text>    

                    </TouchableOpacity>    

               

               </View> 

             

               <View style = {[styles.next_view,{paddingLeft:24,paddingRight:24}]}>

                  <TouchableOpacity style = {styles.next_layout}  
                      activeOpacity = {0.8}
                      onPress={this.clickDone.bind(this)}>

                    <Text style = {styles.next_text}>Done</Text>

                  </TouchableOpacity>

              </View>  


            

          </SafeAreaView>


           <CoverLayer ref={ref => this.coverLayer = ref}/>


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
    backgroundColor:'#FFFFFF',
    width:'100%',
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
    marginTop:11,
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
    justifyContent: 'center',
    width:'100%',
    flexDirection: 'row',
     alignItems: 'center',
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

  text_card_name:{
    flex:1,
    fontSize: 16,
    color: '#333333',
    fontWeight: 'bold',
  },
  text_anument:{
    fontSize: 16,
    color: '#828282',
  },
  view_add:{
    width:'100%',
    backgroundColor:'#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_add_card:{
    width:'100%',
    color:'#C44729',
    textAlign :'center',
    fontSize:14,
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
  text_popup_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    textAlign :'center',
    fontWeight: 'bold',
  },
  view_add_item:{
    width:'100%',
  },
  text_popup_two_title:{
    color:'#333333',
    fontSize:14,
  },
  text_input:{
    marginTop:5,
    width:'100%',
    color:'#333333',
    fontSize:14,
  },
  viw_expiry_cvv:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  date_picker:{
    width:'100%',
    height:220,
  },
  xpop_cancel_confim:{
    marginTop:31,
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
   xpop_touch:{
     width:'48%',
  },
  view_title:{
    paddingTop:24,
    paddingRight:24,
    paddingLeft:24,
     width:'100%',
     backgroundColor:'#FFFFFF',
  }
});