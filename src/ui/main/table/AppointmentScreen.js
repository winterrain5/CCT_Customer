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
  RefreshControl
} from 'react-native';

import Swiper from 'react-native-swiper';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import DeviceStorage from '../../../uitl/DeviceStorage';

import DateUtil from '../../../uitl/DateUtil';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import {Card} from 'react-native-shadow-cards';

import QueueView from '../../../widget/QueueView';

import UpcomingBookTable from './UpcomingBookTable';

import CompletedBookTable from './CompletedBookTable';


let {width, height} = Dimensions.get('window');


import ScrollableTabView, {ScrollableTabBar, DefaultTabBar} from 'react-native-scrollable-tab-view';




export default class AppointmentScreen extends Component {



   constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       today_services:undefined,
       page:0,
       table_page:0,
       isRefreshing:false,
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

    });
     
  }
    //注册通知
  componentDidMount(){
  
     var temporary = this;
    this.emit =  DeviceEventEmitter.addListener('book_up',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         temporary.getClientBookedServices(temporary.state.userBean);
     });


  }

  componentWillUnmount(){

    this.emit.remove();

  }

  _onRefresh(){

    this.setState({
      isRefreshing:true,
      page:0,
    });

    this.getClientBookedServices(this.state.userBean);

  }

  

    //获取当天的服务
  getClientBookedServices(userBean){


    if (userBean == undefined) {
      return;
    }

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
                isRefreshing : false,
             }); 

        }else {
           
            temporary.setState({
                today_services:[],
                isRefreshing : false,
             }); 

        }




    });      

  }


  clickAddBook(){

      DeviceEventEmitter.emit('addBook','ok');

  }


  clickOpenMenu(){

    DeviceEventEmitter.emit('openMenu','ok');

  }


  _renderTabBar(){



    return(<View style = {{width:'100%',backgroundColor:'#000',height:200}} />);



  }


  bookService(){


    if (this.state.today_services && this.state.today_services.length > 0) {



      var pages = [];


      var card_height = 200;



      for (var i = 0; i < this.state.today_services.length; i++) {
         
         var service = this.state.today_services[i];


         if (DateUtil.formatDateTime1() != DateUtil.parserDateString(service.therapy_start_date)) {


           if (card_height < 200) {

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


            if (card_height <= 270) {

              card_height = 270;

              if (service.staff_is_random == '2') {

                 card_height = 290;
              }

            }

            // 看诊排队阶段

             pages.push(


                 <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8,height:service.staff_is_random == '2' ? 260:240}} >


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

                  <Card key = { i + ''} cornerRadius={16} opacity={0.1} elevation={4}  style = {{width:width - 64, padding:4,margin:8}} >


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

             <Text style = {styles.text_book_title}>Today's Session</Text>

           </View> 


           <Text style = {styles.text_book_date}>{DateUtil.getShowTimeFromDate2(DateUtil.formatDateTime())}</Text>



           <View style = {{height:card_height}}>

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


          
           

          

        </View>
      );



    }else {

      return (

        <View />
      );

    }

  }



  _therapistView(service){


    if (service.staff_is_random == '2') {


      return (

          <View style = {styles.view_item_item}>


             <Image style = {styles.image_item} 
                resizeMode = 'contain' 
                source={require('../../../../images/person_0217.png')}/>


              <Text style = {styles.text_item_content}>{service.staff_name}</Text> 
             
          </View> 

      );

    }else {

      return (<View />);

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

  clickChinckIn(service){


     const { navigation } = this.props;
     if (navigation) {

      //扫码页面
      navigation.navigate('ScanQRCodeActivity',{
        'service':service,
        'type':0
      });

      // //确认页面
      // navigation.navigate('CheckInConfirmBookActivity',{
      //   'service':service,
      // });

    }
  }

  clickTablePage(page){

    if (this.state.table_page != page) {

      this.setState({

        table_page : page,

      });

    }

  }





  render() {
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

                <Text style = {styles.text_title}>Appointment</Text>     



                 <TouchableOpacity 
                    activeOpacity = {0.8 }
                    onPress={this.clickAddBook.bind()}>

                    <Image style = {styles.image_home} 
                      resizeMode = 'contain' 
                      source={require('../../../../images/add_more.png')}/>    

                 </TouchableOpacity>  
 

              </View> 


              
             <ScrollView 
                  style = {styles.scrollview}
                  stickyHeaderIndices = {[1]}
                  showsVerticalScrollIndicator = {false}
                  contentOffset={{x: 0, y: 0}}
                  refreshControl={
                      <RefreshControl
                          refreshing={this.state.isRefreshing}
                          onRefresh={this._onRefresh.bind(this)}
                      />
                  }
                  onScroll={this.changeScroll}>


                  {this.bookService()}



                  <View style = {{width:'100%'}}>

                    <View style = {styles.view_table_head}>


                      <TouchableOpacity 
                        style = {styles.view_table_head_item}
                        activeOpacity = {0.8 }
                        onPress={this.clickTablePage.bind(this,0)}>

                        <View style = {styles.view_table_head_item}>

                          <Text style = {[styles.text_table,{color: this.state.table_page == 0 ? '#C44729' : '#000000',fontWeight : this.state.table_page == 0 ? 'bold' : 'normal' }]}>Upcoming</Text>

                        </View>

                     </TouchableOpacity>   


                      <TouchableOpacity 
                        style = {styles.view_table_head_item}
                        activeOpacity = {0.8 }
                        onPress={this.clickTablePage.bind(this,1)}>


                        <View style = {styles.view_table_head_item}>

                          <Text style = {[styles.text_table,{color: this.state.table_page == 1 ? '#C44729' : '#000000',fontWeight : this.state.table_page == 1 ? 'bold' : 'normal' }]}>Completed</Text>

                        </View>


                      </TouchableOpacity>  

                    
                    </View>


                    <View style = {{width:'100%',height:2, flexDirection: 'row',}}>


                      <View style = {{flex:1, justifyContent: 'center',alignItems: 'center',}}>

                          <View style = {{width:97,height:2,backgroundColor:this.state.table_page ==  0 ? '#C44729' : '#FFFFFF'}}/>

                      </View>


                      <View style = {{flex:1, justifyContent: 'center',alignItems: 'center',}}>

                          <View style = {{width:97,height:2,backgroundColor:this.state.table_page ==  1 ? '#C44729' : '#FFFFFF'}}/>

                      </View>


                    </View>


                    <View style = {styles.view_line}/>

                  </View>

                  <View style = {{flex:1}}>


                    {this.state.table_page == 0 ?  <UpcomingBookTable tabLabel="Upcoming" /> :  <CompletedBookTable tabLabel="Completed" />}


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
    backgroundColor:'#FFFFFF'
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
    padding:24,
  },
  view_book_head_title:{
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'  
  },
  text_book_date:{
    color:'#828282',
    fontSize:16,
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
  view_table_head:{
    width:'100%',
    height:50,
    backgroundColor:'#ffffff',
    flexDirection: 'row',
  },
  view_table_head_item:{
    flex:1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_line:{
    width:'100%',
    height:1,
    backgroundColor:'#E5E5E5',
  },
  text_table:{
    fontSize:14,
  }
 
});


