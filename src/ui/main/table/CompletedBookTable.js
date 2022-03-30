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


export default class CompletedBookTable extends Component {

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

       // this.getTAppointmentHistoryForApp(user_bean);

       this.getTSlotHistoryForApp(user_bean);

    });
     
  } 

   getTSlotHistoryForApp(userBean){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getTSlotHistoryForApp id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<length i:type="d:string">50</length>'+
     '<start i:type="d:string">0</start>'+
     '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
     '</n0:getTSlotHistoryForApp></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getTSlotHistoryForAppResponse',data, function(json) {

        
        console.error(json);

        if (json && json.success == 1 && json.data ) {

           var service_data = [];

           for (var key in json.data) {
            
              service_data.push(json.data[key]);     
           } 

           if (service_data.length > 0) {

              temporary.setState({
                service_data:service_data,
             }); 

           }else {
              temporary.setState({
                service_data:json.data,
             }); 
           }  
        }

    });      

  }



  

  // getTAppointmentHistoryForApp(userBean){

  //    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTAppointmentHistoryForApp id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  //    '<isTrement i:type="d:string">1,2</isTrement>'+
  //    '<length i:type="d:string">20</length>'+
  //    '<start i:type="d:string">0</start>'+
  //    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
  //    '<wellnessType i:type="d:string"></wellnessType>'+
  //    '</n0:getTAppointmentHistoryForApp></v:Body></v:Envelope>';

  //   var temporary = this;
  //   WebserviceUtil.getQueryDataResponse('client-profile','getTAppointmentHistoryForAppResponse',data, function(json) {

        
  //       if (json && json.success == 1 && json.data ) {

  //           // 当天有
  //            temporary.setState({
  //               service_data:json.data,
  //            }); 

  //       }

  //   });      

  // }


  _history_service(){


    if (this.state.service_data && this.state.service_data.length > 0) {


      return (

        <FlatList
          ref = {(flatList) => this._flatList = flatList}
          renderItem = {this._renderItem}
          onEndReachedThreshold={0}
          keyExtractor={(item, index) => index.toString()}
          data={this.state.service_data}/>


      );

    

    }else {

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


  clickAddBook(){

    DeviceEventEmitter.emit('addBook','ok');

  }





_renderItem = (item) => {

  var height = 90;


  if (item.item.items && item.item.items.length > 0) {

    height = 90 + item.item.items.length * 23;

  }




  return (

    <View style = {styles.view_item}>


      <Text style = {styles.text_date}>{DateUtil.getShowTimeFromDate5(item.item.therapy_start_date)}</Text>


      <View style = {styles.view_service_item}>


        <View style = {styles.view_item_week}>


          <Text style = {styles.text_day}>{DateUtil.getShowTimeFromDate6(item.item.therapy_start_date)}</Text>


          <Text style = {styles.text_week}>{DateUtil.getShowTimeFromDate7(item.item.therapy_start_date)}</Text>

        </View>





        <View style = {styles.view_item_card}>


          <Card  cornerRadius={16} opacity={0.1} elevation={4}  style = {{ width:width - 110, padding:4,margin:8,height:height}} >


                    <TouchableOpacity
                        activeOpacity = {1}
                        onPress={this.clickItem.bind(this,item.item)}>



                       <View style = {[{height:'100%', backgroundColor:'#FFF'}]}>




                           <View style = {styles.view_service_head}>


                               <Image style = {[styles.image_item,{marginLeft:16}]} 
                                  resizeMode = 'contain' 
                                  source={require('../../../../images/location.png')}/> 


                               <Text style = {styles.text_service_title}>{item.item.location_name}</Text>

                           </View>


                          <View style = {styles.view_time_outle}>

                              {this._itemSevices(item.item.items)}
                                              
                          </View>

                       </View>

                     </TouchableOpacity>    

                   </Card>

        </View>

      </View>


    <View  style = {styles.view_line} />  


    </View>


  );
}


_itemSevices(items){


  if (items && items.length > 0) {

    var item_views = [];

    for (var i = 0; i < items.length; i++) {
       
       item_views.push(

        <View>

          <Text 
            numberOfLines={1} 
            style = {styles.text_item_service}>{items[i]}</Text>

        </View>

      );
    }

    return item_views;


  }else {

    return (<View />);

  }



}





clickItem(item){


  DeviceEventEmitter.emit('service_detail',JSON.stringify(item));


}
  




render() {

       return(

        <View style = {styles.bg}>


        {this._history_service()}

        
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
    flexDirection: 'row',
  },
  text_service_title:{
    width:'100%',
    color:'#145A7C',
    fontSize:14,
    fontWeight:'bold',
    marginLeft:5,
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
  },
  text_item_service:{
    width:width - 150,
    marginTop:8,
    color:'#333',
    fontSize:14,
    fontWeight:'bold',

  }
  
});



