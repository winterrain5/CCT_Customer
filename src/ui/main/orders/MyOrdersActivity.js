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

export default class MyOrdersActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       seleted_type:0,
       orders:[],
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

      this.getInProgressOrders(user_bean);

    });

  }


  getCancelledInvoices(userBean){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n0:getCancelledInvoices id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getCancelledInvoices></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getCancelledInvoicesResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {
            // 当天有
             temporary.setState({
                orders:json.data,
             }); 

        }else {
            temporary.setState({
                orders:[],
             }); 

        }

    });      

  }





  getCompletedOrders(userBean){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:getCompletedOrders id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
     '</n0:getCompletedOrders></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getCompletedOrdersResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {
            // 当天有
             temporary.setState({
                orders:json.data,
             }); 

        }else {
            temporary.setState({
                orders:[],
             }); 

        }

    });      

    
  }




  getInProgressOrders(userBean){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
    '<v:Header />'+
    '<v:Body><n1:getInProgressOrders id="o0" c:root="1" xmlns:n1="http://terra.systems/">'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n1:getInProgressOrders></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getInProgressOrdersResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {
            // 当天有
             temporary.setState({
                orders:json.data,
             }); 

        }else {
            temporary.setState({
                orders:[],
             }); 

        }

    });      



  }



  clickType(type){

    if (type != this.state.seleted_type) {
        if (type == 0) {
          this.getInProgressOrders(this.state.userBean);
        }else if (type == 1){
          this.getCompletedOrders(this.state.userBean);
        }else if (type == 2){
          this.getCancelledInvoices(this.state.userBean);
        }
    }
    

    this.setState({
      'seleted_type':type,
    })

  }


  _renderItem = (item) => {


    var items = [];


    for (var i = 0; i < item.item.order_lines.length; i++) {
      
      items.push(

        <View style = {[styles.view_type,{marginBottom:16}]}>

            <Text style = {styles.tex_item_count}>{parseInt(item.item.order_lines[i].qty) + ' x '}</Text>

            <Text style = {[styles.tex_item_count,{fontWeight:'bold'}]}>{item.item.order_lines[i].name}</Text>

        </View>


      );

    }


    return ( 


        <TouchableOpacity 
          onPress={this.clickOrderItem.bind(this,item)}
          activeOpacity = {0.8 }>

          <View style = {styles.view_item}>

              <Text style = {styles.text_item_title}>{'Date of Order ' + DateUtil.getShowTimeFromDate4(item.item.invoice_date)}</Text>

              {items}

          </View>

        </TouchableOpacity>  

  
      );

  }


  clickOrderItem(item){

    const { navigation } = this.props;

    if (navigation) {
       navigation.navigate('OrderDetailsActivity',{
        'selected_type':this.state.seleted_type,
        'order':item.item,
      });

    }

  }


  orderItems(){


    if (this.state.orders && this.state.orders.length > 0) {

      return (

            <FlatList
              ref = {(flatList) => this._flatList = flatList}
              renderItem = {this._renderItem}
              onEndReachedThreshold={0}
              keyExtractor={(item, index) => index.toString()}
              data={this.state.orders}/>


        );


    }else {


      return (

        <View style = {styles.view_nodata}>

          <Text style = {styles.text_no_data}>You have not ordered anything recently</Text>

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
              title = {'My Orders'} 
              navigation={navigation}
              hideLeftArrow = {true}
              hideRightArrow = {false}
              extraData={this.state}/>


             <View style = {styles.view_content}>


                <View style = {styles.view_type}>


                   <TouchableOpacity 
                      onPress={this.clickType.bind(this,0)}
                      activeOpacity = {0.8 }>

                       <View style = {[styles.view_type_item,{backgroundColor: this.state.seleted_type == 0 ? '#145A7C' : '#F2F2F2'}]}>


                          <Text style = {this.state.seleted_type == 0 ? styles.text_type : styles.text_type_unselected}>In Progress</Text>

                      </View>

                   </TouchableOpacity>   


                   <TouchableOpacity 
                      onPress={this.clickType.bind(this,1)}
                      activeOpacity = {0.8 }>

                       <View style = {[styles.view_type_item,{marginLeft:8,backgroundColor: this.state.seleted_type == 1 ? '#145A7C' : '#F2F2F2'}]}>


                          <Text style = {this.state.seleted_type == 1 ? styles.text_type : styles.text_type_unselected}>Completed</Text>

                      </View>

                  </TouchableOpacity>



                  <TouchableOpacity 
                      onPress={this.clickType.bind(this,2)}
                      activeOpacity = {0.8 }>


                      <View style = {[styles.view_type_item,{marginLeft:8,backgroundColor: this.state.seleted_type == 2 ? '#145A7C' : '#F2F2F2'}]}>


                          <Text style = {this.state.seleted_type == 2 ? styles.text_type : styles.text_type_unselected}>Cancelled</Text>

                      </View>

                   </TouchableOpacity>         

              
                </View>





                 <View style = {[styles.bg,{paddingTop:16}]}>



                  {this.orderItems()}


                 


                </View>



             </View>   


          </SafeAreaView>


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
    backgroundColor:'#FFFFFF',
     padding:24,
  },
  view_type:{
    width:'100%',
    flexDirection: 'row',
    
  },
  view_type_item:{
    paddingLeft:12,
    paddingRight:12,
    paddingTop:8,
    paddingBottom:8,
    backgroundColor:'#145A7C',
    borderRadius:50,
  },
  text_type:{
    color:'#FFFFFF',
    fontSize:14,
    fontWeight:'bold',
  },
  text_type_unselected:{
     color:'#333333',
    fontSize:14,
  },
  view_item:{
    marginTop:24,
    width:'100%',
    backgroundColor:'#FAF3EB',
    borderRadius:16,
    padding:16,
  },
  text_item_title:{
    fontSize:16,
    color:'#145A7C',
    fontWeight:'bold',
  },
  tex_item_count:{
    color:'#333333',
    fontSize:14,
  },
  view_nodata:{
    flex:1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text_no_data:{
    color:'#828282',
    fontSize:14,
    fontWeight:'bold',
  }
});

