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

import StringUtils from '../../../uitl/StringUtils';

import {Card} from 'react-native-shadow-cards';


let {width, height} = Dimensions.get('window');


export default class WalletTransactionsTable extends Component {

  constructor(props) {
      super(props);
      this.state = {
         head_company_id:'97',
         userBean:undefined,
         transactions:[],
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

      this.getTInvoicesForApp(user_bean);
    });
     
  } 


  getTInvoicesForApp(userBean){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTInvoicesForApp id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<length i:type="d:string">20</length><orderType i:type="d:string">0</orderType>'+
     '<start i:type="d:string">0</start>'+
     '<isHistory i:type="d:string">1</isHistory>'+
     '<clientId i:type="d:string">' + userBean.id +'</clientId>'+
     '</n0:getTInvoicesForApp></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('client-profile','getTInvoicesForAppResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {

            // 当天有
             temporary.setState({
                transactions:json.data,
             }); 

        }else {
           
            temporary.setState({
                transactions:[],
             }); 

        }

    });      


  }



_renderItem = (item) => {


  var volue = 0.00;

  if (item.item.freight) {

    volue = parseFloat(item.item.freight) + parseFloat(item.item.total);

  }



  return(

     <TouchableOpacity 
        style = {{width:'100%'}}
        activeOpacity = {0.8 }
        onPress={this.clickItem.bind(this,item)}>

         <View style = {{width:'100%'}}>

              <View style = {{width:'100%',backgroundColor:'#f2f2f2',paddingLeft:24,}}>

                  <Text style = {styles.text_item_date}>{DateUtil.getShowTimeFromDate4(item.item.due_date)}</Text>

              </View>


              <View style = {styles.view_item_info}>


                  <View style = {styles.view_no_volue}>

                      <Text style = {styles.text_invoice_no}>#{item.item.invoice_no}</Text>

                      <Text style = {styles.text_invoice_no}>${StringUtils.toDecimal(volue)}</Text>


                  </View>


                  <Text style = {styles.text_remark}>{item.item.product_category == '9' ? 'Top Up' : item.item.first_product_name}</Text>

               

              </View>


          </View>

     </TouchableOpacity>

   
  );

}


clickItem(item){


  DeviceEventEmitter.emit('transactions_detail',item.item.id);


}




render() {

  return(

    <View style = {styles.bg}>

    { (this.state.transactions && this.state.transactions.length > 0) ?   

      <FlatList
          style = {{flex:1,width:'100%'}}
          ref = {(flatList) => this._flatList = flatList}
          renderItem = {this._renderItem}
          onEndReachedThreshold={0}
          keyExtractor={(item, index) => index.toString()}
          data={this.state.transactions}/>

       :
       
       <Text style = {styles.text_no_data}>You have no new Transaction</Text>   

    }      


    </View>





  );

}
    
}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_item_date:{
     marginTop:6,
     marginBottom:6,
     color:'#333333',
     fontSize:13,
     fontWeight:'bold',
  },
  view_item_info:{
    backgroundColor:'#FFFFFF',
    paddingLeft:24,
    paddingRight:24,
    paddingTop:16,
    paddingBottom:16,
  },
  text_invoice_no:{
    color:'#000000',
     fontSize:13,
     fontWeight:'bold',
  },
  view_no_volue:{
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_remark:{
    marginTop:8,
    color:'#828282',
    fontSize:12,
  },
  text_no_data:{
    width:'100%',
    color:'#BDBDBD',
    fontWeight:'bold',
    fontSize:16,
    textAlign: 'center',
  },


});


