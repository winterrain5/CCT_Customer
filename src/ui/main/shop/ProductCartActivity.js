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


import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';


import TitleBar from '../../../widget/TitleBar';

let nativeBridge = NativeModules.NativeBridge;



export default class ProductCartActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       products:[],
       buy_now:0,
       tax:undefined,
       business:undefined,
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

    if (this.props && this.props.buy_now) {

      if (this.props.buy_now && this.props.buy_now == 1) {
        var products = [];
        products.push(this.props.product_detail);
  
        this.setState({
          buy_now : 1,
          products : products,
        });
  
      } else {

        DeviceStorage.get('shop_cart').then((cart_json) => {

          var carts = [];
    
          if (cart_json) {
              carts = JSON.parse(cart_json,'utf-8');
          }
    
          this.setState({
            buy_now : 0,
            products : carts,
          });
          
       });
      }
      
    } else if (this.props.route && this.props.route.params && this.props.route.params.buy_now && this.props.route.params.buy_now == 1) {


          var products = [];
          products.push(this.props.route.params.product_detail);

          this.setState({
            buy_now : 1,
            products : products,
          });
    
    } else {

      DeviceStorage.get('shop_cart').then((cart_json) => {

      var carts = [];

      if (cart_json) {
          carts = JSON.parse(cart_json,'utf-8');
      }

      this.setState({
        buy_now : 0,
        products : carts,
      });
      
   });

  }
    

    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

    });
     
  }


   //注册通知
  componentDidMount(){

     this.emit =  DeviceEventEmitter.addListener('shop_over',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI

          if (this.props.pressLeft) {
            this.props.pressLeft();
       
          }else if (this.props.navigation) {
            this.props.navigation.goBack();
       
          }else {
           nativeBridge.goBack();

         }
        
     });


  }

  componentWillUnmount(){  
    this.emit.remove();
  }




  _renderItem = (item) =>{

    var picture = item.item.Product.picture;
    var image_url = '';
    if (picture) {
      image_url = picture.slice(1,picture.length);
    }

   return (

        <View style = {{width:'100%',marginTop:16}}>


          <View style = {styles.view_item}>



              <View style = {styles.view_image_card}>

                  <Image 
                      style={{flex:1,borderRadius:16}}
                      source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                      resizeMode="cover" />



              </View>


              <View style = {{flex:1,paddingLeft:20,paddingTop:8}}>


                  <Text style = {styles.text_item_name}>{item.item.Product.alias}</Text>


                  <View style = {styles.view_item_price}>


                      <Text style = {styles.text_item_price}>{'$' + item.item.Product.sell_price}</Text>


                      <View style = {styles.view_product_num}>

                           <TouchableOpacity  
                              onPress={this.clickNumJian.bind(this,item)}>

                             <Image
                                style={{width:26,height:26}}
                                source={require('../../../../images/jian_525.png')}
                                resizeMode = 'contain' />

                          </TouchableOpacity>  


                          <Text style = {styles.text_num}>{item.item.product_num}</Text>


                           <TouchableOpacity  
                              onPress={this.clickNumAdd.bind(this,item)}>


                               <Image
                                style={{width:26,height:26}}
                                source={require('../../../../images/jia_525.png')}
                                resizeMode = 'contain' />    
                              

                          </TouchableOpacity>    

                    
                       </View>


                  </View>

              </View>


        
          </View>



          <View style = {styles.view_line} />




        </View>

        
      );



}


clickNumJian(item){


var new_produts = this.state.products;


  if (new_produts[item.index].product_num > 1) {

      var new_product_num = new_produts[item.index].product_num -1;

      new_produts[item.index].product_num = new_product_num;

      this.setState({
        products:new_produts,
      })

  }else {

    this.deleteProductCart(item);

  }

}

deleteProductCart(item){

        // 根据传入的方法渲染并弹出
    this.coverLayer.showWithContent(
                ()=> {
                    return (
                        <View style={styles.view_popup_bg}>


                          <Text style = {[styles.text_popup_title]}>Are you sure you want to remove this item?</Text>



                          <View style = {styles.xpop_cancel_confim}>

                            <TouchableOpacity   
                               style = {styles.xpop_touch}   
                               activeOpacity = {0.8}
                               onPress={this.clickDeleteCancel.bind(this)}>


                                <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                                  <Text style = {[styles.xpop_text,{color:'#333'}]}>Cancel</Text>

                               </View>


                            </TouchableOpacity>   



                            <TouchableOpacity
                               style = {styles.xpop_touch}    
                               activeOpacity = {0.8}
                               onPress={this.clickDeleteSure.bind(this,item)}>

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


clickDeleteCancel(){

  this.coverLayer.hide();

}


clickDeleteSure(item){

  this.coverLayer.hide();

  var new_products = this.state.products;
  new_products.splice(item.index,1);

  this.setState({
    products:new_products,
  });

  DeviceStorage.save('shop_cart', JSON.stringify(new_products));
  DeviceEventEmitter.emit('shop_cart_up','ok');

}





clickNumAdd(item){

  var new_produts = this.state.products;


  if (new_produts[item.index].product_num <= 99) {

      var new_product_num = new_produts[item.index].product_num + 1;

      new_produts[item.index].product_num = new_product_num;


      this.setState({
        products:new_produts,
      })

  }

}


_footer(){


  if (this.state.products && this.state.products.length > 0) {

    var items = 0;
    var total = 0;  


    var total_title = '0.00';

    if (this.state.products) {

      for (var i = 0; i < this.state.products.length; i++) {

        var product = this.state.products[i];

        items += product.product_num;


        var sell_price = parseFloat(product.Product.sell_price);


        total += (sell_price * product.product_num);
      }

    }


    total_title = StringUtils.toDecimal(total) + '';

   


    return (

      <View style = {styles.view_list_foot}>


          <View style = {styles.view_foot_item}>


              <Text style  = {styles.text_total}>Total Items</Text>


               <Text style = {styles.text_total}>{items}</Text>


          </View>


          <View style = {[styles.view_foot_item,{marginTop:24}]}>


              <Text style  = {styles.text_total}>Sub Total(GST Inclusive)</Text>

              <Text style = {styles.text_total}>${total_title}</Text>


          </View>



            <View style = {[styles.view_foot_item,{marginTop:24}]}>


              <Text style  = {[styles.text_total,{fontWeight:'bold'}]}>Total</Text>

              <Text style = {[styles.text_total,{fontWeight:'bold'}]}>${total_title}</Text>


          </View>


      </View>


      );



  }else {


    return (<View/>);


  }


 


}


clickNext(){



  // 获取 当前税率

  this.getTAllTaxes();

}


getTAllTaxes(){


  var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTAllTaxes id="o0" c:root="1" xmlns:n0="http://terra.systems/"><'+
  'companyId i:type="d:string">' + this.state.head_company_id + '</companyId>'+
  '</n0:getTAllTaxes></v:Body></v:Envelope>';  
  var temporary = this;
  Loading.show();
  WebserviceUtil.getQueryDataResponse('tax','getTAllTaxesResponse',data, function(json) {

      if (json && json.success == 1 && json.data && json.data.length > 0) {

          temporary.setState({
            tax:json.data[0],
          });
        
      }else {

        var tax = {};

        tax.id = '0';
        tax.rate = '7';
        tax.tax_code = 'GST';

        temporary.setState({
            tax:tax,
        });
      }


      temporary.getBusiness();



  });

}


// 获取默认人员
getBusiness(){

  var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getBusiness id="o0" c:root="1" xmlns:n0="http://terra.systems/" /></v:Body></v:Envelope>';  
  var temporary = this;
  WebserviceUtil.getQueryDataResponse('employee','getBusinessResponse',data, function(json) {

      
      if (json && json.success == 1 && json.data ) {

          temporary.setState({
            business:json.data,
          });

          temporary.checkoutTOrder(json.data.id);
        
      }else {
        toastShort('Network exception, Please try again later');
        Loading.hidden();
       
      }

     

  });

}


// 生成订单
checkoutTOrder(business_id){



   var total_all = 0;  

  var order_lines_data = '';

  for (var i = 0; i < this.state.products.length; i++) {

      var product = this.state.products[i];

      var tax = '';
      var voucher = 0;
      var rate = 0;
      var total = 0;

      voucher = parseFloat(product.Product.sell_price);
      rate = parseFloat(this.state.tax.rate);

      tax = (voucher - (voucher / (1 + rate / 100))) + '';

      total = voucher * product.product_num;

      total_all += (voucher * product.product_num);


      order_lines_data += ('' +
        '<item><key i:type="d:string">' + i + '</key><value i:type="n1:Map">'+
        '<item><key i:type="d:string">data</key><value i:type="n1:Map">'+
        '<item><key i:type="d:string">create_time</key><value i:type="d:string">'+ DateUtil.formatDateTime()+'</value></item>'+
        '<item><key i:type="d:string">tax_is_include</key><value i:type="d:string">1</value></item>'+
        '<item><key i:type="d:string">staff_id</key><value i:type="d:string">' + business_id + '</value></item>'+
        '<item><key i:type="d:string">location_id</key><value i:type="d:string">' + this.state.head_company_id + '</value></item>'+
        '<item><key i:type="d:string">tax_id</key><value i:type="d:string">'+ this.state.tax.id +'</value></item>'+
        '<item><key i:type="d:string">referrer</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">present_qty</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">responsible_doctor</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">qty</key><value i:type="d:string">' + product.product_num +'</value></item>'+
        '<item><key i:type="d:string">product_unit_id</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">delivery_time</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">appoint_sale_id</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">delivery_location_id</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">discount_id</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">product_id</key><value i:type="d:string">' + product.Product.id + '</value></item>'+
        '<item><key i:type="d:string">create_uid</key><value i:type="d:string">' + this.state.userBean.user_id + '</value></item>'+
        '<item><key i:type="d:string">staff_id2</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">is_delete</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">has_delivered</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">tax</key><value i:type="d:string">'+ tax +'</value></item>'+
        '<item><key i:type="d:string">equal_staffs</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">discount_id2</key><value i:type="d:string">0</value></item>'+
        '<item><key i:type="d:string">price</key><value i:type="d:string">' + voucher + '</value></item>'+
        '<item><key i:type="d:string">cost</key><value i:type="d:string">'+ voucher +'</value></item>'+
        '<item><key i:type="d:string">retail_price</key><value i:type="d:string">'+ voucher + '</value></item>'+
        '<item><key i:type="d:string">product_category</key><value i:type="d:string">' + (product.Product.product_category == 0 ? '5' : '1') +'</value></item>'+
        '<item><key i:type="d:string">collection_method</key><value i:type="d:string"></value></item>'+
        '<item><key i:type="d:string">total</key><value i:type="d:string">'+ total +'</value></item>'+
        '<item><key i:type="d:string">name</key><value i:type="d:string">'+ product.Product.alias+ '</value></item>'+
        '</value></item></value></item>');


 
  }
  var data ='<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:checkoutTOrder id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
  '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">Order_Lines</key><value i:type="n1:Map">'+
   order_lines_data  +
  '</value></item>'+
  '<item><key i:type="d:string">Order_Info</key><value i:type="n1:Map">'+
  '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
  '<item><key i:type="d:string">create_time</key><value i:type="d:string">'+ DateUtil.formatDateTime() +'</value></item>'+
  '<item><key i:type="d:string">customer_id</key><value i:type="d:string">' + this.state.userBean.id + '</value></item>'+
  '<item><key i:type="d:string">category</key><value i:type="d:string">2</value></item>'+
  '<item><key i:type="d:string">is_delete</key><value i:type="d:string">0</value></item>'+
  '<item><key i:type="d:string">company_id</key><value i:type="d:string">' + this.state.head_company_id + '</value></item>'+
  '<item><key i:type="d:string">location_id</key><value i:type="d:string">'+ this.state.head_company_id +'</value></item>'+
  '<item><key i:type="d:string">due_date</key><value i:type="d:string">' + DateUtil.formatDateTime1() + '</value></item>'+
  '<item><key i:type="d:string">status</key><value i:type="d:string">0</value></item>'+
  '<item><key i:type="d:string">invoice_date</key><value i:type="d:string">' + DateUtil.formatDateTime() + '</value></item>'+
  '<item><key i:type="d:string">is_from_app</key><value i:type="d:string">1</value></item>'+
  '<item><key i:type="d:string">type</key><value i:type="d:string">1</value></item>'+
  '<item><key i:type="d:string">total</key><value i:type="d:string">' + StringUtils.toDecimal(total_all)+ '</value></item>'+
  '<item><key i:type="d:string">subtotal</key><value i:type="d:string">'+ StringUtils.toDecimal(total_all) +'</value></item>'+
  '</value></item><item><key i:type="d:string">Client_Info</key><value i:type="n1:Map" /></item></data>'+
  '<logData i:type="n2:Map" xmlns:n2="http://xml.apache.org/xml-soap">'+
  '<item><key i:type="d:string">ip</key><value i:type="d:string"></value></item>'+
  '<item><key i:type="d:string">create_uid</key><value i:type="d:string">'+ this.state.userBean.user_id +'</value></item>'+
  '</logData>'+
  '<Cancel_Consultation_Ids i:type="n3:Map" xmlns:n3="http://xml.apache.org/xml-soap" /></n0:checkoutTOrder></v:Body></v:Envelope>';  
  var temporary = this;

  WebserviceUtil.getQueryDataResponse('sale','checkoutTOrderResponse',data, function(json) {

      
      Loading.hidden();
      if (json && json.success == 1 && json.data ) {

          temporary.toCheckOutActivity(json.data);  

      }else {
        toastShort('Network exception, Please try again later');

      }


  });

}


toCheckOutActivity(order_id){

  if (this.props.isNative) {
    NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'CheckOutActivity',property:{
      'buy_now':this.state.buy_now,
      'order_id':order_id,
    }});
  }else {
    const { navigation } = this.props;
    if (navigation) {
       navigation.replace('CheckOutActivity',{
        'buy_now':this.state.buy_now,
        'order_id':order_id,
      });
  
    }
  } 
}


_nextView(){


  if (this.state.products && this.state.products.length > 0) {


    return (
       <View style = {styles.next_view}>

          <TouchableOpacity style = {[styles.next_layout]}  
              activeOpacity = {0.8 }
              onPress={this.clickNext.bind(this)}>


                 <Text style = {styles.next_text}>Check Out</Text>

          </TouchableOpacity>

      </View>
    );


  }else {


    return (<View/>);

  }


}




 render() {

    const { navigation } = this.props;


    return (

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


         <SafeAreaView style = {styles.afearea} >


          <TitleBar
            title = {this.state.buy_now == 1 ? 'Buy Now' : 'Your Cart'} 
            navigation={navigation}
            hideLeftArrow = {true}
            hideRightArrow = {false}
            extraData={this.state}/>



          <View style = {[styles.bg,{padding:16}]}>


             <FlatList
                style = {{flex:1}}
                ref = {(flatList) => this._flatList = flatList}
                renderItem = {this._renderItem}
                ListFooterComponent={this._footer.bind(this)}
                onEndReachedThreshold={0}
                keyExtractor={(item, index) => index.toString()}
                data={this.state.products}/>  



             {this._nextView()}     


          
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
    backgroundColor:'#FFFFFF',
  },
  afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
  view_item : {
    width:'100%',
    flexDirection: 'row',
  },
  view_image_card:{
    flex:1,
    backgroundColor:'#F2F2F2',
    borderRadius:16,
    width:'100%',
    height:120,
  },
  text_item_name:{
    fontWeight: 'bold',
    fontSize:14,
    color:'#333333',
  },
  view_item_price : {
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_item_price:{
    marginTop:8,
    fontSize:16,
    color:'#333333',
  },
  view_product_num:{
    marginTop:8,
    flexDirection: 'row',
  },
  text_num:{
    width:30,
    marginTop:4,
    color:'#333',
    fontSize: 14,
    fontWeight: 'bold',
    textAlign:'center',
  },
  view_line : {
    marginTop : 16,
    backgroundColor:'#E0e0e0',
    width:'100%',
    height:1,
  },
  view_list_foot:{
    width:'100%',
    padding:16,
  },
  view_foot_item:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_total:{
    color:'#333',
    fontSize: 14,
  },
   next_layout:{
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
    marginTop:16
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
    color:'#333333',
    fontSize:16,
    textAlign :'center',
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
    view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
});