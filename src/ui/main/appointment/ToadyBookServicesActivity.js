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

import Swiper from 'react-native-swiper';

import {Card} from 'react-native-shadow-cards';

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


let {width, height} = Dimensions.get('window');


export default class ToadyBookServicesActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       client_id:undefined,
       code_company:undefined,
       today_book_services:[],
     }
   }


   UNSAFE_componentWillMount(){

    var temporary = this;
    var userBean = undefined;
    var client_id = undefined;


     if (this.props && this.props.route && this.props.route.params && this.props.route.params.client_id) {

        client_id = this.props.route.params.client_id;

        this.getTClientPartInfo(client_id);


        DeviceStorage.get('code_company').then((code_company) => {

            temporary.setState({
                code_company: code_company,
            });

            temporary.getClientLocationBookedServices(client_id,code_company.id);
           
              
        }); 

     }else  {

        DeviceStorage.get('UserBean').then((user_bean) => {

         if (user_bean != undefined) {

            this.setState({
                userBean: user_bean,
            });

            DeviceStorage.get('code_company').then((code_company) => {

              temporary.setState({
                  code_company: code_company,
              });

              temporary.getClientLocationBookedServices(user_bean.id,code_company.id);

            }); 

         } 

        });
     }
   }


   getTClientPartInfo(client_id){


      if (client_id == undefined) {
        return;
      }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ client_id+'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {

        if (json && json.success == 1 && json.data ) {

            DeviceStorage.save('UserBean',json.data);
        }

    });

  }

  // 扫码登陆时，获取当天有没有预约
  getClientLocationBookedServices(client_id,code_company_id){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header /><v:Body>'+
    '<n0:getClientLocationBookedServices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<date i:type="d:string">'+ DateUtil.formatDateTime1() +'</date>'+
    '<clientId i:type="d:string">' + client_id +'</clientId>'+
    '<locationId i:type="d:string">'+ code_company_id +'</locationId>'+
    '</n0:getClientLocationBookedServices></v:Body></v:Envelope>';
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('booking-order','getClientLocationBookedServicesResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {

            temporary.setState({
              today_book_services:json.data,
              client_id:client_id,
            });  
              
        }     
    });

  }


  _todayBookServicesView(){


    if (this.state.today_book_services && this.state.today_book_services.length > 0) {

       var pages = [];


       for (var i = 0; i < this.state.today_book_services.length; i++) {
            
            var service =  this.state.today_book_services[i];


            pages.push(

              <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8,height:180}} >

                  <View style = {styles.view_swiper}>

                      <Text style = {styles.text_swiper_title}>{service.alias_name ? service.alias_name : service.name}</Text>

                      <Text style = {[styles.text_swiper_title,{marginTop:16,fontSize:13}]}>Time</Text>

                      <Text style = {styles.text_swiper_time}>{DateUtil.getShowHMTime2(service.therapy_start_date)}</Text>



                      {this._serviceViewdata(service)}

                      
                  </View>


              </Card>

            );


       }


       return (

        <View style = {{width:'100%',marginTop:32,height:200}}>

            <Swiper
           
              loop={false}  
              height={200}
              index = {this.state.page}
              showsPagination={true} 
              paginationStyle={{bottom:-10}}
              autoplay={false} 
              horizontal={true}
              dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
              activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#FFFFFF'}]}></View>}
               >


              {pages}
            
        

           </Swiper>   
           

          

        </View>);





    }else {


      return (<View />);

    }

  }


  _serviceViewdata(service){


    if (service.status == '1' || service.status == '2' || !service.filled_health_form) {

      return (

        <TouchableOpacity 
            activeOpacity = {0.8}
            onPress={this.clickService.bind(this,service)}>

             <View style = {styles.view_swiper_check_in}>

                  <Text style = {styles.text_check_in}>Check In</Text>

             </View>

        </TouchableOpacity>                  

      );


    }else {


      return (<View />);


    }


  }


  clickService(service){

    const { navigation } = this.props;
     if (navigation) {

      //扫码页面
      navigation.navigate('CheckInConfirmBookActivity',{
        'service':service
      });
    }

  }


  addBook(){

       // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                            <Text style = {[styles.text_popup_title]}>Select the type of Service</Text>




                          <TouchableOpacity style = {styles.view_add_item}  
                                activeOpacity = {0.8}
                                onPress={this.addTreaTment.bind(this)}>


                              <View style = {styles.view_popup_item}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}>Treatment</Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                              <Text style = {styles.text_service_content}>Treating pain management such as bone, muscle and joints issues</Text>                        

                           </View>  


                          </TouchableOpacity>    




                           <TouchableOpacity style = {styles.view_add_item}  
                                activeOpacity = {0.8}
                                onPress={this.addWellness.bind(this)}>


                            <View style = {[styles.view_popup_item,{marginBottom:64}]}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}>Wellness</Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                              <Text style = {styles.text_service_content}>Rejuvenate your well being and experience a pampering time. Including specialised services for mothers</Text>                        

                           </View>   


                        </TouchableOpacity>        

                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);

  }


   addTreaTment(){

    this.coverLayer.hide();


          // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Share more about your condition?</Text>



                          <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickTreaTmentSkip.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Skip</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickTreaTmentYes.bind(this)}>

                                <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#fff'}]}>Yes</Text>

                              </View>

                            </TouchableOpacity>   

                                                   
                        </View>                     
     
                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }


  clickTreaTmentSkip(){

     this.coverLayer.hide();

     const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('BookAppointmentActivity',{
          'select_type':0,
        });
    }
     

  }


  clickTreaTmentYes(){

    this.coverLayer.hide();


    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('TellUsCondition1Activity');
    }


  }

   addWellness(){

    this.coverLayer.hide();


         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                            <Text style = {[styles.text_popup_title]}>Wellness Appointment</Text>




                          <TouchableOpacity style = {styles.view_add_item}  
                                activeOpacity = {0.8}
                                onPress={this.addWellnessToDate.bind(this)}>


                              <View style = {styles.view_popup_item}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}></Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                             <View style = {[styles.view_wellness]}>


                                <Image style = {{width:70,height:70,marginLeft:10,marginBottom:15}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../../images/date_0802.png')}/> 



                                <Text style = {[styles.text_service_title,{marginLeft:40,marginTop:-10}]}>Select Date & Time</Text>      


                             </View> 

                           </View>  


                          </TouchableOpacity>    




                           <TouchableOpacity style = {styles.view_add_item}  
                                activeOpacity = {0.8}
                                onPress={this.addWellnessToTherapist.bind(this)}>


                            <View style = {[styles.view_popup_item,{marginBottom:64}]}>


                              <View style = {styles.popup_service_more_head}>


                                <Text style = {styles.text_service_title}></Text>

                                 <View style = {styles.popup_service_more}>


                                       <Image style = {styles.image_icon} 
                                          resizeMode = 'contain' 
                                          source={require('../../../../images/hei_more.png')}/>  


                                 </View>


                              </View>


                               <View style = {[styles.view_wellness,{marginTop:-10}]}>


                                <Image style = {{width:90,height:90,marginTop:-10}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../../images/graphic_app_therapist.png')}/> 



                                <Text style = {[styles.text_service_title,{marginLeft:26,marginBottom:8}]}>Select a Therapist</Text>      


                             </View>                     

                           </View>   


                        </TouchableOpacity>        

                          

                   </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);




  }

  addWellnessToDate(){

    this.coverLayer.hide();


    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('BookAppointmentActivity',{
          'select_type':1,
        });
     
    }

  }

  addWellnessToTherapist(){

    this.coverLayer.hide();

    const { navigation } = this.props;
    
    if (navigation) {
      navigation.navigate('BookAppointmentActivity',{
          'select_type':2,
        });
     
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


              <View style = {[styles.afearea,{padding:24}]}>


                  <Text style = {styles.text_loaction}>Check in today's session at {this.state.code_company ? this.state.code_company.name : ''}</Text>


                  <Text style = {styles.text_time}>{DateUtil.getShowTimeFromDate0()}</Text>


                  {this._todayBookServicesView()}


              

              </View>


              <View style = {styles.view_content}>


                <Image style = {{ width: 53,height: 53,marginTop:0}} 
                    resizeMode = 'contain' 
                    source={require('../../../../images/0125_date.png')}/>


               <Text style = {styles.text_content}>Get a queue spot today when checking in for a new session</Text>



                <View style = {styles.next_view}>

                    <TouchableOpacity style = {[styles.next_layout]}  
                          activeOpacity = {0.8}
                          onPress={this.addBook.bind(this)}>


                      <Text style = {styles.next_text}>Register New Session</Text>

                    </TouchableOpacity>


                </View>     



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
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_loaction:{
    color:'#FFFFFF',
    fontSize:24,
    fontWeight: 'bold',
  },
  text_time:{
    marginTop:8,
    color:'#FFFFFF',
    fontSize:16,
  },
  text_content:{
    marginTop:22,
    width:'100%',
    color:'#333333',
    fontSize:16,
    textAlign :'center',
  },
  next_layout:{
    marginTop:16,
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
    marginBottom:24,
    width:'100%',
    height:44,
  },
  view_swiper:{
    flex:1,
    padding:16
  },
  text_swiper_title:{
    color:'#145A7C',
    fontSize:16,
    fontWeight: 'bold',
  },
  text_swiper_time:{
    color:'#333333',
    fontSize:16,
  },
  view_swiper_check_in:{
    marginTop:16,
    width:'100%',
    height:44,
    backgroundColor:'#FAF3EB',
    borderRadius:16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_check_in:{
    color:'#C44729',
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
  image_icon:{
    width:5,
    height:8
  },
  view_add_item:{
     width:'100%'
  },
  text_service_title:{
    flex:1,
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    fontWeight: 'bold',
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
  image_date_icon:{
    width:80,
    height:80,
  },
  view_wellness:{
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },

  indicator_item:{
      width:24,
      height:4,
      backgroundColor:'#000000',
      borderRadius: 50,
      marginLeft:4,
  },

});

