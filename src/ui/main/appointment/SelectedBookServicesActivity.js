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
  DeviceEventEmitter
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

import QueueView from '../../../widget/QueueView';

export default class SelectedBookServicesActivity extends Component {

    constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       client_id:undefined,
       code_company:undefined,
       wait_service_info:undefined,
     }
   }


   UNSAFE_componentWillMount(){

    var temporary = this;

    DeviceStorage.get('code_company').then((code_company) => {

      this.setState({
          code_company: code_company,
      });

      temporary.getWaitServiceInfo(code_company);
    }); 



     if (this.props && this.props.route && this.props.route.params) {

        this.setState({
            client_id:this.props.route.params.client_id,
        });

        this.getTClientPartInfo(this.props.route.params.client_id);

     }


   }


   getTClientPartInfo(client_id){


      if ( !client_id) {
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



  getWaitServiceInfo(code_company){


      if (code_company == undefined) {
        return;
      }


      var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
      '<v:Body><n0:getWaitServiceInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<startTime i:type="d:string">'+ DateUtil.formatDateTime1() + '</startTime>'+
      '<endTime i:type="d:string">'+ DateUtil.formatDateTime5(24*60*60*1000) +'</endTime>'+
      '<wellnessTreatType i:type="d:string">2</wellnessTreatType>'+
      '<locationId i:type="d:string">'+ code_company.id  +'</locationId></n0:getWaitServiceInfo></v:Body></v:Envelope>';
      var temporary = this;
      WebserviceUtil.getQueryDataResponse('booking-order','getWaitServiceInfoResponse',data, function(json) {

        
        if (json && json.success == 1  ) {

            // 当天有
             temporary.setState({
                wait_service_info:json.data,
             }); 

        }

    });      


    }





   addTreaTment(){
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

  
         // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                            <Text style = {[styles.text_popup_title]}>Wellness Appointment</Text>




                          <TouchableOpacity style = {styles.next_layout}  
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


                             <View style = {styles.view_wellness}>


                                <Image style = {{width:70,height:70,marginLeft:10,marginBottom:15}} 
                                      resizeMode = 'contain' 
                                      source={require('../../../../images/date_0802.png')}/> 



                                <Text style = {[styles.text_service_title,{marginLeft:40,marginTop:-10}]}>Select Date & Time</Text>      


                             </View> 

                           </View>  


                          </TouchableOpacity>    




                           <TouchableOpacity style = {styles.next_layout}  
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

            <View style = {styles.view_content}>

                <Text style = {styles.text_title}>Register new session for today at {this.state.code_company ? this.state.code_company.name : ''}</Text>


                <Text style = {styles.text_titme}>{DateUtil.getShowTimeFromDate0()}</Text>


                <TouchableOpacity style = {styles.next_layout}  
                    activeOpacity = {0.8}
                    onPress={this.addTreaTment.bind(this)}>


                  <View style = {styles.view_popup_item}>


                  <View style = {styles.popup_service_more_head}>


                    <Text style = {styles.text_service_title}>Treatment Services</Text>

                     <View style = {styles.popup_service_more}>


                           <Image style = {styles.image_icon} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/hei_more.png')}/>  


                     </View>


                  </View>



                  <Text style = {{marginTop:16,color:'#333',fontWeight:'bold',fontSize:13}}>Time</Text>


                  <Text style = {{marginTop:4,color:'#333',fontSize:14}}>{this.state.wait_service_info ? this.state.wait_service_info.queue_count : '0'} in Queue - Est.{this.state.wait_service_info ? this.state.wait_service_info.duration_mins : '0'} mins waiting time</Text>



                   <Text style = {{marginTop:16,color:'#333',fontWeight:'bold',fontSize:13}}>Description</Text>


                  <Text style = {styles.text_service_content}>Treating pain management such as bone, muscle and joints issues</Text>                        

               </View>  


              </TouchableOpacity> 



               <TouchableOpacity style = {styles.next_layout}  
                    activeOpacity = {0.8}
                    onPress={this.addWellness.bind(this)}>


                <View style = {[styles.view_popup_item,{marginBottom:64}]}>


                  <View style = {styles.popup_service_more_head}>


                    <Text style = {styles.text_service_title}>Wellness Services</Text>

                     <View style = {styles.popup_service_more}>

                           <Image style = {styles.image_icon} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/hei_more.png')}/>  


                     </View>


                  </View>


                   <Text style = {{marginTop:16,color:'#333',fontWeight:'bold',fontSize:13}}>Description</Text>


                  <Text style = {styles.text_service_content}>Rejuvenate your well being and experience a pampering time. Including specialised services for mothers</Text>                        

               </View>   


            </TouchableOpacity>        



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
  text_title:{
    color:'#145A7C',
    fontSize:24,
    fontWeight: 'bold',
  },
  text_titme:{
    marginTop:8,
    color:'#333333',
    fontSize:16,
  },
  next_layout:{
    width:'100%'
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
  text_service_title:{
    flex:1,
    width:'100%',
    color:'#145A7C',
    fontSize:16,
    fontWeight: 'bold',
  },
  popup_service_more:{
    borderRadius:8,
    width:24,
    height:24,
    backgroundColor:'#EE8F7B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_service_content:{
    marginBottom:12,
    marginTop:4,
    color:'#333',
    fontSize:14,
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
  xpop_cancel_confim:{
    marginTop:31,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_touch:{
     width:'48%',

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
  view_wellness:{
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  image_date_icon:{
    width:80,
    height:80,
  },
  image_icon:{
    width:5,
    height:8
  },
});

