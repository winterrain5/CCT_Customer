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


export default class BookDetailsActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       service:undefined,
       service_location : undefined,
       today_conditions:undefined,
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


      this.getTCompany(this.props.route.params.service.location_id);
    }


  }


  getTCompany(location_id){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header /><v:Body><n0:getTCompany id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<id i:type="d:string">'+ location_id +'</id></n0:getTCompany></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('company','getTCompanyResponse',data, function(json) {

        if (json && json.success == 1 ) {

            // 
             temporary.setState({
                service_location:json.data,
             }); 

        }

    });      

  }




  cardQueue(){


    if (DateUtil.isToday(this.state.service.therapy_start_date) && this.state.service.queue_no != undefined && this.state.service.wellness_treatment_type == '2' && this.state.service.status == '4') {

     return (

       <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >


        <View style = {styles.view_card_item}>


          <Text style = {styles.text_item_title}>Queue No.</Text>

          <Text style = {styles.text_item_content}>{this.state.service.queue_no ? this.state.service.queue_no : ''}</Text>


        </View>



       </Card>



      );

    }else {

      return (<View/>)
    }


    

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


          {this._therapistView()}


        </View>



       </Card>



      );

  }


  _therapistView(){


    if (this.state.service  && this.state.service.staff_is_random == '2') {


      var therapist_name = '';

      if (this.state.service.staff_name) {


        therapist_name = this.state.service.staff_name;

      }else if (this.state.service.employee_first_name || this.state.service.employee_last_name) {

        if (this.state.service.employee_first_name) {
            therapist_name = this.state.service.employee_first_name;
        }

        if (this.state.service.employee_last_name) {
          if (therapist_name.length > 0) {
            therapist_name += (' ' + this.state.service.employee_last_name);
          }else {
            therapist_name += this.state.service.employee_last_name;
          }

        }
      }


      return (

          <View style = {styles.view_item_item}>

              <Image style = {styles.image_item} 
                  resizeMode = 'contain' 
                  source={require('../../../../images/person_0217.png')}/>


              <Text style = {styles.text_item_content2}>{therapist_name}</Text>

          </View> 


      );

    }else {


      return (<View />);


    }




  }




  cardNote(){


    if ((this.state.service.status == '1' || this.state.service.status == '2') && this.state.service.remark) {

    return (

      <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >

        <View style = {styles.view_card_item}>

          <Text style = {styles.text_item_title}>Addition Notes.</Text>

          <Text style = {styles.text_item_content}>{this.state.service.remark}</Text>

        </View>
      </Card>


      );

    }else {

      <View/>


    }

    

  }


  cardConditions(){



    if (this.state.service.wellness_treatment_type == '2' && this.state.today_conditions) {

      var symptoms = [];
      var last_activity = [];
      var area_of_pain = [];


      symptoms.push(

          <Text style = {styles.text_condition_content}>Aching</Text>

      );


      return(

       <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >
       
        <View style = {styles.view_card_item}>


          <Text style = {styles.text_item_title}>Conditions</Text>


          <View style = {[styles.condition_item,{marginTop:21}]}>


              <Text style = {styles.text_condition_title}>Symptoms</Text>


              <View style = {{flex:2}}>

               {symptoms}

              </View>  


          </View>


           <View style = {[styles.condition_item,{marginTop:14}]}>


              <Text style = {styles.text_condition_title}>Last Activity</Text>


              <View style = {{flex:2}}>

               {last_activity}

              </View>  


           </View>


           <View style = {[styles.condition_item,{marginTop:14}]}>


              <Text style = {styles.text_condition_title}>Area of Pain</Text>


              <View style = {{flex:2}}>

               {area_of_pain}

              </View>  


           </View>


        </View>


       </Card>  
        );


    }else {


      <View/>
    }
    
  }


  cardEnquiry(){


    return(

      <Card cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >


        <View style = {styles.view_card_item}>


          <Text style = {[styles.text_item_title,{fontSize:16}]}>Got an Enquiry ?</Text>


          <View style = {[styles.view_phone_wechat,{marginTop:10}]}>



            <TouchableOpacity style = {styles.view_phone_wechat}  
                activeOpacity = {0.8 }
                onPress={this.clickCallPhone.bind(this)}>


                <View style = {styles.view_phone_wechat}>


                   <Image style = {[styles.image_item,{marginTop:3}]} 
                      resizeMode = 'contain' 
                      source={require('../../../../images/phonexxxhdpi.png')}/>


                      <Text style = {styles.text_phone_wechat}>{this.state.service_location ? this.state.service_location.phone : ''}</Text>


                </View>






            </TouchableOpacity>      


            

            <TouchableOpacity style = {styles.view_phone_wechat}  
                activeOpacity = {0.8 }
                onPress={this.clickCallWhatapp.bind(this)}> 


                 <View style = {styles.view_phone_wechat}>


                     <Image style = {[styles.image_item,{marginTop:3}]} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/lv_dianhua.png')}/>

                        <Text style = {styles.text_phone_wechat}>{this.state.service_location ? this.state.service_location.whatapp : ''}</Text>


                  </View>


             </TouchableOpacity>   


          </View>

        </View>



      </Card>
     );



  }


  clickCallPhone(){


    if (!this.state.service_location || !this.state.service_location.phone  || this.state.service_location.phone.length == 0) {

      return;

    }


       // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Do you want to call {this.state.service_location ? this.state.service_location.phone : ''}</Text>


                        

                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPhonePopCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickPhonePopConfirm.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Sure</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>

                          
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);




  }


  clickPhonePopCancel(){

      this.coverLayer.hide();

  }

  clickPhonePopConfirm(){

    this.coverLayer.hide();

    const url = 'tel:' + this.state.service_location.phone;
    Linking.canOpenURL(url)
      .then(supported => {
        if (!supported) {
            toastShort('The phone does not support dialing function!');
        }
        return Linking.openURL(url);
      })
      .catch(err => toastShort('The phone does not support dialing function!'));

  }


  clickCallWhatapp(){



    if (!this.state.service_location || !this.state.service_location.whatapp  || this.state.service_location.whatapp.length == 0) {

      return;

    }



         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Do you want to chat with {this.state.service_location ? this.state.service_location.whatapp : ''}</Text>


                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickPhonePopCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickWhatAppPopConfirm.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Sure</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                          </View>

                          
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }


  clickWhatAppPopConfirm(){


    this.coverLayer.hide();

    const url = 'whatsapp://send?text=hello&phone=' + '65' + this.state.service_location.whatapp;
    Linking.canOpenURL(url)
      .then(supported => {
        if (!supported) {
            toastShort('You are not installed Whatapp!');
        }
        return Linking.openURL(url);
      })
      .catch(err => toastShort('You are not installed Whatapp!'));



  }





  cardCancelBooking(){


    if (this.state.service.status == '1' || this.state.service.status == '2') {

       return(

            <TouchableOpacity style = {{width:'100%'}}  
                activeOpacity = {0.8 }
                onPress={this.clickCancelBooking.bind(this)}>

                 <Text style = {styles.text_cancel_booking}>Cancel Booking</Text> 

            </TouchableOpacity>         

       );

    }else {

      return (<View/>);


    }

  }


  clickCancelBooking(){


    // 判断是否是 48 小时内取消

    if (this.state.service && this.state.service.therapy_start_date) {


      var now = new Date();

      if (DateUtil.getTimeMilliseconds(this.state.service.therapy_start_date)  - now.getTime() >= 48*60*60*1000) {

        // 48小时外，直接确认取消

        this.showCancelCountPopup(undefined);

      }else {

        //48小时内，

        this.getClientCanceCount();


      }


    }

  }

  getClientCanceCount(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientCancelCount id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<clientId i:type="d:string">359459</clientId>'+
     '</n0:getClientCancelCount></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('client','getClientCancelCountResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1 && json.data ) {
            // 当天有
           temporary.showCancelCountPopup(json.data.cancel_count);

        }

    });      

  }



  showCancelCountPopup(cancel_count){

    var title = '';

    if (cancel_count != undefined) {

      title = 'Your cancellation is less than 48 hours from the scheduled appointment. You have ' + cancel_count + ' late cancellation(s), your in app booking privillages will be suspended after performing 3 late cancellations. '

    }




         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Are you sure you want to cancel?</Text>


                          <Text style = {styles.text_popup_content}>{title}</Text>



                           <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickCancel48.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Back</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickConfirm48.bind(this)}>

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



  clickCancel48(){

    this.coverLayer.hide()

  }

  clickConfirm48(){

    this.coverLayer.hide();

    this.cancelAppointments(1);

  }

  cancelAppointments(isReach){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:cancelAppointments id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<startDate i:type="d:string">'+ this.state.service.therapy_start_date +'</startDate>'+
    '<isCancelUpcoming i:type="d:string">0</isCancelUpcoming>'+
    '<id i:type="d:string">'+ this.state.service.id +'</id>'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">isReach</key><value i:type="d:string">'+ isReach +'</value></item>'+
    '<item><key i:type="d:string">cancel_uid</key><value i:type="d:string">'+ this.state.userBean.id +'</value></item>'+
    '<item><key i:type="d:string">cancel_date</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
    '<item><key i:type="d:string">cancel_reason_id</key><value i:type="d:string">0</value></item>'+
    '<item><key i:type="d:string">remarks</key><value i:type="d:string">在手机端取消</value></item>'+
    '</data></n0:cancelAppointments>'+
    '</v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('booking-order','cancelAppointmentsResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1 ) {
            // 
             DeviceEventEmitter.emit('book_up','ok');
            temporary.cancelServiceSuccess();
        }else {

          toastShort('Network request failed！');
        }

    });      


  }


  cancelServiceSuccess(){
     this.props.navigation.goBack();
  }





  cardCheckIn(){



    if ((this.state.service.status == '1' || this.state.service.status == '2') && DateUtil.formatDateTime1() == DateUtil.parserDateString(this.state.service.therapy_start_date)) {

      return (
       <View style = {styles.next_view}>

            <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                activeOpacity = {  0.8 }
                onPress={this.clickCheckIn.bind(this,1)}>


                   <Text style = {styles.next_text}>Check In</Text>

            </TouchableOpacity>

        </View>


    );

    }else if ((this.state.service.status == '1' || this.state.service.status == '2') && DateUtil.formatDateTime1() != DateUtil.parserDateString(this.state.service.therapy_start_date)) {


    return (
       <View style = {styles.next_view}>

            <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#e0e0e0'}]}  
                activeOpacity = { 1 }
                onPress={this.clickCheckIn.bind(this,0)}>


                   <Text style = {styles.next_text}>Check In</Text>

            </TouchableOpacity>

        </View>


    );

       
    }else {

      return (<View/>); 

    }


  
  }



clickCheckIn(type){


  if (type == 1) {

      const { navigation } = this.props;
     if (navigation) {
      //扫码页面
      navigation.navigate('ScanQRCodeActivity',{
        'service':this.state.service,
        'type':0,
      });

    }
  }

}


serviceType(){



 if (this.state.service.status == '1' || this.state.service.status == '2') {


    return (

     <View style = {styles.view_service_type}>

         <View style = {styles.view_service_type}>


            <View style = {styles.view_service_type_item}>

                 <Text style = {styles.text_service_type}>Upcoming</Text>

            </View>
     
        </View>
                   
     
      </View>


    );

 }else if (this.state.service.status == '4') {


   return (

     <View style = {styles.view_service_type}>

         <View style = {styles.view_service_type}>


            <View style = {[styles.view_service_type_item,{backgroundColor:'#145A7C'}]}>

                 <Text style = {styles.text_service_type}>In Progress</Text>

            </View>
     
        </View>
                   
     
      </View>


    );




 }else {



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

                 
                  <Text style = {styles.text_service_title}>{this.state.service.alias_name}</Text>



                  {this.cardQueue()}


                  {this.cardTimeLocation()}


                  {this.cardNote()}


                  {this.cardConditions()}


                  {this.cardEnquiry()}


                  {this.cardCancelBooking()}


                  {this.cardCheckIn()}







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
    textAlign :'center',
    fontWeight: 'bold',
  },
  text_popup_content : {
    marginTop:24,
    width:'100%',
    color:'#333333',
    fontSize:14,
  }
});




