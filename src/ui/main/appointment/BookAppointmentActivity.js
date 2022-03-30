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

let nativeBridge = NativeModules.NativeBridge;

export default class BookAppointmentActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       selsected_outlet:undefined,
       selsected_service:undefined,
       selsected_therapist:undefined,
       selsected_date:undefined,
       selsected_time_slot:undefined,
       selsected_additional_note:undefined,
       isOneChecked:true,
       select_type:0, //0:看诊 1：服务（日期）2：服务（人员）
       userBean:undefined,
       services:undefined,
       employees:undefined,
       year:undefined,
       month:undefined,
       date_data:undefined,
       duty_dates:undefined,
       time_slots:undefined,
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
    if (this.props && this.props.select_type) {
      
      this.setState({
        select_type:this.props.select_type,
      });


      if (this.props.select_type && this.props.select_type == 1) {

           this.getBusiness();
      }

    }else {
     
      // if (this.props) {
      //   this.setState({
      //     select_type:this.props.select_type,
      //   });
      //   this.getBusiness();
      //   return;
      // }
      this.setState({
        select_type:this.props.route.params.select_type,
      });


      if (this.props.route.params.select_type && this.props.route.params.select_type == 1) {

           this.getBusiness();
      }
    }

   
  }


  getBusiness(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getBusiness id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';
    Loading.show();
    nativeBridge.log('getBusiness');
    var temporary = this;
    WebserviceUtil.getQueryDataResponse('employee','getBusinessResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data ) {
          
            var person = {};
            person.employee_id = json.data.id;

            temporary.setState({
               selsected_therapist:person,   

            });
        }else {
          toastShort('Failed to get the information of the person on duty. You may not be able to make an appointment！');
        } 


    });


  }



  clickSelectedOutlet(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getCanOnlineBookingLocations id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<pId i:type="d:string">'+ this.state.head_company_id + '</pId>'+
    '</n0:getCanOnlineBookingLocations></v:Body></v:Envelope>';
    Loading.show();
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('company','getCanOnlineBookingLocationsResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {
           
              if (json.data && json.data.length > 0) {
                  temporary.showSelectedOulet(json.data);
              }else {
                toastShort('No suitable Outlet！');
              }
         
        }else {
          toastShort('Network request failed！');
        } 


    });


  }

  showSelectedOulet(data){

     // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Outlet</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._outlet_renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={data}/>

                         


                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }


  _outlet_renderItem = (item) => {


      return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.selectedOutlet.bind(this,item)}>

          <Text style = {styles.text_popup_content}>{item.item.alias_name ? item.item.alias_name : item.item.name}</Text>


          <View style = {styles.view_item_line}/>


        </TouchableOpacity>  

      );

  }

  selectedOutlet(item){
    this.coverLayer.hide();


    if (this.state.select_type == 1) {

       // 服务日期的人员为默认员工，不进行重置
        this.setState({
          selsected_outlet:item.item,
          selsected_service:undefined,
          selsected_date:undefined,
          selsected_time_slot:undefined,
    });


    }else  {

        this.setState({
          selsected_outlet:item.item,
          selsected_service:undefined,
          selsected_therapist:undefined,
          selsected_date:undefined,
          selsected_time_slot:undefined,
        });

    }

   

    //
    this.getServicesByLocation(item.item);

  }


  getServicesByLocation(outlet){

      var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getServicesByLocation id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<gender i:type="d:string">'+this.state.userBean.gender +'</gender>'+
      '<isWellness i:type="d:string">'+(this.state.select_type == 0 ? '2' : '1')+ '</isWellness>'+
      '<locationId i:type="d:string">'+ outlet.id + '</locationId>'+
      '</n0:getServicesByLocation></v:Body></v:Envelope>';
      var temporary = this;
      
      Loading.show();
      WebserviceUtil.getQueryDataResponse('schedule','getServicesByLocationResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data) {

              temporary.setState({
                services:json.data
              });


            if (json.data.length == 1) {

                temporary.setState({
                  selsected_service:json.data[0],
                });

            }
        }else {
          temporary.setState({
              services:undefined
          });

        }


    });      

    
  }

  clickSelectedService(){


    if (this.state.selsected_outlet) {


      if (this.state.services && this.state.services.length > 0) {

          this.showSelectedService(this.state.services);

      }else {
        toastShort('No suitable Service');
      }
    }else {
        toastShort('Please select a outlet');
    }

  }

  showSelectedService(data){

      // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Service</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._sevice_renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={data}/>

                         


                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


  }

  _sevice_renderItem = (item) => {


      return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.selectedService.bind(this,item)}>

          <Text style = {styles.text_popup_content}>{item.item.alias_name}</Text>


          <View style = {styles.view_item_line}/>


        </TouchableOpacity>  

      );

  }


selectedService(item){

   this.coverLayer.hide();



   if (this.state.select_type == 2) {


    this.setState({
      selsected_service:item.item,
      selsected_therapist:undefined,
      selsected_date:undefined,
      selsected_time_slot:undefined,
    });


    // 自动获取人员
    this.getEmployeeForService(item.item.id);


   }else {

    this.setState({
      selsected_service:item.item,
      selsected_date:undefined,
      selsected_time_slot:undefined,
    });

   }

    

}


getEmployeeForService(service_id){


  var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getEmployeeForService id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<gender i:type="d:string">'+ this.state.userBean.gender + '</gender>'+
  '<serviceId i:type="d:string">'+ service_id +'</serviceId>'+
  '<locationId i:type="d:string">'+ this.state.selsected_outlet.id+'</locationId>'+
  '</n0:getEmployeeForService></v:Body></v:Envelope>';
  var temporary = this;

  Loading.show();
  nativeBridge.log('getEmployeeForService');
  WebserviceUtil.getQueryDataResponse('schedule','getEmployeeForServiceResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data) {

              temporary.setState({
                employees:json.data
              });


            if (json.data.length == 1) {

                temporary.setState({
                  selsected_therapist:json.data[0],
                });

            }
        }else {
          temporary.setState({
              employees:undefined
          });

        }


    });      


}


clickSelectedTherapist(){



  if (this.state.selsected_outlet) {

    if (this.state.selsected_service) {


        if (this.state.employees && this.state.employees.length > 0) {

            this.showSelectedTherapist(this.state.employees);  

        }else {

            toastShort('No suitable therapist');
        }

    }else {

        toastShort('Please select a service');
    }
  }else {
      
       toastShort('Please select a outlet');

  }

}


showSelectedTherapist(data){


    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Therapist</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._therapist_renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={data}/>

                         


                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



}



_therapist_renderItem = (item) => {


      return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.selectedTherapist.bind(this,item)}>

          <Text style = {styles.text_popup_content}>{item.item.employee_name}</Text>


          <View style = {styles.view_item_line}/>


        </TouchableOpacity>  

      );

  }


  selectedTherapist(item){

    this.coverLayer.hide();
    this.setState({
      selsected_therapist:item.item,
      selsected_date:undefined,
      selsected_time_slot:undefined,
    });



  }

  clickSelectedDate(){



    if (this.state.selsected_outlet) {


      if ( this.state.select_type == 0) {

          if (this.state.selsected_service) {

            this.getDocSchedulesForService();

          }else {
             toastShort('Please select a service');
          }

      }else {

        if (this.state.selsected_therapist) {

          this.getEmployeeDutyDates();

        }else {
          toastShort('Please select a therapist');
        }

      }
    }else {
        toastShort('Please select a outlet');
    }


  }


  getDocSchedulesForService(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getDocSchedulesForService id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<serviceId i:type="d:string">'+ this.state.selsected_service.id +'</serviceId>'+
    '<locationId i:type="d:string">'+ this.state.selsected_outlet.id +'</locationId>'+
    '</n0:getDocSchedulesForService></v:Body></v:Envelope>';
    var temporary = this;
    Loading.show();
    nativeBridge.log('getDocSchedulesForService');
    WebserviceUtil.getQueryDataResponse('schedule','getDocSchedulesForServiceResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data && json.data.length > 0) {

              temporary.setState({
                duty_dates:json.data
              });

              temporary.showSelectedDatePopup();

        }else {
          
           toastShort('There is no right date!');

        }


    });      


  }


  getEmployeeDutyDates(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getEmployeeDutyDates id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<employeeId i:type="d:string">'+ this.state.selsected_therapist.employee_id + '</employeeId>'+
    '<locationId i:type="d:string">'+ this.state.selsected_outlet.id + '</locationId>'+
    '</n0:getEmployeeDutyDates></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    nativeBridge.log('getEmployeeDutyDates');
    WebserviceUtil.getQueryDataResponse('schedule','getEmployeeDutyDatesResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data && json.data.length > 0) {

              temporary.setState({
                duty_dates:json.data
              });

              temporary.showSelectedDatePopup();

        }else {
          
           toastShort('There is no right date!');

        }


    });      


  }


  showSelectedDatePopup(){


    var year = parseInt(DateUtil.formatDateTime3(new Date().getTime() / 1000));
    var month = parseInt(DateUtil.formatDateTime4(new Date().valueOf() / 1000));

    this.setState({
      year:year,
      month:month,
    });


    var days = DateUtil.getDaysfromYearMonth(year,month);

    // 1 号是星期几
    var week = DateUtil.getWeek(year + '-' + (month >= 10 ? month : '0' + month) + '-01');


    var data = [];


    for (var i = 1; i < week; i++) {
        data.push('');
    }

    for (var i = 0; i < days; i++) {
        data.push((i+1) + '');
    }

    var yu = data.length % 7;


    if (yu == 0) {
      yu = 0;
    }else {
      yu = (7 - yu);
    }  

    for (var i = 0; i < yu; i++) {
        data.push('');
    }


    this.setState({
      date_data:data,
    });


      // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Date</Text>



                          <View  style = {[styles.view_line,{marginTop:16}]}/>


                          <View style = {styles.view_week}>


                              <TouchableOpacity 
                                activeOpacity = {0.8}
                                onPress = {this.dateNextOrMonth.bind(this,'up')}>

                                 <Image style = {styles.image_next} 
                                   resizeMode = 'contain' 
                                   source={require('../../../../images/zuo.png')}/>


                              </TouchableOpacity>


                              <Text style = {styles.text_month_title}>{DateUtil.getENfromMoth2(this.state.month)}</Text>



                              <TouchableOpacity
                                activeOpacity = {0.8}
                                onPress = {this.dateNextOrMonth.bind(this,'next')}>

                                 <Image style = {styles.image_next} 
                                   resizeMode = 'contain' 
                                   source={require('../../../../images/you.png')}/>


                              </TouchableOpacity>

                          </View>



                          <View style = {styles.view_week2}>


                            <Text style = {styles.text_month}>MON</Text>

                            <Text style = {styles.text_month}>TUE</Text>

                            <Text style = {styles.text_month}>WED</Text>

                            <Text style = {styles.text_month}>THU</Text>

                            <Text style = {styles.text_month}>FRI</Text>

                            <Text style = {styles.text_month}>SAT</Text>

                            <Text style = {styles.text_month}>SUN</Text>


                          </View>


                          <FlatList
                              style = {[styles.flat_popup,{marginTop:16,marginBottom:32}]}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._date_renderItem}
                              numColumns = {7}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={this.state.date_data}/>

                         
                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);

  }


  dateNextOrMonth(type){


     var year = this.state.year;
     var month = this.state.month;


    if (type == 'next') {

      if (month == 12) {

          month = 1;
          year = year + 1;

      }else {
        month = month + 1;
      }


    }else {


        if (month == 1) {

          month = 12;
          year = year -1;

        }else {

          month = month - 1;

        }
    }

    var days = DateUtil.getDaysfromYearMonth(year,month);

    // 1 号是星期几
    var week = DateUtil.getWeek(year + '-' + (month >= 10 ? month : '0' + month) + '-01');

  
    var data = [];


    for (var i = 1; i < week; i++) {
        data.push('');
    }

    for (var i = 0; i < days; i++) {
        data.push((i+1) + '');
    }

    var yu = data.length % 7;


    if (yu == 0) {
      yu = 0;
    }else {
      yu = (7 - yu);
    }  

    for (var i = 0; i < yu; i++) {
        data.push('');
    }

    this.setState({
      year:year,
      month:month,
      date_data:data,
    });

  }

  _date_renderItem = (item) => {


      return (

        <TouchableOpacity
          style = {styles.view_date_item}
          activeOpacity = {0.8}
          onPress = {this.selectedDate.bind(this,item)}>

        
        {this.dateItem(item)}

         
        </TouchableOpacity>  

      );

  }



  selectedDate(item){


    if (item.item != '') {

       var day = parseInt(item.item);

       var month = this.state.month;

      var str_date = this.state.year + '-' + (month >= 10 ? month : '0' + month) + '-' + (day >= 10 ? day : '0' + day);

      var is_in_duty_date = false;

      var employee_id = undefined;

       for (var i = 0; i < this.state.duty_dates.length; i++) {
         
          if (str_date == this.state.duty_dates[i].w_date) {
            is_in_duty_date = true;
            employee_id = this.state.duty_dates[i].employee_id;
            break;
          }
       }


       if (is_in_duty_date) {

        if (this.state.select_type == 0) {

          var person = {};
          person.employee_id = employee_id;

          this.setState({
            selsected_therapist:person,
            selsected_date:str_date,
            selsected_time_slot:undefined,
          });

        }else {

          this.setState({
            selsected_date:str_date,
            selsected_time_slot:undefined,
          });
         
       }

       this.coverLayer.hide();

      }
      
    } 

  }


  dateItem(item){


    if (item.item == '') {

      return (
          <View style = {[styles.view_date_item_1,{backgroundColor:'#FFFFFF'}]}>

             <Text style = {styles.text_date_item}>{item.item}</Text>

          </View>
      );
        
    
    }else {


       var day = parseInt(item.item);

       var month = this.state.month;

       var str_date = this.state.year + '-' + (month >= 10 ? month : '0' + month) + '-' + (day >= 10 ? day : '0' + day);


       var is_today = (DateUtil.formatDateTime1() == str_date);

       var is_in_duty_date = false;


       for (var i = 0; i < this.state.duty_dates.length; i++) {
         
          if (str_date == this.state.duty_dates[i].w_date) {
            is_in_duty_date = true;
            break;
          }
       }



       return (
          <View style = {[styles.view_date_item_1,{backgroundColor:is_today ? '#C44729' : '#FFFFFF'}]}>

             <Text style = {[styles.text_date_item,{color:is_in_duty_date ? '#333333' : '#828282'}]}>{item.item}</Text>

          </View>
        );

    }

  }


  clickSelectedTime(){


    if (this.state.selsected_outlet) {


      if (this.state.selsected_service) {

         if (this.state.selsected_therapist || this.state.select_type == 0) {


            if (this.state.selsected_date) {

                this.getBookingTimeSlots();

            }else {
               toastShort('Please select a date');
            }
        }else {
            toastShort('Please select a therapist');
        }

      }else {
         toastShort('Please select a service');
      }

    }else {
        toastShort('Please select a outlet');
    }


  }


  getBookingTimeSlots(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getBookingTimeSlots id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<isWellness i:type="d:string">1</isWellness>'+
    '<serviceId i:type="d:string">'+ this.state.selsected_service.id +'</serviceId>'+
    '<date i:type="d:string">'+ this.state.selsected_date +'</date>'+
    '<employeeId i:type="d:string">'+ this.state.selsected_therapist.employee_id + '</employeeId>'+
    '<locationId i:type="d:string">'+ this.state.selsected_outlet.id + '</locationId>'+
    '</n0:getBookingTimeSlots></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    nativeBridge.log('getBookingTimeSlots');
    WebserviceUtil.getQueryDataResponse('schedule','getBookingTimeSlotsResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data && json.data.length > 0) {

              temporary.setState({
                time_slots:json.data
              });

              temporary.showSelectedTimePopup(json.data);

        }else {
          
           toastShort('There is no right time!');

        }


    });      



  }


clickNoSee(){

   // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Time Slot</Text>

                          
                          <Text style = {{color:'#333333',fontSize:16,marginTop:32}}>Please speak to our staff for assistance in arranging a suitable timing. Alternatively you may arrange to see us on later date.</Text>

                          <Text style = {{color:'#C44729',fontSize:16,fontWeight:'bold',marginTop:16}}>If you require immediate medical attention, alert our staff of your condition, so that they may advise on the next course of action.</Text>  



                          <View style = {[styles.next_view,{width:'100%',marginBottom:64}]}>

                              <TouchableOpacity style = {[styles.next_layout,{backgroundColor: '#C44729' }]}  
                                  activeOpacity = {0.8}
                                  onPress={this.clickContactUs.bind(this)}>


                                <Text style = {styles.next_text}>Contact Us</Text>

                              </TouchableOpacity>

                          </View>

                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);


}


clickContactUs(){

  this.coverLayer.hide();
  //
  nativeBridge.openNativeVc("ContactUsViewController",null);

}




showSelectedTimePopup(data){

    // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {styles.text_popup_title}>Select Time Slot</Text>

                          <FlatList
                              style = {styles.flat_popup}
                              ref = {(flatList) => this._flatList = flatList}
                              renderItem = {this._time_renderItem}
                              onEndReachedThreshold={0}
                              keyExtractor={(item, index) => index.toString()}
                              data={data}/>

                         


                        </View>
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



}


_time_renderItem = (item) =>{


   return (

        <TouchableOpacity
          activeOpacity = {0.8}
          onPress = {this.selectedTimeSlot.bind(this,item)}>

          <Text style = {styles.text_popup_content}>{DateUtil.getShowHMTime(item.item)}</Text>


          <View style = {styles.view_item_line}/>


        </TouchableOpacity>  

      );



}


selectedTimeSlot(item){

   this.coverLayer.hide();
   this.setState({
    selsected_time_slot:item.item,

   });



}


  clickSelected(){

  }


  clickConfim(){

    if (this.state.selsected_outlet && this.state.selsected_service && this.state.selsected_therapist && this.state.selsected_date && this.state.selsected_time_slot) {


      Loading.show();
      if (this.state.select_type == 1 || this.state.select_type == 2) {

        this.checkCanBookService();

      }else {

        if (this.state.select_type  == 0) {

            this.checkConsulted();

        }else {

            this.checkCanBookService();
        }

      }
    }

  }


  checkConsulted(){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:checkConsulted id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<date i:type="d:string">'+ this.state.selsected_date +'</date>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '<locationId i:type="d:string">'+ this.state.selsected_outlet.id +'</locationId>'+
    '</n0:checkConsulted></v:Body></v:Envelope>';


    var temporary = this;
    WebserviceUtil.getQueryDataResponse('booking-order','checkConsultedResponse',data, function(json) {

        if (json && json.success == 1 && json.data != 1) {

            // 可以进行预约
            temporary.checkCanBookService();
        }else {
          
            // 无法进行预约
             Loading.hidden();
            temporary.showErrorPopup();

        }


    });      

  }




  checkCanBookService(){


    var startTime = this.state.selsected_date + ' ' + this.state.selsected_time_slot + ':00';

    var endTime = DateUtil.formatDateTime0(DateUtil.transdate(startTime) + parseInt(this.state.selsected_service.duration) * 60 * 1000);


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:checkCanBookService id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<startTime i:type="d:string">'+ startTime +'</startTime>'+
    '<endTime i:type="d:string">'+ endTime +'</endTime>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:checkCanBookService></v:Body></v:Envelope>';
    var temporary = this;
  
    WebserviceUtil.getQueryDataResponse('booking-order','checkCanBookServiceResponse',data, function(json) {

        Loading.hidden();

        if (json && json.success == 1 && json.data == '0') {

            // 可以进行预约
            temporary.toConfirmBookActivity();
        }else {
          
            // 无法进行预约
            temporary.showErrorPopup();

        }


    });      


  }


  showErrorPopup(){

     // 根据传入的方法渲染并弹出

    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>

                          <Text style = {styles.text_popup_content}>Another appointment with a similar time slot has been created. Please select another day or time.</Text>
               
                        </View>
                       
                    )
                },
            ()=>this.coverLayer.hide(),
            CoverLayer.popupMode.bottom);



  }



  toConfirmBookActivity(){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'ConfirmBookActivity',property:{
        'selsected_outlet':this.state.selsected_outlet,
        'selsected_service':this.state.selsected_service,
        'selsected_therapist':this.state.selsected_therapist,
        'selsected_date':this.state.selsected_date,
        'selsected_time_slot':this.state.selsected_time_slot,
        'selsected_additional_note':this.state.selsected_additional_note,
        'select_type': this.state.select_type,
      }});
      return;
    }

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('ConfirmBookActivity',{
        'selsected_outlet':this.state.selsected_outlet,
        'selsected_service':this.state.selsected_service,
        'selsected_therapist':this.state.selsected_therapist,
        'selsected_date':this.state.selsected_date,
        'selsected_time_slot':this.state.selsected_time_slot,
        'selsected_additional_note':this.state.selsected_additional_note,
        'select_type': this.state.select_type,
      });
    }

  }


  serviceItem(){


    if (this.state.select_type == 1 || this.state.select_type == 2) {


        // 服务

       return (

            <TouchableOpacity                      
                  activeOpacity = {0.8}
                  onPress={this.clickSelectedService.bind(this)}>

                <View style = {styles.view_selecte_item}>


                  <View style = {styles.view_selecte_item_title}>


                      <Text style = {[styles.text_select_item_title,{color:this.state.selsected_service ? '#000000' : '#828282'}]}>{this.state.selsected_service ? this.state.selsected_service.alias_name : 'Select Service'}</Text>


                      <Image style = {styles.image_id_more} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/xia.png')}/>


                  </View>

                  <View style = {styles.view_line}/>

                </View> 

            </TouchableOpacity>
      );
 

    }else {


      // 看诊

      if (this.state.services && this.state.services.length >= 2 ) {

          return (
            <TouchableOpacity                      
                  activeOpacity = {0.8}
                  onPress={this.clickSelectedService.bind(this)}>

                <View style = {styles.view_selecte_item}>


                  <View style = {styles.view_selecte_item_title}>


                      <Text style = {[styles.text_select_item_title,{color:this.state.selsected_service ? '#000000' : '#828282'}]}>{this.state.selsected_service ? this.state.selsected_service.caption : 'Select Service'}</Text>


                      <Image style = {styles.image_id_more} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/xia.png')}/>


                  </View>

                  <View style = {styles.view_line}/>

                </View> 

            </TouchableOpacity>
          );


      }else {


        return (<View />);


      }





    } 
    

  }


  therapistItem(){



    if (this.state.select_type == 2) {


      return (

         <TouchableOpacity                      
                  activeOpacity = {0.8}
                  onPress={this.clickSelectedTherapist.bind(this)}>

                <View style = {styles.view_selecte_item}>


                  <View style = {styles.view_selecte_item_title}>


                      <Text style = {[styles.text_select_item_title,{color:this.state.selsected_therapist ? '#000000' : '#828282'}]}>{this.state.selsected_therapist ? this.state.selsected_therapist.employee_name : 'Select Therapist'}</Text>


                      <Image style = {styles.image_id_more} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/xia.png')}/>


                  </View>

                  <View style = {styles.view_line}/>

                </View> 

           </TouchableOpacity>

      );


    }else {


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
            title = {''} 
            navigation={navigation}
            hideLeftArrow = {true}
            hideRightArrow = {false}
            extraData={this.state}/>


         <View style = {styles.view_content}>

            <ScrollView style = {styles.scrollview}
              contentOffset={{x: 0, y: 0}}>


              <Text style = {styles.text_title}>Select by Preferred Slot</Text>




              <TouchableOpacity                      
                  activeOpacity = {0.8}
                  onPress={this.clickSelectedOutlet.bind(this)}>

                <View style = {styles.view_selecte_item}>


                  <View style = {styles.view_selecte_item_title}>


                      <Text style = {[styles.text_select_item_title,{color:this.state.selsected_outlet ? '#000000' : '#828282'}]}>{this.state.selsected_outlet ? (this.state.selsected_outlet.alias_name ? this.state.selsected_outlet.alias_name : this.state.selsected_outlet.alias_name) : 'Select Outlet'}</Text>


                      <Image style = {styles.image_id_more} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/xia.png')}/>


                  </View>

                  <View style = {styles.view_line}/>

                </View> 


              </TouchableOpacity>



              {this.serviceItem()}


              {this.therapistItem()}


              
               <TouchableOpacity                      
                  activeOpacity = {0.8}
                  onPress={this.clickSelectedDate.bind(this)}>

                <View style = {styles.view_selecte_item}>


                  <View style = {styles.view_selecte_item_title}>


                      <Text style = {[styles.text_select_item_title,{color:this.state.selsected_date ? '#000000' : '#828282'}]}>{this.state.selsected_date ? DateUtil.getShowTimeFromDate(this.state.selsected_date) :'Select Date'}</Text>


                      <Image style = {styles.image_id_more} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/xia.png')}/>


                  </View>

                  <View style = {styles.view_line}/>

                </View> 


              </TouchableOpacity>




               <TouchableOpacity                      
                  activeOpacity = {0.8}
                  onPress={this.clickSelectedTime.bind(this)}>

                <View style = {styles.view_selecte_item}>


                  <View style = {styles.view_selecte_item_title}>


                      <Text style = {[styles.text_select_item_title,{color:this.state.selsected_time_slot ? '#000000' : '#828282'}]}>{this.state.selsected_time_slot ? DateUtil.getShowHMTime(this.state.selsected_time_slot) : 'Select Time Slot'}</Text>


                      <Image style = {styles.image_rili_more} 
                        resizeMode = 'contain' 
                        source={require('../../../../images/rili.png')}/>


                  </View>

                  <View style = {styles.view_line}/>

                </View> 


              </TouchableOpacity>


              <View style = {styles.view_iparinput}>
                  <IparInput
                      valueText = {this.state.selsected_additional_note} 
                      placeholderText={'Additional Note'}
                      onChangeText={(text) => {
                        this.setState({selsected_additional_note:text})
                    }}/>

              </View>


              <View style = {styles.view_notic}>


                   <View style = {styles.view_checkbox}>
                      <CheckBox 
                          style={styles.checkbox} 
                          rightText={''}
                          rightTextStyle = {styles.text_foot_content}
                          onClick={()=>{
                            this.setState({
                              isOneChecked:!this.state.isOneChecked})
                          }}
                          isChecked={this.state.isOneChecked}
                          checkedCheckBoxColor = "#C44729"
                          uncheckedCheckBoxColor = "#C44729"/>   

                  </View>

                   <Text style = {styles.text_checkbox_content}>Sync with phone calendar</Text>

              </View>


              <View style = {styles.next_view}>

                  <TouchableOpacity style = {[styles.next_layout,{backgroundColor: (this.state.selsected_outlet && this.state.selsected_service && this.state.selsected_therapist && this.state.selsected_date && this.state.selsected_time_slot) ? '#C44729' : '#BDBDBD'}]}  
                      activeOpacity = {(this.state.selsected_outlet && this.state.selsected_service && this.state.selsected_therapist && this.state.selsected_date && this.state.selsected_time_slot) ? 0.8 : 1}
                      onPress={this.clickConfim.bind(this)}>


                    <Text style = {styles.next_text}>Confirm</Text>

                  </TouchableOpacity>

              </View>


             <TouchableOpacity
                  style = {styles.view_no_see} 
                  activeOpacity = {0.8}
                  onPress={this.clickNoSee.bind(this)}>
             
                <Text style = {styles.text_no_see}>Don't see your preferred slot?</Text>

             </TouchableOpacity>   


                          

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
  view_selecte_item :{
    width:'100%',
  },
  view_line:{
    marginTop:11,
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
  },
  view_selecte_item_title:{
    marginTop:28,
    flexDirection: 'row',
  },
  image_id_more:{
    marginTop:8,
    width:6,
    height:3,
  },
  image_rili_more:{
    width:15,
    height:15
  },
  text_select_item_title:{
    flex:1,
    fontSize:16,
  },
  view_notic :{
    marginTop:32,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'

  },
  text_checkbox_content:{
    fontSize:16,
    color:'#000000',
    marginLeft:8,
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
    marginTop:32
  },
  view_no_see:{
    marginTop:16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_no_see:{
    fontSize:14,
    color:'#C44729',
    fontWeight: 'bold',
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
   flat_popup:{
    marginTop:24,
    width:'100%'
  },
  text_popup_content:{
    width:'100%',
    marginTop:16,
    marginBottom:16,
    fontSize:16,
    color:'#333333'
  },
  view_item_line:{
    backgroundColor: "#E0E0E0",
    width: '100%',
    height: 1
  },
  view_date_item:{
    flex:1,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_date_item:{
    fontSize:16,
  },
  view_date_item_1:{
    borderRadius:40,
    width:40,
    height:40,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_week : {
    paddingLeft:8,
    paddingRight:8,
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  image_next:{
    width:8,
    height:13,
  },
  text_month_title:{
    fontSize:18,
    color:'#000000',
    fontWeight:'bold',
  },
   view_week2 : {
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    alignItems: 'center'
  },
  text_month:{
    flex:1,
    fontSize:13,
    color:'#BDBDBD',
    fontWeight:'bold',
     textAlign :'center'
  }
});
