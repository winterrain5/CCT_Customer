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
  NativeEventEmitter,
  NativeModules,
  RefreshControl
} from 'react-native';


import Swiper from 'react-native-swiper';


import CoverLayer from '../../../widget/xpop/CoverLayer';

import DeviceStorage from '../../../uitl/DeviceStorage';

import DateUtil from '../../../uitl/DateUtil';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';

import QueueView from '../../../widget/QueueView';

let {width, height} = Dimensions.get('window');
let nativeBridge = NativeModules.NativeBridge;

const { PushManager } = NativeModules;
const MyPushManager = (Platform.OS.toLowerCase() != 'ios') ? '' : new NativeEventEmitter(PushManager);


export default class HomeScreen extends Component {

   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       today_services:undefined,
       today_future_title:'Today‘s Session',
       page:0,
       page2:0,
       card_amount:0.00,
       blog_data:undefined,
       object:true,
       isRefreshing:false,
       new_blog_id:undefined,
    };

  }


  clickAddBook(){

    DeviceEventEmitter.emit('addBook','ok');

  }

  clickOpenMenu(){

    DeviceEventEmitter.emit('openMenu','ok');

  }



  bookService(){


    if (this.state.today_services && this.state.today_services.length > 0) {


      var pages = [];


      var card_height = 0;





      for (var i = 0; i < this.state.today_services.length; i++) {
         
         var service = this.state.today_services[i];


         if (DateUtil.formatDateTime1() != DateUtil.parserDateString(service.therapy_start_date)) {


            if (card_height < 200) {

              card_height = 200;

              if (service.staff_is_random == '2') {

                 card_height = 220;
              }

            }


            pages.push(


                 <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8,height: service.staff_is_random == '2' ? 200 : 180}} >


                  <TouchableOpacity
                      activeOpacity = {1}
                      onPress={this.clickItem.bind(this,service)}>



                     <View style = {[{height:'100%', backgroundColor:'#FFF'}]}>


                         <View style = {styles.view_service_head}>

                             <Text style = {styles.text_service_title}>{service.alias_name}</Text>

                         </View>


                        <View style = {styles.view_time_outle}>


                          <View style = {styles.view_item_item}>

                              <Image style = {styles.image_item} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/time.png')}/>


                              <Text style = {styles.text_item_content}>{DateUtil.getShowHMTime2(service.therapy_start_date)}</Text>

                          </View>


                          <View style = {styles.view_item_item}>


                             <Image style = {styles.image_item} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/home_date.png')}/>


                              <Text style = {styles.text_item_content}>{DateUtil.getShowTimeFromDate2(service.therapy_start_date)}</Text> 
                             
                          </View> 




                         <View style = {styles.view_item_item}>


                            <Image style = {styles.image_item} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/location.png')}/>


                             <Text style = {styles.text_item_content}>{service.location_name}</Text>

                          </View> 



                          {this._therapistView(service)}

                      
                        </View>

                     </View>

                   </TouchableOpacity>    

                 </Card>


              );




         } else if (service.queue_no && service.queue_no.trim().length > 0) {


            if (card_height < 270) {

              card_height = 270;

              if (service.staff_is_random == '2') {

                 card_height = 290;
              }

            }

            // 看诊排队阶段

             pages.push(


                 <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8,height: service.staff_is_random == '2' ? 260:240}} >


                  <TouchableOpacity
                      activeOpacity = {1}
                      onPress={this.clickItem.bind(this,service)}>



                     <View style = {[{height:'100%', backgroundColor:'#FFF'}]}>


                         <View style = {[styles.view_service_head,{flexDirection: 'row',}]}>


                            <View style = {{flex:1}}>

                               <Text style = {styles.text_service_title}>{service.alias_name}</Text>

                               <Text style = {[styles.text_service_title,{marginTop:4}]}>Queue No.</Text>

                            </View>


                            <Text style = {styles.text_time_title}>{service.queue_no}</Text>



                         </View>


                        <View style = {styles.view_time_outle}>


                          <View style = {styles.view_item_item}>

                              <Image style = {styles.image_item} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/time.png')}/>


                              <Text style = {styles.text_item_content}>{DateUtil.getShowHMTime2(service.therapy_start_date)}</Text>

                          </View>



                         <View style = {styles.view_item_item}>


                            <Image style = {styles.image_item} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/location.png')}/>


                             <Text style = {styles.text_item_content}>{service.location_name}</Text>

                          </View> 



                           <View style = {styles.view_item_item2}>


                             <Image style = {styles.image_item} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/home_gantan.png')}/>


                              <QueueView
                                service = {service}/>  
                             
                          </View> 


                          <Text style ={styles.text_item_content_hint}>Your number may not be called in sequence,we seek your understanding!</Text>



                        </View>

                     </View>

                   </TouchableOpacity>    

                 </Card>


              );






         }else if (service.status == '4' && service.filled_health_form) {

            //服务等待阶段


            if (card_height < 200) {

              card_height = 200;

              if (service.staff_is_random == '2') {

                 card_height = 220;
              }
              
            }

             pages.push(

                  <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8,height:service.staff_is_random == '2' ? 200 : 180}} >


                    <TouchableOpacity
                      activeOpacity = {1}
                      onPress={this.clickItem.bind(this,service)}>


                      <View style = {[{height:'100%', backgroundColor:'#FFF'}]}>


                         <View style = {styles.view_service_head}>

                              <Text style = {styles.text_service_title}>{service.alias_name}</Text>

                              <Text style = {styles.text_time_title}>{DateUtil.getShowHMTime2(service.therapy_start_date)}</Text>


                         </View>


                        <View style = {styles.view_time_outle}>


                            <View style = {styles.view_item_item}>


                               <Image style = {styles.image_item} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/location.png')}/>


                              <Text style = {styles.text_item_content}>{service.location_name}</Text>

                            </View> 


                            {this._therapistView(service)}  


                            <Text style = {styles.text_item_content_hint}>Your session timing may not necessarily start on time!</Text>


                        </View>


                      </View>


                    </TouchableOpacity>   

                 </Card>

              );

         }else {

            // 服务 Chinck in 阶段


             if (card_height <= 220) {

              card_height = 220;

              if (service.staff_is_random == '2') {

                 card_height = 240;
              }
                
            }

             pages.push(  
                <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8,height: service.staff_is_random == '2' ? 220 : 200}} >

                  <TouchableOpacity
                      activeOpacity = {1}
                      onPress={this.clickItem.bind(this,service)}>



                    <View style = {[{height:'100%', backgroundColor:'#FFF'}]}>


                      <View style = {styles.view_service_head}>


                          <Text style = {styles.text_service_title}>{service.alias_name}</Text>


                      </View>


                     <View style = {styles.view_time_outle}>

                        <View style = {styles.view_item_item}>


                          <Image style = {styles.image_item} 
                            resizeMode = 'contain' 
                            source={require('../../../../images/time.png')}/>


                           <Text style = {styles.text_item_content}>{DateUtil.getShowHMTime2(service.therapy_start_date)}</Text>

                        </View>


                        <View style = {styles.view_item_item}>


                           <Image style = {styles.image_item} 
                             resizeMode = 'contain' 
                            source={require('../../../../images/location.png')}/>


                          <Text style = {styles.text_item_content}>{service.location_name}</Text>

                        </View> 


                      {this._therapistView(service)} 

                  
                     </View>  


                      <View style = {styles.next_view_chinck_in}>

                          <TouchableOpacity style = {[styles.next_layout_chinck_in,{backgroundColor:'#C44729'}]}  
                              activeOpacity = {0.8 }
                              onPress={this.clickChinckIn.bind(this,service)}>


                              <Text style = {styles.next_text_chinck_in}>Check In</Text>

                          </TouchableOpacity>  

                       </View>

                    </View>

                   </TouchableOpacity>  

                </Card>  
              );

         }

      }


      return (

        <View style = {[styles.view_book_head]}>

           <View style = {[styles.view_book_head_title,{marginBottom:20,}]}>

             <Text style = {styles.text_book_title}>{this.state.today_future_title}</Text>


             <TouchableOpacity 
                  activeOpacity = {0.8 }
                  onPress={this.clickServiceViewAll.bind(this)}>

                   <Text style = {styles.text_view_all}>View All</Text>

             </TouchableOpacity>    


            

           </View> 


            <Swiper
              loop={false}  
              height={card_height}
              index = {this.state.page}
              showsPagination={true} 
              paginationStyle={{bottom: -10}}
              autoplay={false} 
              horizontal={true}
              dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
              activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
               >


              {pages}
            
        

           </Swiper>   
           

          

        </View>
      );



    }else {

      return (

        <View style = {styles.view_book_head}>

            <Text style = {styles.text_book_title}>{'Welcome,' + (this.state.userBean ? this.state.userBean.first_name + ' ' + this.state.userBean.last_name : '') }</Text>

            <Text style = {styles.text_book_content}>Start exploring our integrated healthcare app!</Text>

        </View>
      );

    }

  }


  _therapistView(service){


    if (service.staff_is_random == '2') {


      var therapist_name = '';

      if (service.employee_first_name) {

          therapist_name = service.employee_first_name;
      }

      if (service.employee_last_name) {
        if (therapist_name.length > 0) {
          therapist_name += (' ' + service.employee_last_name);
        }else {
          therapist_name += service.employee_last_name;
        }

      }
   
      if (therapist_name == '' || therapist_name.length == 0) {

        therapist_name = service.staff_name;

      }






      return (

          <View style = {styles.view_item_item}>


             <Image style = {styles.image_item} 
                resizeMode = 'contain' 
                source={require('../../../../images/person_0217.png')}/>


              <Text style = {styles.text_item_content}>{therapist_name}</Text> 
             
          </View> 

      );

    }else {

      return (<View />);

    }

  }




  clickServiceViewAll(){
    DeviceEventEmitter.emit('clickUseCenterItem','Appointments');
  }



  clickChinckIn(service){

     const { navigation } = this.props;
     if (navigation) {
      //扫码页面
      navigation.navigate('ScanQRCodeActivity',{
        'service':service,
        'type':0,
      });
    }
  }

  clickItem(service){


    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('BookDetailsActivity',{
        'service':service,
      });
    }


  }


  clickHomeQrCode(){

    const { navigation } = this.props;
     if (navigation) {

      //扫码页面
      navigation.navigate('ScanQRCodeActivity',{
        'service':undefined,
        'type':1,
      });

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

       this.getClientBookedServices(user_bean);


       // 获取用户金额
       this.getNewReCardAmountByClientId(user_bean);


       // 所有博客
      this.getAllBlogs(user_bean);


    });

  
  }


  _onRefresh(type){


      this.setState({
        isRefreshing:true,
        page:0,
        page2:0,
      })

      this.getTClientPartInfo(this.state.userBean.id);



      this.getClientBookedServices(this.state.userBean);


       // 获取用户金额
       this.getNewReCardAmountByClientId(this.state.userBean);


       // 所有博客
      this.getAllBlogs(this.state.userBean);

  }





    //注册通知
  componentDidMount(){
  
     var temporary = this;
    this.emit =  DeviceEventEmitter.addListener('book_up',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         temporary.getClientBookedServices(temporary.state.userBean);
     });

      this.emit1 =  DeviceEventEmitter.addListener('user_update',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           if (params) {
              temporary.setState({
                userBean: JSON.parse(params,'utf-8'),
               });
           }  
           
       });

      this.emit2 =  DeviceEventEmitter.addListener('user_update_home',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           if (params) {
              temporary.setState({
                userBean: JSON.parse(params,'utf-8'),
               });
           }  
           
       });
      
       this.emit3 =  DeviceEventEmitter.addListener('user_money_up',(params)=>{
              //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI


              temporary.getTClientPartInfo(temporary.state.userBean.id,true);

              temporary.getNewReCardAmountByClientId(temporary.state.userBean);
             
             
      });






     this.subscription = (Platform.OS.toLowerCase() != 'ios')?'':MyPushManager.addListener('BlogBookMarkStatus',(reminder) => {

        if (reminder != undefined) {

          
          // 当前修改的blog 类型， 0 ；取消收藏。1 ：加入收藏


         var blog_data =  temporary.state.blog_data;


        for (var i = 0; i < blog_data.length; i++) {


            if (blog_data[i].length >= 2) {

              if (blog_data[i][0].id == temporary.state.new_blog_id) {

                if (reminder == '0') {
                  blog_data[i][0].has_booked = false;
                }else {
                   blog_data[i][0].has_booked = true;
                }
                break;
              }

              if (blog_data[i][1].id == temporary.state.new_blog_id) {

                if (reminder == '0') {
                  blog_data[i][1].has_booked = false;
                }else {
                   blog_data[i][1].has_booked = true;
                }
                break;
              }



            }else {

               if (blog_data[i][0].id == temporary.state.new_blog_id) {

                if (reminder == '0') {
                  blog_data[i][0].has_booked = false;
                }else {
                   blog_data[i][0].has_booked = true;
                }
                break;
              }
            }

          }

          temporary.setState({
            blog_data:blog_data,
          });
          

        }
      
    });



  }

  componentWillUnmount(){

    this.emit.remove();
    this.emit1.remove();
    this.emit2.remove();
    this.emit3.remove(); 

  }



   getTClientPartInfo(client_id,type){


      if (client_id == undefined) {
        return;
      }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTClientPartInfo id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ client_id+'</clientId>'+
    '</n0:getTClientPartInfo></v:Body></v:Envelope>';
    var temporary = this;

    WebserviceUtil.getQueryDataResponse('client','getTClientPartInfoResponse',data, function(json) {

        if (json && json.success == 1 && json.data ) {

            temporary.setState({
              userBean:json.data,
            });

            DeviceStorage.save('UserBean',json.data);

            if (type == true) {
              DeviceEventEmitter.emit('user_update',JSON.stringify(json.data));
            }

            
        }

    });

  }








  getAllBlogs(userBean){



    if (!userBean) {
      return
    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header />'+
    '<v:Body><n0:getAllBlogs id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<filterKeys i:type="d:string"></filterKeys>'+
    '<companyId i:type="d:string">'+ this.state.head_company_id +'</companyId>'+
    '<isFeatured i:type="d:string">1</isFeatured>'+
    '<searchData i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap" />'+
    '<limit i:type="d:string">4</limit>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '<categoryId i:type="d:string">0</categoryId>'+
    '</n0:getAllBlogs></v:Body></v:Envelope>';

    var temporary = this;

    WebserviceUtil.getQueryDataResponse('blog','getAllBlogsResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {
            
            var blogs = [];
            var blog_chien = [];

            for (var i = 0; i < json.data.length; i++) {
             
                if (i % 2 == 0) {

                  if (blog_chien.length > 0) {
                      blogs.push(blog_chien);
                  }
                  blog_chien = [];

                }

                blog_chien.push(json.data[i]);

            }

            if (blog_chien.length > 0) {
              blogs.push(blog_chien);
            }

            temporary.setState({
              blog_data:blogs,
            });

        }else {
          temporary.setState({
              blog_data:[],
            });
        }

    });      

  }


// 获取用户金额
 getNewReCardAmountByClientId(userBean){

    if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewReCardAmountByClientId id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId></n0:getNewReCardAmountByClientId></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('voucher','getNewReCardAmountByClientIdResponse',data, function(json) {


         if (json && json.success == 1 && json.data) {

            temporary.setState({
              card_amount:StringUtils.toDecimal(json.data),
            });

         }

        

    });      

  }

  //获取当天的服务
  getClientBookedServices(userBean){


    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getClientBookedServices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<date i:type="d:string">'+ DateUtil.formatDateTime1() +'</date>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getClientBookedServices></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('booking-order','getClientBookedServicesResponse',data, function(json) {

        
        if (json && json.success == 1 && json.data && json.data.length > 0) {

            // 当天有
             temporary.setState({
                today_services:json.data,
                today_future_title:'Today‘s Session',
                isRefreshing:false,
             }); 

        }else {
           
           // 当天没有，获取将来
           temporary.getTUpcomingAppointments();


        }

    });      

  }


  // 获取将来预约
  getTUpcomingAppointments(){

      var  data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTUpcomingAppointments id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<length i:type="d:string">5</length>'+
      '<start i:type="d:string">0</start>'+
      '<clientId i:type="d:string">'+this.state.userBean.id+'</clientId>'+
      '<wellnessType i:type="d:string"></wellnessType>'+
      '<startDateTime i:type="d:string">'+DateUtil.timestampToTime(new Date().getTime() + 24 * 60 * 60 * 1000) + ' 00:00:00</startDateTime>'+
      '</n0:getTUpcomingAppointments></v:Body></v:Envelope>';
      var temporary = this;

    

      WebserviceUtil.getQueryDataResponse('client-profile','getTUpcomingAppointmentsResponse',data, function(json) {


        if (json && json.success == 1 && json.data && json.data.data && json.data.data.length > 0) {


            // 将来有
             temporary.setState({
                today_services:json.data.data,
                today_future_title:'Upcoming Session',
                isRefreshing:false,
             }); 

        }else {
           
           // 将来没有，
            temporary.setState({
                today_services:undefined,
                isRefreshing:false,
             });

        }

    });      

  }


  clickShop(){

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('ShopActivity');
    }

  }


_allBlogView(){


  if (this.state.blog_data && this.state.blog_data.length > 0) {

       var pages = [];

       for (var i = 0; i < this.state.blog_data.length; i++) {


          if (this.state.blog_data[i].length >= 2) {

            var filters1 = '';
            var filters2 = '';

            if (this.state.blog_data[i][0].filters && this.state.blog_data[i][0].filters.length > 0) {

              for (var j = 0; i < this.state.blog_data[i][0].filters.length; j++) {

                 var filter =  this.state.blog_data[i][0].filters[j];

                 if (!filter || filter.key_word) {
                    continue;
                 }
                 if (filters1 == '') {
                    filters1 += filter.key_word;
                 }else {
                     filters1 += (' ' + filter.key_word);
                }

              } 
            }

            if (this.state.blog_data[i][1].filters && this.state.blog_data[i][1].filters.length > 0) {

              for (var j = 0; j < this.state.blog_data[i][1].filters.length; j++) {

                 var filter =  this.state.blog_data[i][1].filters[j];

                 if (filters2 == '') {
                    filters2 += filter.key_word;
                 }else {
                    filters2 += (' ' + filter.key_word);
                }

              } 
            }
           
            var thumbnail_img1 = this.state.blog_data[i][0].thumbnail_img;
            var image_url1 = '';
            if (thumbnail_img1) {
              image_url1 = thumbnail_img1.slice(1,thumbnail_img1.length);
            }


            var thumbnail_img2 = this.state.blog_data[i][1].thumbnail_img;
            var image_url2 = '';
            if (thumbnail_img2) {
              image_url2 = thumbnail_img2.slice(1,thumbnail_img2.length);
            }

            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                 <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickBlog.bind(this,this.state.blog_data[i][0])}>


                    <View style = {[styles.view_product_item,{marginRight:4}]}>

                      <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                          <View style = {styles.view_image_card}>

                               <Image 
                                style={{flex:1,borderRadius:16}}
                                source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                resizeMode="cover" />


                          </View>


                          <View style = {{flexDirection: 'row',position:'absolute',}}>

                            

                                <TouchableOpacity
                                  onPress={this.clickLikeBlogShare.bind(this,this.state.blog_data[i][0])}>

                                   <View style = {[styles.view_item_like,{marginRight:0}]}>

                                     <Image
                                      style={{width:13,height:10}}
                                      source={require('../../../../images/share.png')}
                                      resizeMode = 'contain' />

                                   </View>  

                                </TouchableOpacity> 

                             

                                <TouchableOpacity
                                  onPress={this.clickLikeProduct.bind(this,this.state.blog_data[i][0])}>  


                                  <View style = {[styles.view_item_like]}>

                                       <Image
                                        style={{width:10,height:13}}
                                        source={ this.state.blog_data[i][0].has_booked == true ? require('../../../../images/home_qizi.png') : require('../../../../images/quxiao_0311.png')}
                                        resizeMode = 'contain' />

                    
                                  </View>

                            </TouchableOpacity>   


                          </View>


                      
                     </View>

                      <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.blog_data[i][0].title}</Text>

                      <Text style = {styles.text_product_price} numberOfLines={1}>{filters1}</Text>

                  </View>


                </TouchableOpacity>    



                  
                 <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickBlog.bind(this,this.state.blog_data[i][1])}>


                     <View style = {[styles.view_product_item,{marginLeft:4}]}>

                          <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                              <View style = {styles.view_image_card}>

                                  <Image 
                                    style={{flex:1,borderRadius:16}}
                                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url2}}
                                    resizeMode="cover" />

                              </View>


                              <View style = {{flexDirection: 'row',position:'absolute',}}>


                            
                                       <TouchableOpacity
                                          onPress={this.clickLikeBlogShare.bind(this,this.state.blog_data[i][1])}>

                                          <View style = {[styles.view_item_like,{marginRight:0}]}>

                                           <Image
                                              style={{width:13,height:10}}
                                              source={require('../../../../images/share.png')}
                                              resizeMode = 'contain' />

                                           </View>    

                                      </TouchableOpacity>    
                                  

                                       <TouchableOpacity
                                          onPress={this.clickLikeProduct.bind(this,this.state.blog_data[i][1])}>

                                           <View style = {styles.view_item_like}>

                                             <Image
                                                style={{width:10,height:13}}                                         
                                                source={ this.state.blog_data[i][1].has_booked == true ? require('../../../../images/home_qizi.png') : require('../../../../images/quxiao_0311.png')}
                                                resizeMode = 'contain' />

                                           </View>     

                                      </TouchableOpacity>    
                                  
                                  
                              </View>

                         </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.blog_data[i][1].title}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1}>{filters2}</Text>

                      
                      </View>
          
          
                   </TouchableOpacity>     


                   </View>


               

              );

          }else {

            var filters1 = '';
            if (this.state.blog_data[i][0].filters && this.state.blog_data[i][0].filters.length > 0) {

              for (var j = 0; i < this.state.blog_data[i][0].filters.length; j++) {

                 var filter =  this.state.blog_data[i][0].filters[j];

                 if (filters1 == '') {
                    filters1 += filter.key_word;
                 }else {
                     filters1 += (' ' + filter.key_word);
                }

              } 
            }

            var thumbnail_img1 = this.state.blog_data[i][0].thumbnail_img;
            var image_url1 = '';
            if (thumbnail_img1) {
              image_url1 = thumbnail_img1.slice(1,thumbnail_img1.length);
            }
      
           
            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                <TouchableOpacity
                    style = {styles.view_product_item}  
                    onPress={this.clickBlog.bind(this,this.state.blog_data[i][0])}>


                    <View style = {[styles.view_product_item,{marginRight:4}]}>

                        <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                            <View style = {styles.view_image_card}>

                                 <Image 
                                  style={{flex:1,borderRadius:16}}
                                  source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                  resizeMode="cover" />


                            </View>


                            <View style = {{flexDirection: 'row',position:'absolute',}}>


                               

                                     <TouchableOpacity
                                          onPress={this.clickLikeBlogShare.bind(this,this.state.blog_data[i][0])}>

                                          <View style = {styles.view_item_like}>

                                             <Image
                                                style={{width:13,height:10}}
                                                source={require('../../../../images/share.png')}
                                                resizeMode = 'contain' />


                                          </View>      

                                     </TouchableOpacity>     
                    

                                   <TouchableOpacity
                                        onPress={this.clickLikeProduct.bind(this,this.state.blog_data[i][0])}>

                                           <View style = {styles.view_item_like}>

                                             <Image
                                                style={{width:10,height:13}}
                                                source={ this.state.blog_data[i][0].has_booked == true ? require('../../../../images/home_qizi.png') : require('../../../../images/quxiao_0311.png')}
                                                resizeMode = 'contain' />

                                          </View>      

                                   </TouchableOpacity>     

 
                            </View>  

                       </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.state.blog_data[i][0].title}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1} >{filters1}</Text>


                    </View>

                </TouchableOpacity>    
                  


                <View style = {[styles.view_product_item,{marginLeft:4}]}>

                      

                </View>
      
              </View>


              );

          }


          
       }

      return (

        <View style = {styles.view_recently}>

          <View style = {styles.view_recently_title}>


            <Text style = {styles.text_recently_title}>Featured</Text>


             <TouchableOpacity
                onPress={this.clickViewBlog.bind(this,0)}>

                <Text style = {styles.text_view_all}>View Blog</Text>

             </TouchableOpacity>    

            

          </View>


          <Swiper
            loop={false}  
            height={257}
            index = {this.state.page2}
            showsPagination={true} 
            paginationStyle={{bottom: 24}}
            autoplay={false} 
            horizontal={true}
            dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
            activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
            >

            {pages}

          </Swiper>   




        </View>


      );



  }else {


    return (

      <View/>

    );


  }



}  


clickLikeBlogShare(blog){

  nativeBridge.shareBlog(blog.id,blog.title);

}


clickLikeProduct(item){

  this.setState({
    new_blog_id:item.id
  });

  if (item.has_booked == true) {
     nativeBridge.setBlogStatus(item.id,'1');
  }else {
     nativeBridge.setBlogStatus(item.id,'0');
  }


}




clickBlog(item){

  nativeBridge.openNativeVc("BlogDetailViewController",{blogId:item.id,hasBook:item.has_booked});

}





clickViewBlog(){

  DeviceEventEmitter.emit('clickUseCenterItem','Blog');

}


clickSymptomChecker(){

  nativeBridge.openNativeVc("SymptomCheckBeginController",null);

}

clickConditions(){

  DeviceEventEmitter.emit('clickUseCenterItem','Conditions We Treat');

}


clickMadamPartum(){

  nativeBridge.openNativeVc("MadamPartumController",null);

}


clickWalt(){

  DeviceEventEmitter.emit('clickUseCenterItem','CCT Wallet');

} 





  render() {

    var level_name = 'Basic';

    if (this.state.userBean) {

      if (this.state.userBean.new_recharge_card_level) {

          if (this.state.userBean.new_recharge_card_level == '1') {

              level_name = 'Basic Tier';

          }else if (this.state.userBean.new_recharge_card_level == '2') {

            level_name = 'Silver Tier';

          }else if (this.state.userBean.new_recharge_card_level == '3') {

            level_name = 'Gold Tier';
            
          }else if (this.state.userBean.new_recharge_card_level == '4') {

            level_name = 'Platinum Tier';
            
          }

      }
    }



      return(
          <View style = {styles.bg}>

           <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

           <SafeAreaView style = {styles.afearea} />

           <View style = {styles.view_head}>


            <TouchableOpacity 
              activeOpacity = {0.8}
              onPress={this.clickOpenMenu.bind(this)}>

                <Image style = {styles.image_home} 
                  resizeMode = 'contain' 
                  source={require('../../../../images/home_user.png')}/> 

            </TouchableOpacity>

          

            <Text style = {styles.text_title}>Chien Chi Tow</Text>  




             <TouchableOpacity 
              activeOpacity = {0.8}
              onPress={this.clickHomeQrCode.bind(this)}>


               <Image style = {styles.image_home} 
                  resizeMode = 'contain' 
                  source={require('../../../../images/home_saoma.png')}/>    


            </TouchableOpacity>

           

           </View> 

          <ScrollView style = {styles.scrollview}

            refreshControl={
                <RefreshControl
                    refreshing={this.state.isRefreshing}
                    onRefresh={this._onRefresh.bind(this, 0)}
                />
            }
            contentOffset={{x: 0, y: 0}}>


            <View style = {styles.view_value}>


                <View style = {styles.view_tier}>

                    <Text style = {styles.text_tier}>{level_name}</Text>

                    <Image style = {styles.image_tier} 
                      resizeMode = 'contain' 
                      source={require('../../../../images/bai_gantan.png')}/>    

                </View>



                <TouchableOpacity style = {{width:'100%'}}  
                  activeOpacity = {0.8}
                  onPress={this.clickWalt.bind(this)}>

                  <View style = {styles.view_walt}>
                  
                    <View style = {styles.view_walt_item}>

                        <Image style = {styles.image_walt} 
                          resizeMode = 'contain' 
                          source={require('../../../../images/home_logo.png')}/>

                    </View>


                    <Text style = {styles.text_walt}>{'$' + this.state.card_amount}</Text>



                    <View style = {[styles.view_walt_item,{marginLeft:28}]}>

                        <Image style = {styles.image_walt} 
                          resizeMode = 'contain' 
                          source={require('../../../../images/oyaltypointxxxhdpi.png')}/>

                    </View>


                     <Text style = {styles.text_walt}>{this.state.userBean ? (this.state.userBean.points ? (parseInt(this.state.userBean.points)) : '0') : '0'}</Text>


                     <Text style = {styles.text_walt_value}>Points</Text>



                     <View style = {{flex:1}}/>



                     <Image style = {styles.image_walt_more} 
                          resizeMode = 'contain' 
                          source={require('../../../../images/right_11_10.png')}/>

                  </View>

                </TouchableOpacity>  

            </View>


            <View style = {[styles.view_book,{backgroundColor:'#FFFFFF'}]}>


              {this.bookService()}

              <TouchableOpacity style = {styles.next_layout}  
                    activeOpacity = {0.8}
                    onPress={this.clickAddBook.bind(this)}>


                <Text style = {styles.text_add_book}>+Book Appointment</Text>



              </TouchableOpacity>



              <View style = {styles.view_icon}>



                   {/* <TouchableOpacity   
                      activeOpacity = {0.8}
                      onPress={this.clickSymptomChecker.bind(this)}>


                       <View style = {styles.view_icon_item}>

                            <View style = {styles.view_icon_bg}>

                                <Image style = {styles.image_icon} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/symptomcheckerxxxhdpi.png')}/>  


                            </View>


                           <Text style = {styles.text_icon}>Symptom</Text>   

                           <Text style = {styles.text_icon}>Checker</Text>   

                        </View>


                  </TouchableOpacity>       */}

                   
                   <TouchableOpacity   
                      activeOpacity = {0.8}
                      onPress={this.clickShop.bind(this)}>

                      <View style = {styles.view_icon_item}>

                          <View style = {styles.view_icon_bg}>

                              <Image style = {styles.image_icon} 
                                resizeMode = 'contain' 
                                source={require('../../../../images/shoppingxxxhdpi.png')}/>  


                          </View>


                         <Text style = {styles.text_icon}>Shop</Text>   

                         <Text style = {styles.text_icon}></Text>   

                      </View>

                  </TouchableOpacity>



                  <TouchableOpacity   
                      activeOpacity = {0.8}
                      onPress={this.clickConditions.bind(this)}>

                      <View style = {styles.view_icon_item}>

                          <View style = {styles.view_icon_bg}>

                              <Image style = {styles.image_icon} 
                                resizeMode = 'contain'
                                source={require('../../../../images/conditionwetreatxxxhdpi.png')}/>  


                          </View>


                         <Text style = {styles.text_icon}>Conditions</Text>   

                         <Text style = {styles.text_icon}>We Treat</Text>   

                      </View>


                  </TouchableOpacity>


                <TouchableOpacity   
                    activeOpacity = {0.8}
                    onPress={this.clickMadamPartum.bind(this)}>

                     <View style = {styles.view_icon_item}>

                        <View style = {styles.view_icon_bg}>

                            <Image style = {styles.image_icon} 
                              resizeMode = 'contain' 
                              source={require('../../../../images/facebook_copyxxxhdpi.png')}/>  


                        </View>


                       <Text style = {styles.text_icon}>Madam</Text>   

                       <Text style = {styles.text_icon}>Partum</Text>   

                    </View>

                </TouchableOpacity>            


                   
              </View>


             
            </View>


            <View style = {{padding:24,width:'100%'}}>

              {this._allBlogView()}

            </View>

            


          </ScrollView>  



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
    flex:0,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_head:{
    padding:19,
    width: '100%',
    backgroundColor:'#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  image_home :{
    width:18,
    height:18
  },
  text_title :{
    color:'#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
   scrollview:{
    flex:1,
    backgroundColor:'#FAF3E8'
  },
  view_value : {
    paddingTop:8,
    paddingLeft:16,
    paddingBottom:16,
    paddingRight:16,
    backgroundColor:'#145A7C',
  },
  view_tier : {
    flexDirection: 'row',  
  },
  text_tier : {
    color:'#FFFFFF',
    fontSize: 14,
    fontWeight: 'bold',
  },
  image_tier:{
    marginTop:1,
    marginLeft:8,
    width:15,
    height:15,
  },
  view_walt:{
    marginTop:10,
    flexDirection: 'row',
  },
  image_walt: {
    width:15,
    height:15,
  },
  view_walt_item:{
    backgroundColor:'#FFF',
    height:25,
    width:25,
    borderRadius:50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_walt : {
    marginTop:2,
    marginLeft:10,
    fontSize:16,
    color:'#FFFFFF',
    fontWeight: 'bold',

  },
  text_walt_value:{
    marginTop:2,
    marginLeft:2,
    fontSize:16,
    color:'#FFFFFF',
  },
  image_walt_more:{
    marginTop:7,
     width:8,
     height:8, 
  },
  view_book:{
    padding:24,
  },
  text_book_title:{
    color:'#145A7C',
    fontSize:24,
    fontWeight:'bold',
  },
  text_book_content:{
    fontSize:14,
    color:'#000000',
  },
  next_layout:{
    marginTop:26,
      backgroundColor:'#145A7C',
      width:'100%',
      height:44,
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'
  },
  text_add_book : {
    color:'#ffffff',
    fontSize:14,
    fontWeight:'bold',
  },
  view_icon : {
    paddingRight:16,
    paddingLeft:16,
    marginTop:24,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  view_icon_item : {
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_icon_bg:{
    marginBottom:8,
    width:44,
    height:44,
    borderRadius: 50,
    backgroundColor:'#FAF3E8',
    justifyContent: 'center',
    alignItems: 'center'
  },
  image_icon:{
    width:25,
    height:25,
  },
  text_icon:{
    fontSize:12,
    color:'#000000'
  },
  view_book_head:{
    width:'100%',
  },
  view_book_head_title:{
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'  
  },
  text_view_all: {
    color:'#C44729',
    fontWeight:'bold',
    fontSize:14,
  },
  view_card:{
    backgroundColor:'#0000FF',
    height:'#100%',
    width:200,
    shadowColor:'#000000'
  },
  view_service_head : {
    padding:12,
    width:'100%',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    backgroundColor:'#FAF3E8',
    justifyContent: 'center'  ,
  },
  text_service_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:14,
    fontWeight:'bold',
  },
  view_item_item:{
    marginTop:8,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_item_item2:{
    marginTop:8,
    flexDirection: 'row',
  },

  image_item:{
    width:15,
    height:15
  },
  text_item_content:{
    marginLeft:6,
    flex:1,
    color:'#333',
    fontSize:14,
    fontWeight:'bold',
  },
  text_item_content2:{
    marginLeft:6,
    color:'#333',
    fontSize:14,
    fontWeight:'bold',
  },
  view_time_outle:{
    width:'100%',
    margin:16,
  },
  next_layout_chinck_in:{
      width:'100%',
      height:44,
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'
  },
  next_text_chinck_in :{
      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',
  },
  next_view_chinck_in:{
    marginLeft:16,
    marginBottom:16,
    marginRight:16,
  },
  text_time_title:{
    marginTop:4,
    fontSize:32,
    color:'#C44729',
    fontWeight:'bold',
  },
  text_item_content_hint:{
    marginTop:8,
    fontSize:12,
    color:'#828282',
  },
  indicator_item:{
      width:24,
      height:4,
      backgroundColor:'#000000',
      borderRadius: 50,
      marginLeft:4,
  },
  view_product:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  view_product_item:{
    flex:1,
    height:180
  },
  view_image_card:{
    borderRadius:16,
    width:'100%',
    height:120,
    backgroundColor:'#F2F2F2'
  },

  view_item_like:{
    margin:8,
    borderRadius:50,
    width:25,
    height:25,
    backgroundColor:'#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_xing:{
    marginTop:4,
    width:'100%',
    flexDirection: 'row',
  },
  text_product_name:{
    width:'100%',
    fontSize:14,
    color:'#333',
    fontWeight:'bold',
  },
  text_product_price:{
    marginTop:4,
    width:'100%',
    fontSize:12,
    color:'#828282',
  },
  view_recently:{
    marginTop:24,
    width:'100%',
  },
  view_recently_title:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_recently_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C'
  },
 
});