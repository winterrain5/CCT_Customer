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


export default class UpcomingBookTable extends Component {

  constructor(props) {
      super(props);
      this.state = {
         head_company_id:'97',
         userBean:undefined,
         service_data:[],
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


       this.getTUpcomingAppointments(user_bean);

    });
     
  } 


    //注册通知
  componentDidMount(){
  
     var temporary = this;
    this.emit =  DeviceEventEmitter.addListener('book_up',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         temporary.getTUpcomingAppointments(temporary.state.userBean);
     });


  }

  componentWillUnmount(){

    this.emit.remove();

  }


  

  getTUpcomingAppointments(userBean){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTUpcomingAppointments id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<length i:type="d:string">20</length>'+
     '<start i:type="d:string">0</start>'+
     '<clientId i:type="d:string">' + userBean.id +'</clientId>'+
     '<wellnessType i:type="d:string"></wellnessType>'+
     '<startDateTime i:type="d:string">'+ (DateUtil.formatDateTime5(24*60*60*1000) + ' 00:00:00')+'</startDateTime>'+
     '</n0:getTUpcomingAppointments></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getTUpcomingAppointmentsResponse',data, function(json) {

           console.error(json.data);
        if (json && json.success == 1 && json.data ) {

            // 当天有
             temporary.setState({
                service_data:json.data.data,
             }); 

        }

    });      

  }






_renderItem() {


if (this.state.service_data && this.state.service_data.length > 0) {


    var items = [];

    for (var i = 0; i < this.state.service_data .length; i++) {
        var item =  this.state.service_data [i]


        items.push(


             <TouchableOpacity
                  key = {'' + i}
                  activeOpacity = {0.8}
                  onPress={this.clickItem.bind(this,item)}> 


              <View style = {styles.view_item} key = {'' + i}>


                  <Text style = {styles.text_date}>{DateUtil.getShowTimeFromDate5(item.therapy_start_date)}</Text>


                  <View style = {styles.view_service_item}>


                    <View style = {styles.view_item_week}>


                      <Text style = {styles.text_day}>{DateUtil.getShowTimeFromDate6(item.therapy_start_date)}</Text>


                      <Text style = {styles.text_week}>{DateUtil.getShowTimeFromDate7(item.therapy_start_date)}</Text>

                    </View>



                    <View style = {styles.view_item_card}>


                      <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{ width:width - 110, padding:4,margin:8,height:145}} >


                            
                                   <View style = {[{height:'100%', backgroundColor:'#FFF'}]}>


                                       <View style = {styles.view_service_head}>

                                           <Text style = {styles.text_service_title}>{item.alias_name}</Text>

                                       </View>


                                      <View style = {styles.view_time_outle}>


                                        <View style = {styles.view_item_item}>

                                            <Image style = {styles.image_item} 
                                              resizeMode = 'contain' 
                                              source={require('../../../../images/time.png')}/>


                                            <Text style = {styles.text_item_content}>{DateUtil.getShowHMTime2(item.therapy_start_date)}</Text>

                                        </View>


              

                                       <View style = {[styles.view_item_item,{marginTop:8}]}>


                                          <Image style = {styles.image_item} 
                                            resizeMode = 'contain' 
                                            source={require('../../../../images/location.png')}/>


                                           <Text style = {styles.text_item_content}>{item.location_name}</Text>

                                        </View>


                                        {this._therapistView(item)} 

                                    
                                      </View>

                                   </View>

                                

                               </Card>

                    </View>

                  </View>

                  <View  style = {styles.view_line} />  

                </View>

             </TouchableOpacity>    


        );


    }


    return (

      <View style = {{width:'100%'}}>


        {items}


      </View>

    );



} else {


  return (

      <View style = {styles.view_item}>


        <Text style = {styles.txte_no_data_title}>You have no upcoming appointments</Text>


         <TouchableOpacity style = {styles.next_layout}  
                    activeOpacity = {0.8}
                    onPress={this.clickAddBook.bind(this)}>

            <Text style = {styles.text_add_book}>+Book Appointment</Text>

        </TouchableOpacity>

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

    return (

     <View style = {[styles.view_item_item,{marginTop:8}]}>


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





clickAddBook(){
    DeviceEventEmitter.emit('addBook','ok');
} 


itemDateTitle(item){


  return (<View />);


}

clickItem(item){


  
    DeviceEventEmitter.emit('service_detail',JSON.stringify(item));
   
    // if (navigation) {
    //   navigation.navigate('BookDetailsActivity',{
    //     'service':item.item,
    //   });
    // }


  }
  



    
render() {

       return(

        <View style = {styles.bg}>

        <ScrollView 
          style = {styles.scrollview}
          showsVerticalScrollIndicator = {false}>

           {this._renderItem()}

        </ScrollView>     



       
{/*
      <FlatList
              ref = {(flatList) => this._flatList = flatList}
              renderItem = {this._renderItem}
              onEndReachedThreshold={0}
              keyExtractor={(item, index) => index.toString()}
              data={this.state.service_data}/>*/}
        </View>
       );

    }
}



const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_item : {
    width:'100%',
    padding:24,
  },
  view_service_item:{
     width:'100%',
     flexDirection: 'row',  
  },
  view_item_week:{
    marginTop:8,
    alignItems: 'center',
  },
  view_item_card:{
    marginLeft:8

  },
  text_day:{
    color:'#000',
    fontWeight: 'bold',
    fontSize:36,

  },
  text_week:{
    color:'#828282',
    fontSize:12,
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
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
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
  view_time_outle:{
    width:'100%',
    margin:16,
  },
  view_line: {
    marginTop:14,
    backgroundColor:'#F2F2f2',
    width:'100%',
    height:1
  },
  text_date:{
    color:'#000',
     fontSize:12,
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
  txte_no_data_title:{
    marginTop:24,
    width:'100%',
    color:'#828282',
    fontSize:14,
    fontWeight:'bold',
    textAlign :'center',
  }
  
});


