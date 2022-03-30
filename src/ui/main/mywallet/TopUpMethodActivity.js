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

// import DateTimePicker from '@react-native-community/datetimepicker'


import {DatePicker} from "react-native-common-date-picker";



export default class TopUpMethodActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       selected_method:undefined,
       method_detail:undefined,
       method_data:[],
       new_card_name:undefined,
       new_card_number:undefined,
       new_card_date:undefined,
       new_card_cvv:undefined,
       show_birth_day:new Date(),
       keyboard:false,
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

       this.getMethodsForApp(user_bean);

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





_renderItem = (item) => {

  return (

     <TouchableOpacity 
        activeOpacity = {0.8}
        onPress={this.clickPaymentMethodItem.bind(this,item)}>


        <View style = {{width:'100%'}}>

          <View style = {styles.view_item}>

            <View style = {{width:17,height:12}}>
                {this._selectedItem(item)}

            </View>

            <Image style = {{width:20,height:20,marginLeft:16}} 
                resizeMode = 'contain' 
                source={require('../../../../images/qianbao_526.png')}/>

            <Text style = {styles.text_item_name}>{item.item.name_on_card}</Text> 


            <TouchableOpacity 
              activeOpacity = {0.8}
              onPress={this.deletedPaymentMethodItem.bind(this,item)}>


              <Image style = {{width:20,height:20}} 
                resizeMode = 'contain' 
                source={require('../../../../images/hongse_deltete.png')}/>   

            </TouchableOpacity>  

          </View>

          <View style = {styles.view_line} />

        </View>

    </TouchableOpacity>   
 
  );


}

clickPaymentMethodItem(item){


  this.setState({
    selected_method:item.item,
  });

}



_selectedItem(item){

  if (this.state.selected_method && item.item.id == this.state.selected_method.id) {

    return (

      <Image style = {{width:17,height:12,marginTop:5}} 
            resizeMode = 'contain' 
            source={require('../../../../images/selected_526.png')}/>

    );

  }else {

    return (<View />);
  }


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
  '<id i:type="d:string">'+ item.item.id +'</id>'+
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






_methodDataView(){


  if (this.state.method_data && this.state.method_data.length > 0) {


    return (

      <View style = {[styles.view_content,{padding:24}]}>


           <Text style = {styles.text_method}>Payment Method</Text>


           <FlatList
              style = {{flex:1}}
              ref = {(flatList) => this._flatList = flatList}
              renderItem = {this._renderItem}
              onEndReachedThreshold={0}
              keyExtractor={(item, index) => index.toString()}
              data={this.state.method_data}/>



           <TouchableOpacity 
              activeOpacity = {0.8}
              onPress={this.clickAddPaymentMethod.bind(this,1)}>

              <Text style = {styles.text_add_card}>Add Card</Text>    

          </TouchableOpacity>    




         <View style = {[styles.next_view,{paddingLeft:0,paddingRight:0}]}>

                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:this.state.selected_method ? '#C44729' : '#BDBDBD'}]}  
                      activeOpacity = {this.state.selected_method  ? 0.8 : 1}
                      onPress={this.clickDone.bind(this)}>

                    <Text style = {styles.next_text}>Done</Text>

                  </TouchableOpacity>

              </View>  

      </View>


    );




  }else {


    return (

      <View style = {styles.view_na_data}>


          <Text style = {styles.text_no_data}>You have no payment method</Text>


           <View style = {styles.next_view}>

                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#145A7C'}]}  
                      activeOpacity = {0.8}
                      onPress={this.clickAddPaymentMethod.bind(this,1)}>

                    <Text style = {styles.next_text}>Add Payment Method</Text>

                  </TouchableOpacity>

          </View>




      </View>

    );


  }


}

clickDone(){


  var one_method_lines = [];

  one_method_lines.push(this.state.selected_method);

  var new_method_detail = this.state.method_detail;

  new_method_detail.method_lines = one_method_lines;

  DeviceEventEmitter.emit('selected_method',JSON.stringify(new_method_detail));

  this.props.navigation.goBack();


}
  



clickAddPaymentMethod(type ){

  
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
                                   multiline = {true}
                                  value = {this.state.new_card_name} 
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
                                  placeholder='Enter Card Number'
                                  keyboardType='numeric'
                                  multiline = {true}
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


                              
                                <View style = {[styles.view_line,{marginTop:10}]}/>   



                              </View>


                               <View style = {{flex:1}}>

                                 <Text style = {styles.text_popup_two_title}>CVV</Text>


                                  <TextInput 
                                  style = {styles.text_input}
                                  ref='intput_amount'
                                  placeholder='CVV'
                                  multiline = {true}
                                  keyboardType='numeric'
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


                                <View style = {[styles.view_line,{marginTop:5}]}/>   


                              </View>


                          </View>
                         

                       <View style = {[styles.next_view,{paddingLeft:0,paddingRight:0}]}>

                                <TouchableOpacity style = {[styles.next_layout]}  
                                    activeOpacity = {0.8}
                                    onPress={this.addCard.bind(this)}>

                                  <Text style = {styles.next_text}>Add Card</Text>

                                </TouchableOpacity>

                            </View>


                       <View style = {{width:'100%',height:this.state.keyboard ? 300 : 0,}}/>           
     
                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


}



clickNewCardDate(){

    this.coverLayer.hide();
    this.setState({
      keyboard:false,
    });

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





 render() {

   const { navigation } = this.props;

    return (

      <View style = {styles.bg}>


        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


        <SafeAreaView style = {styles.afearea} >

          <TitleBar
            title = {'Payment Method'} 
            navigation={navigation}
            hideLeftArrow = {true}
            hideRightArrow = {false}
            extraData={this.state}/>

          <View style = {styles.view_content}>


            {this._methodDataView()}
          

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
  view_na_data : {
    flex:1,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_no_data:{
    width:'100%',
    color:'#BDBDBD',
    textAlign :'center',
    fontSize:16,
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
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF'
  },
  view_item : {
    paddingTop:16,
    paddingBottom:16,
    width:'100%',
    flexDirection: 'row',
  },
  text_item_name:{
    flex:1,
    marginLeft:8,
    color:'#333333',
    fontSize:16,
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
    fontSize:18,
    textAlign :'center',
    fontWeight: 'bold',
  },
  view_popup_item:{
    marginTop:16,
    padding:16,
    borderRadius:16,
    backgroundColor:'#FAF3EB',
    width:'100%',
  },
  popup_service_more_head:{

    flexDirection: 'row',
  

  },
  popup_service_more:{
    borderRadius:8,
    width:24,
    height:24,
    backgroundColor:'#EE8F7B',
    justifyContent: 'center',
    alignItems: 'center',
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


});


